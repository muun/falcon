//
//  CardPairingDebugExecutable.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

final class CardPairingDebugExecutable: DebugExecutable {

    private let disposeBag = DisposeBag()
    private let paidNfcCardAction = PairNfcCardAction()

    func getTitleForCell() -> String {
        "Pair Security Card"
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {

        if #available(iOS 13.0, *) {
            paidNfcCardAction.run(seed: "00112233445566778899AABBCCDDEEFF",
                                  slot: 0)
            .subscribe { statusCode in
                Logger.log(.debug, "Setup Card response: \(statusCode)")
                completion()
            }.disposed(by: disposeBag)
        }
    }
}
