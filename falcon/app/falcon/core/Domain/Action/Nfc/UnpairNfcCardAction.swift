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
    private let disposeBag = DisposeBag()

    func run(slot: UInt8) -> Completable {
        return Completable.create { completable in
            self.cardNfcService.connect(alertMessage: "Unpair Muun security card")
                .subscribe(onCompleted: {
                    self.walletService.resetSecurityCard()
                        .subscribe(onCompleted: {
                            Logger.log(.debug, "Security card was unpaired successfully")
                            completable(.completed)
                            self.cardNfcService.close()
                        }, onError: { error in
                            Logger.log(
                                .err,
                                "Card unpair failed! Error: \(error.localizedDescription)"
                            )
                            self.cardNfcService.close()
                            completable(.error(error))
                        }).disposed(by: self.disposeBag)
                }, onError: { error in
                    Logger.log(.err, "Can't connect security card: \(error.localizedDescription)")
                    self.cardNfcService.close()
                    completable(.error(error))
                })
        }
    }
}
