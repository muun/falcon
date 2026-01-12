//
//  NfcSessionImpl.swift
//  Muun
//
//  Created by Daniel Mankowski on 05/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import CoreNFC
import RxSwift

@available(iOS 13.0, *)
final class NfcSessionImpl: NSObject, NfcSession {

    private var session: NFCTagReaderSession?
    private var connectSubject: PublishSubject<Void>?

    /// Initiates an NFC tag reading session.
    func connect(alertMessage: String) -> Completable {
        invalidateSession()

        let subject = PublishSubject<Void>()
        connectSubject = subject

        session = NFCTagReaderSession(pollingOption: .iso14443,
                                      delegate: self,
                                      queue: .global(qos: .userInitiated))
        session?.alertMessage = alertMessage
        session?.begin()

        return subject.ignoreElements()
    }

    func transmit(message: Data) -> Single<CardNfcResponse> {
        return Single.create { single in
            if case let .iso7816(tag) = self.session?.connectedTag {
                if let apdu = NFCISO7816APDU(data: message) {
                    tag.sendCommand(apdu: apdu) { (response, sw1, sw2, error) in
                        if let error {
                            Logger.log(.err, "Error trasmiting command to NFC tag")
                            single(.error(MuunError(error)))
                            return
                        }
                        // Combines sw1 and sw2 in a Integer
                        let statusCode = (Int(sw1) & 0xFF) << 8 | (Int(sw2) & 0xFF)
                        let response = CardNfcResponse(response: response, statusCode: statusCode)
                        single(.success(response))
                    }
                } else {
                    Logger.log(.err, "Error decoding APDU command")
                    single(.error(MuunError(CardNfcError.decodingMessageError)))
                }
            } else {
                single(.error(MuunError(CardNfcError.unsupportedTagConnected)))
            }
            return Disposables.create()
        }
    }

    func close() {
        invalidateSession()
    }

    private func invalidateSession() {
        session?.invalidate()
        session = nil
        connectSubject = nil
    }
}

@available(iOS 13.0, *)
extension NfcSessionImpl: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        AnalyticsHelper.logEvent(
            "security_card_tap",
            parameters: ["type": "tag_reader_alert_shown"]
        )
        Logger.log(.debug, "NFC session became active.")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        // Ignores expected non-critical errors such as user cancellation or session timeout,
        // and only logs and propagates other errors to observers.
        if let readerError = error as? NFCReaderError {
            switch readerError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                return
            case .readerSessionInvalidationErrorSessionTimeout:
                AnalyticsHelper.logEvent(
                    "security_card_tap",
                    parameters: ["type": "tag_reader_session_timeout"]
                )
                return
            default:
                break
            }
        }
        Logger.log(.warn, "NFC session invalidated with error: \(error.localizedDescription)")
        connectSubject?.onError(MuunError(error))
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        if tags.count > 1 {
            session.alertMessage = "More than 1 tags found. Please present only 1 tag."
            return
        }

        guard let firstTag = tags.first, case .iso7816 = firstTag else {
            session.invalidate(errorMessage: "No NFC tag detected.")
            Logger.log(.err, "No NFC ISO7816 tag detected.")
            connectSubject?.onError(MuunError(CardNfcError.unsupportedTagConnected))
            return
        }

        session.connect(to: firstTag) { [weak self] error in
            if let error = error {
                Logger.log(.err, "Error connecting to NFC tag: \(error.localizedDescription)")
                self?.connectSubject?.onError(MuunError(error))
                return
            }
            Logger.log(.debug, "Successfully connected to NFC tag.")
            self?.connectSubject?.onCompleted()
        }
    }
}
