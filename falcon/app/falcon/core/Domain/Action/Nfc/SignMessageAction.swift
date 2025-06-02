//
//  SignMessageAction.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class SignMessageAction: Resolver {

    private let cardNfcService: CardNfcService = resolve()
    private let walletService: WalletService = resolve()
    private let disposeBag = DisposeBag()

    func run(message: String, slot: UInt8) -> Single<Data?> {
        return Single.create { single in
            self.cardNfcService.connect(alertMessage: "Approve transaction with you card")
                .subscribe(onCompleted: {
                    CardUtils.selectApplet(walletService: self.walletService,
                                           appletId: "A00000015100133700")

                    let secureChannel = SecureChannel()

                    let scInitialized = secureChannel.cardInitiateSecureChannel(
                        cardNfcService: self.cardNfcService
                    )

                    guard scInitialized else {
                        single(.success(nil))
                        return
                    }

                    let signedMessage = self.sendSignMessage(
                        secureChannel: secureChannel,
                        cardNfcService: self.cardNfcService,
                        message: message,
                        slot: slot
                    )

                    CardUtils.deselectApplet(walletService: self.walletService)
                    single(.success(signedMessage))
                    self.cardNfcService.close()
                }, onError: { error in
                    Logger.log(.err, "Signature verification failed! \(error.localizedDescription)")
                    single(.error(error))
                })
        }
    }

    private func sendSignMessage(secureChannel: SecureChannel,
                                 cardNfcService: CardNfcService,
                                 message: String,
                                 slot: UInt8) -> Data? {
        let cla: UInt8 = 0x80   // javaCard.MUUNCARD_CLA_EDGE
        let ins: UInt8 = 0x80   // INS_MUUNCARD_SIGN_MESSAGE
        let p2: UInt8 = 0x00    // javacard.NULL_BYTE

        // Convert the message to bytes and apply PKCS7 padding
        guard let messageData = message.data(using: .utf8) else {
            return nil  // Return nil if conversion fails.
        }

        let blockSize = 16

        // Compute PKCS7 padding length.
        let paddingLength = blockSize - (messageData.count % blockSize)
        // Create padding bytes: each byte has the value equal to paddingLength.
        let paddingData = Data(repeating: UInt8(paddingLength), count: paddingLength)
        // Create the padded message.
        var paddedMessage = messageData
        paddedMessage.append(paddingData)

        // Build the APDU message using your APDU builder.
        // This constructs an APDU with the format: [cla, ins, p1, p2, Lc, data...]
        let apdu = APDU.buildAPDU(cls: cla,
                                  ins: ins,
                                  data: paddedMessage.bytes,
                                  p1: slot,
                                  p2: p2)
        let serializedAPDU = apdu.apduMessage()

        // Transmit the APDU message securely.
        // swiftlint:disable force_error_handling
        guard let encryptedAPDU =
                try? secureChannel.cardEncryptSecureChannelMessageRequest(apdu: serializedAPDU)
        else { return nil }

        Logger.log(.debug, "NFC: sending encrypted message through secure channel")

        // Transmit the encrypted APDU to the card.
        // swiftlint:disable force_error_handling
        guard let response =
                try? walletService.nfcTransmit(apduCommand: encryptedAPDU).toBlocking().single()
        else { return nil }

        // Check for a successful response.
        let nfcStatusCode = CardUtils.getNfcStatusCode(response.statusCode)
        if nfcStatusCode != NfcStatusCode.responseOk {
            Logger.log(.err,
                       "Error: Couldn't sign message: \(String(format: "%x", response.statusCode))")
            return nil  // Return nil if the response is not OK.
        }

        // Verify the MAC in the response and return the final data.
        return secureChannel.verifyResponseMAC(response: response.response)
    }
}
