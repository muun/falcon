//
//  SignMessageAction.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class SignMessageAction: Resolver {

    private let nfcSession: NfcSession = resolve()
    private let walletService: WalletService = resolve()
    private let disposeBag = DisposeBag()

    func run(message: String) -> Single<[UInt8]> {
        return Single.create { single in
            let connectionDisposable = self.nfcSession
                .connect(alertMessage: "Approve transaction with you card")
                .subscribe(onCompleted: {
                    self.walletService.signMessageWithSecurityCard(messageHex: message)
                        .subscribe(onSuccess: { signedMessageBytes in
                            single(.success(signedMessageBytes))
                        }, onError: { error in
                            Logger.log(.debug, "Sign message error: \(error.localizedDescription)")
                            single(.error(error))
                       }).disposed(by: self.disposeBag)
                }, onError: { error in
                    Logger.log(.err, "Can't connect security card: \(error.localizedDescription)")
                    single(.error(error))
                })

            return Disposables.create {
                connectionDisposable.dispose()
                self.nfcSession.close()
            }
        }
    }
}
