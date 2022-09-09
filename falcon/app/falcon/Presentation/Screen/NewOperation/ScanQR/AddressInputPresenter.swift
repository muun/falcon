//
//  ScanQRPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 04/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import RxSwift
import core

protocol AddressInputPresenterDelegate: BasePresenterDelegate {
    func checkForClipboardChange()
}

class AddressInputPresenter<Delegate: AddressInputPresenterDelegate>: BasePresenter<Delegate> {

    private let userRepository: UserRepository
    private let preferences: Preferences

    init(delegate: Delegate, userRepository: UserRepository, preferences: Preferences) {
        self.userRepository = userRepository
        self.preferences = preferences

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(userRepository.watchAppState(), onNext: self.onAppStateChange)
    }

    private func onAppStateChange(_ result: Bool?) {
        if let isInForeground = result, isInForeground {
            delegate.checkForClipboardChange()
        }
    }

    func isValid(rawAddress: String) -> Bool {
        return AddressHelper.isValid(rawAddress: rawAddress)
    }

    func isValid(lnurl: String) -> Bool {
        return AddressHelper.isValid(lnurl: lnurl)
    }

    func getPaymentIntent(for raw: String) throws -> PaymentIntent {
        return try AddressHelper.parse(raw)
    }

    func isOwnAddress(_ address: String) -> Bool {
        #if !DEBUG
        if let ownAddress = getOwnAddress() {
            return address == ownAddress
        }
        #endif
        return false
    }

    private func getOwnAddress() -> String? {
        return preferences.string(forKey: .lastOwnAddressCopied)
    }

}
