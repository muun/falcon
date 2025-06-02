//
//  UnpairNfcCardAction.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class UnpairNfcCardAction: Resolver {

    private let cardNfcService: CardNfcService = resolve()
    private let walletService: WalletService = resolve()
    private let userRepository: UserRepository = resolve()
    private let disposeBag = DisposeBag()

    func run(slot: UInt8) -> Single<NfcStatusCode> {
        return Single.create { single in
            self.cardNfcService.connect(alertMessage: "Unpair Muun security card")
                .subscribe { _ in
                    CardUtils.selectApplet(walletService: self.walletService,
                                           appletId: "A00000015100133700")

                    let cla: UInt8 = 0x80   // javaCard.MUUNCARD_CLA_EDGE
                    let ins: UInt8 = 0x30   // INS_MUUNCARD_RESET
                    let p2: UInt8 = 0x00    // javacard.NULL_BYTE

                    let apdu = APDU.buildAPDU(cls: cla,
                                              ins: ins,
                                              data: Data().bytes,
                                              p1: slot,
                                              p2: p2)

                    self.walletService.nfcTransmit(apduCommand: apdu.apduMessage())
                        .subscribe(onSuccess: { response in
                            let nfcStatusCode = CardUtils.getNfcStatusCode(response.statusCode)
                            if nfcStatusCode == .responseOk {
                                self.userRepository.setCardActivated(isActivated: false)
                            }
                            single(.success(nfcStatusCode))
                            CardUtils.deselectApplet(walletService: self.walletService)
                            self.cardNfcService.close()
                        }).disposed(by: self.disposeBag)
                }
        }
    }
}
