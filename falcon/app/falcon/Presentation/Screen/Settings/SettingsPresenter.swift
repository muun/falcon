//
//  SettingsPresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 21/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core
import Libwallet

protocol SettingsPresenterDelegate: BasePresenterDelegate {
    func successfullyUpdateUser()
    func setCurrencyLoading(_ isLoading: Bool)
}

enum SettingsSection {
    case general(_ generalRows: [GeneralRow])
    case security(_ securityRows: [SecurityRow])
    case advanced(_ rows: [AdvancedRow])
    case logout
    case deleteWallet
    case version
}

enum GeneralRow {
    case bitcoinUnit
    case changeCurrency
}

enum SecurityRow {
    case changePassword
}

enum AdvancedRow {
    case lightningNetwork
    case onchain
}

class SettingsPresenter<Delegate: SettingsPresenterDelegate>: BasePresenter<Delegate> {

    private let logoutAction: LogoutAction
    private let sessionActions: SessionActions
    private let exchangeRateRepository: ExchangeRateWindowRepository
    private let changeCurrencyAction: ChangeCurrencyAction
    private let operationActions: OperationActions
    private let balanceActions: BalanceActions
    private let userActivatedFeatureSelector: UserActivatedFeaturesSelector

    var sections: [SettingsSection] = []

    private var userBalance: MonetaryAmount?
    // We will use this property to determine if anon users can delete their wallet
    private var hasPendingOps = false
    // Users can't log out with pending incoming swaps, because they'd lose the preimages
    private var hasPendingIncomingSwaps = false

    init(delegate: Delegate,
         logoutAction: LogoutAction,
         sessionActions: SessionActions,
         exchangeRateWindowRepository: ExchangeRateWindowRepository,
         changeCurrencyAction: ChangeCurrencyAction,
         operationActions: OperationActions,
         balanceActions: BalanceActions,
         userActivatedFeatureSelector: UserActivatedFeaturesSelector) {
        self.logoutAction = logoutAction
        self.sessionActions = sessionActions
        self.exchangeRateRepository = exchangeRateWindowRepository
        self.changeCurrencyAction = changeCurrencyAction
        self.operationActions = operationActions
        self.balanceActions = balanceActions
        self.userActivatedFeatureSelector = userActivatedFeatureSelector

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        sections = buildSections()
        subscribeTo(changeCurrencyAction.getState(), onNext: self.onChangeCurrency)
        subscribeTo(operationActions.getOperationsChange(), onNext: self.onOperationsChange)
        subscribeTo(balanceActions.watchBalance(), onNext: self.onBalanceChange)
    }

    private func onOperationsChange(_ change: OperationsChange) {
        hasPendingIncomingSwaps = operationActions.hasPendingIncomingSwaps()
        hasPendingOps = operationActions.hasPendingOperations(includeUnsettled: true)
    }

    private func onBalanceChange(_ balance: MonetaryAmount) {
        self.userBalance = balance
    }

    func logout() {
        logoutAction.run()
    }

    func deleteWallet() {
        logoutAction.run()
    }

    private func buildSections() -> [SettingsSection] {
        var sections: [SettingsSection] = []
        sections.append(.general([.bitcoinUnit, .changeCurrency]))

        if sessionActions.hasPasswordChallengeKey() {
            sections.append(.security([.changePassword]))
        }

        switch userActivatedFeatureSelector.get(for: Libwallet.userActivatedFeatureTaproot()!) {
        case .active, .preactivated, .scheduledActivation:
            sections.append(.advanced([.onchain, .lightningNetwork]))
        default:
            sections.append(.advanced([.lightningNetwork]))
        }

        if sessionActions.isAnonUser() {
            sections.append(.deleteWallet)
        } else {
            sections.append(.logout)
        }

        sections.append(.version)
        return sections
    }

    func getPrimaryCurrency() -> String {
        return sessionActions.getPrimaryCurrency()
    }

    func getReadablePrimaryCurrency() -> String {
        return CurrencyHelper.readableCurrency(code: getPrimaryCurrency())
    }

    func getBitcoinUnit() -> String {
        let currency = CurrencyHelper.bitcoinCurrency
        return currency.name
    }

    func getExchangeRateWindow() -> ExchangeRateWindow? {
        return exchangeRateRepository.getExchangeRateWindow()
    }

    func shouldDisplayBtcLogo() -> Bool {
        return getReadablePrimaryCurrency() == getBitcoinUnit()
    }

    func didChangeCurrency(_ currency: Currency) {
        var userUpdated: User
        if let user = sessionActions.getUser() {
            userUpdated = user
            userUpdated.setPrimaryCurrency(currency.code)

            changeCurrencyAction.run(user: userUpdated)
        }
    }

    private func onChangeCurrency(_ result: ActionState<User>) {
        switch result.type {

        case .EMPTY:
            delegate.setCurrencyLoading(false)

        case .ERROR:
            if let e = result.error {
                handleError(e)

            } else {
                handleError(ServiceError.defaultError)
            }

        case .LOADING:
            delegate.setCurrencyLoading(true)

        case .VALUE:
            delegate.successfullyUpdateUser()
        }
    }

    func canDeleteWallet() -> Bool {
        if let balance = userBalance, balance.amount > 0 {
            return false
        }

        return !hasPendingOps
    }

    func hasPendingIncomingSwapOperations() -> Bool {
        return hasPendingIncomingSwaps
    }

#if DEBUG
    func debugChangeTaprootActivation() {
        userActivatedFeatureSelector.debugChangeTaprootActivation()
        delegate.showMessage(
            "New status \(userActivatedFeatureSelector.get(for: Libwallet.userActivatedFeatureTaproot()!))"
        )
    }
#endif

}
