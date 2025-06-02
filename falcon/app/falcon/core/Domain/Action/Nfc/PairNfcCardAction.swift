//
//  PairNfcCardAction.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class PairNfcCardAction: Resolver {

    private let cardNfcService: CardNfcService = resolve()
    private let walletService: WalletService = resolve()
    private let userRepository: UserRepository = resolve()
    private let disposeBag = DisposeBag()

    func run(seed: String, slot: UInt8) -> Single<NfcStatusCode> {
        return Single.create { single in
            self.cardNfcService.connect(alertMessage: "Pair your Muun security card")
                .subscribe { _ in
                    CardUtils.selectApplet(walletService: self.walletService,
                                           appletId: "A00000015100133700")

                    let secureChannel = SecureChannel()

                    let scInitialized = secureChannel.cardInitiateSecureChannel(
                        cardNfcService: self.cardNfcService
                    )

                    guard scInitialized else {
                        self.cardNfcService.close()
                        return
                    }

                    guard let apduData = self.makeSetupCardSlotAPDU(secureChannel: secureChannel,
                                                     cardNfcService: self.cardNfcService,
                                                     seed: seed,
                                                     slot: slot)
                    else { return }

                    self.cardNfcService.transmit(message: apduData)
                        .subscribe(onSuccess: { response in
                            let nfcStatusCode = CardUtils.getNfcStatusCode(response.statusCode)
                            if nfcStatusCode == .responseOk {
                                self.userRepository.setCardActivated(isActivated: true)
                            }
                            single(.success(nfcStatusCode))
                            CardUtils.deselectApplet(walletService: self.walletService)
                            self.cardNfcService.close()
                        }, onError: { error in
                            Logger.log(.debug, "Card Transmit error: \(error.localizedDescription)")
                        }).disposed(by: self.disposeBag)
                }
        }
    }

    private func makeSetupCardSlotAPDU(secureChannel: SecureChannel,
                                       cardNfcService: CardNfcService,
                                       seed: String,
                                       slot: UInt8) -> Data? {

        let cla: UInt8 = 0x80   // javaCard.MUUNCARD_CLA_EDGE
        let ins: UInt8 = 0x10   // INS_MUUNCARD_SIGN_MESSAGE
        let p2: UInt8 = 0x00    // javacard.NULL_BYTE

        let seedBytes = Data(hex: seed)
        let apdu = APDU.buildAPDU(cls: cla, ins: ins, data: seedBytes.bytes, p1: slot, p2: p2)

        // swiftlint:disable force_error_handling
        return try? secureChannel.cardEncryptSecureChannelMessageRequest(apdu: apdu.apduMessage())
    }
}
