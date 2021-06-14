//
//  ReceivePresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift
import core

protocol ReceivePresenterDelegate: BasePresenterDelegate {
    func didReceiveNewOperation(message: String)
    func show(invoice: IncomingInvoiceInfo?)
}

class ReceivePresenter<Delegate: ReceivePresenterDelegate>: BasePresenter<Delegate> {

    private let addressActions: AddressActions
    private let operationActions: OperationActions
    private let createInvoiceAction: CreateInvoiceAction
    private let preferences: Preferences
    internal let fetchNotificationsAction: FetchNotificationsAction
    private let userPreferencesSelector: UserPreferencesSelector

    private let segwitAddress: String
    private let legacyAddress: String
    private var numberOfOperations: Int?

    private var customAmount: BitcoinAmount?
    private var amountChanged: Bool = false

    init(delegate: Delegate,
         addressActions: AddressActions,
         preferences: Preferences,
         operationActions: OperationActions,
         createInvoiceAction: CreateInvoiceAction,
         fetchNotificationsAction: FetchNotificationsAction,
         userPreferencesSelector: UserPreferencesSelector) {
        self.addressActions = addressActions
        self.preferences = preferences
        self.operationActions = operationActions
        self.createInvoiceAction = createInvoiceAction
        self.fetchNotificationsAction = fetchNotificationsAction
        self.userPreferencesSelector = userPreferencesSelector
        do {
            let (segwit, legacy) = try addressActions.generateExternalAddresses()
            self.segwitAddress = segwit
            self.legacyAddress = legacy
        } catch {
            Logger.fatal(error: error)
        }

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        // Fetch every 10 seconds for new operations
        let periodicFetch = buildFetchNotificationsPeriodicAction(intervalInSeconds: 10)

        subscribeTo(periodicFetch, onNext: { _ in })
        subscribeTo(operationActions.getOperationsChange(), onNext: self.onOperationsChange)
    }

    func getOnChainAddresses() -> (segwit: String, legacy: String) {
        return (segwitAddress, legacyAddress)
    }

    func getCustomAmount() -> BitcoinAmount? {
        return customAmount
    }

    func setCustomAmount(_ amount: BitcoinAmount?) {
        amountChanged = customAmount != amount
        customAmount = amount
    }

    func refreshLightningInvoice() {

        self.delegate.show(invoice: nil)

        let amount = customAmount?.inSatoshis

        var action = createInvoiceAction.run(amount: amount)
        if amountChanged {
            // TODO: review scheduler for this
            action = action.delay(.seconds(1), scheduler: MainScheduler.instance)
            amountChanged = false
        }

        subscribeTo(action) { rawInvoice in
            let unixExpiration = self.getUnixExpirationTime(rawInvoice)
            let info = IncomingInvoiceInfo(rawInvoice: rawInvoice, expiresAt: unixExpiration)
            self.delegate.show(invoice: info)
        }
    }

    private func getUnixExpirationTime(_ rawInvoice: String) -> Double {
        do {
            let paymentIntent = try AddressHelper.parse(rawInvoice)
            switch paymentIntent {
            case .submarineSwap(let invoice):
                return Double(invoice.expiry)
            default:
                Logger.fatal("Trying to parse something that is not a lightning invoice: \(rawInvoice)")
            }
        } catch {
            Logger.fatal("Trying to parse something that is not a lightning invoice: \(rawInvoice)")
        }
    }

    private func onOperationsChange(_ change: OperationsChange) {
        if numberOfOperations == nil {
            self.numberOfOperations = change.numberOfOperations
        }

        if let ops = numberOfOperations, change.numberOfOperations > ops, let newOp = change.lastOperation {

            // Only do this for BROADCASTED to avoid refreshing the invoice or
            // showing a toast again for CONFIRMED ops
            if newOp.status != .BROADCASTED {
                return
            }

            if newOp.incomingSwap != nil {
                refreshLightningInvoice()
            }

            let amount = newOp.amount.inInputCurrency.toString()
            let message = L10n.ReceivePresenter.s1(amount)
            delegate.didReceiveNewOperation(message: message)
        }
    }

    func saveOwnAddress(_ address: String) {
        preferences.set(value: address, forKey: .lastOwnAddressCopied)
    }

    func skipPushNotificationsPermission() {
        preferences.set(value: true, forKey: .didSkipPushNotificationPermission)
    }

    func hasSkippedPushNotificationsPermission() -> Bool {
        return preferences.bool(forKey: .didSkipPushNotificationPermission)
    }

    func isLNURLFirstTimeUser() -> Bool {
        let preferences = try? userPreferencesSelector.get()
            .toBlocking()
            .first()

        return !(preferences?.seenLnurlFirstTime ?? false)
    }

}

extension ReceivePresenter: NotificationsFetcher {}
