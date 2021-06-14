//
//  LNURLScanQRPresenter.swift
//  falcon
//
//  Created by Federico Bond on 09/04/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import RxSwift
import core

protocol LNURLScanQRPresenterDelegate: BasePresenterDelegate {
    func checkForClipboardChange()
}

class LNURLScanQRPresenter<Delegate: LNURLScanQRPresenterDelegate>: BasePresenter<Delegate> {

    private let userRepository: UserRepository
    private let preferences: Preferences
    private let lnurlWithdrawAction: LNURLWithdrawAction

    init(delegate: Delegate, userRepository: UserRepository, preferences: Preferences, lnurlWithdrawAction: LNURLWithdrawAction) {
        self.userRepository = userRepository
        self.preferences = preferences
        self.lnurlWithdrawAction = lnurlWithdrawAction

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(userRepository.watchAppState(), onNext: self.onAppStateChange)
    }

    func validate(qr: String) -> Bool {
        return lnurlWithdrawAction.preflight(qr: qr)
    }

    private func onAppStateChange(_ result: Bool?) {
        if let isInForeground = result, isInForeground {
            delegate.checkForClipboardChange()
        }
    }

}
