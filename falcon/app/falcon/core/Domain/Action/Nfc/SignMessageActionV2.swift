//
//  SignMessageActionV2.swift
//  falcon
//
//  Created by Daniel Mankowski on 17/10/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class SignMessageActionV2: Resolver {

    private let nfcSession: NfcSession = resolve()
    private let walletService: WalletService = resolve()
    private let disposeBag = DisposeBag()

    func run() -> Completable {
        return Completable.create { completable in
            let connectionDisposable = self.nfcSession
                .connect(alertMessage: "Approve transaction with you card")
                .subscribe(onCompleted: {
                    AnalyticsHelper.logEvent(
                        "security_card_tap",
                        parameters: ["type": "detected"]
                    )
                    self.walletService.signMessageWithSecurityCardV2()
                        .subscribe(onCompleted: {
                            completable(.completed)
                        }, onError: { error in
                            Logger.log(.debug, "Sign message error: \(error.localizedDescription)")
                            completable(.error(error))
                       }).disposed(by: self.disposeBag)
                }, onError: { error in
                    Logger.log(.err, "Can't connect security card: \(error.localizedDescription)")
                    completable(.error(error))
                })

            return Disposables.create {
                connectionDisposable.dispose()
                self.nfcSession.close()
            }
        }
    }
}
