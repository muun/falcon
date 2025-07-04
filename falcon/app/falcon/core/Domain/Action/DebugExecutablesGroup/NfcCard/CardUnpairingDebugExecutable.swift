//
//  CardUnpairingDebugExecutable.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class CardUnpairingDebugExecutable: DebugExecutable {

    private let disposeBag = DisposeBag()
    private let unpairNfcCardAction = UnpairNfcCardAction()

    func getTitleForCell() -> String {
        "Unpair Security Card"
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        if #available(iOS 13.0, *) {
            unpairNfcCardAction.run(slot: 0)
                .subscribe { statusCode in
                    Logger.log(.debug, "Unpair Card response: \(statusCode)")
                    completion()
                }.disposed(by: disposeBag)
        }
    }
}
