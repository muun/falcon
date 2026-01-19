//
//  LibwalletNfcBridge.swift
//  Muun
//
//  Created by Daniel Mankowski on 01/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Libwallet

final class LibwalletNfcBridge: NSObject, App_provided_dataNfcBridgeProtocol {

    private let nfcSession: NfcSession

    init(nfcSession: NfcSession) {
        self.nfcSession = nfcSession
    }

    /// Transmits a message to the NFC card and returns a synchronous response for Libwallet.
    /// WARNING: This function uses a blocking call. If called on the main thread,
    /// it may block the UI.
    func transmit(_ message: Data?) throws -> App_provided_dataNfcBridgeResponse {
        let defaultBridgeResponse = App_provided_dataNfcBridgeResponse()
        guard let message else {
            fatalError("message can't be nil")
        }

        // Wait for the asynchronous NFC operation to complete and obtain its response,
        // so that it can be passed to Libwallet.
        // Note: This uses RxSwift's toBlocking() to convert the asynchronous Single into
        // a synchronous value.
        do {
            // Convert the asynchronous operation (Single) into a blocking call.
            let cardResponse: CardNfcResponse = try nfcSession.transmit(message: message)
                .toBlocking()
                .single()
            return cardResponse.toLibwallet()
        } catch {
            return defaultBridgeResponse
        }
    }
}
