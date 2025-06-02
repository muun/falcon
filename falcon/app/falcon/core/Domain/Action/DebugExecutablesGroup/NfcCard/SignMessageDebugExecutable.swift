//
//  SignMessageDebugExecutable.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class SignMessageDebugExecutable: DebugExecutable {

    private let disposeBag = DisposeBag()
    private let signMessageAction = SignMessageAction()

    func getTitleForCell() -> String {
        "Sign message with card"
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        if #available(iOS 13.0, *) {
            let message = "testing NFC in iOS"
            signMessageAction.run(
                message: message,
                slot: 0
            )
            .subscribe(onSuccess: { signedMessage in
                if let signedMessageText = signedMessage?.debugDescription {
                    Logger.log(.debug, "Signed message response: \(signedMessageText)")
                }
                completion()
            }).disposed(by: disposeBag)
        }
    }
}
