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
    func show(bitcoinURIViewModel: BitcoinURIViewModel?)
}

class ReceivePresenter<Delegate: ReceivePresenterDelegate>: BasePresenter<Delegate> {

    private let addressActions: AddressActions
    private let operationActions: OperationActions
    private let createInvoiceAction: CreateInvoiceAction
    private let createBitcoinURIAction: CreateBitcoinURIAction
    private let preferences: Preferences
    internal let fetchNotificationsAction: FetchNotificationsAction
    private let userPreferencesSelector: UserPreferencesSelector

    private let addressSet: AddressSet
    private var currentAddressType: AddressTypeViewModel?
    private var numberOfOperations: Int?

    private var customAmount: BitcoinAmountWithSelectedCurrency? {
        didSet {
            lastGeneratedBitcoinUri = nil // The existing bitcoinURI is invalid if amount change.
        }
    }
    private var amountChanged: Bool = false
    private var lastGeneratedBitcoinUri: BitcoinURIViewModel?

    init(delegate: Delegate,
         addressActions: AddressActions,
         preferences: Preferences,
         operationActions: OperationActions,
         createInvoiceAction: CreateInvoiceAction,
         createBitcoinURIAction: CreateBitcoinURIAction,
         fetchNotificationsAction: FetchNotificationsAction,
         userPreferencesSelector: UserPreferencesSelector) {
        self.addressActions = addressActions
        self.preferences = preferences
        self.operationActions = operationActions
        self.createInvoiceAction = createInvoiceAction
        self.fetchNotificationsAction = fetchNotificationsAction
        self.userPreferencesSelector = userPreferencesSelector
        self.createBitcoinURIAction = createBitcoinURIAction
        do {
            self.addressSet = try addressActions.generateExternalAddresses()
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

    func getOnChainAddresses() -> AddressSet {
        return addressSet
    }

    func getCustomAmount() -> BitcoinAmountWithSelectedCurrency? {
        return customAmount
    }

    func setCustomAmount(_ amount: BitcoinAmountWithSelectedCurrency?) {
        amountChanged = customAmount != amount
        customAmount = amount
    }

    func refreshLightningInvoice() {
        self.delegate.show(invoice: nil)

        let amount = customAmount?.bitcoinAmount.inSatoshis

        var action = createInvoiceAction.run(amount: amount)
        if amountChanged {
            // TODO: review scheduler for this
            action = action.delay(.seconds(1), scheduler: MainScheduler.instance)
            amountChanged = false
        }

        subscribeTo(action) { rawInvoice in
            let info = IncomingInvoiceInfo.from(raw: rawInvoice)
            self.delegate.show(invoice: info)
        }
    }

    func refreshUnifiedQR(replacingSelectedAddressTypeBy newAddressType: AddressTypeViewModel? = nil) {
        self.currentAddressType = newAddressType ?? currentAddressType
        self.delegate.show(bitcoinURIViewModel: nil)

        let amount = customAmount?.bitcoinAmount.inSatoshis

        let address = getAddressBy(addressType: getCurrentAddressTypeOrDefault())

        var action = createBitcoinURIAction.run(amount: amount,
                                                reusableInvoice: retrieveReusableInvoice(),
                                                address: address)
        if amountChanged {
            action = action.delay(.seconds(1), scheduler: MainScheduler.instance)
            amountChanged = false
        }

        subscribeTo(action) { [weak self] rawBitcoinUri in
            self?.lastGeneratedBitcoinUri = BitcoinURIViewModel.from(raw: rawBitcoinUri)
            self?.delegate.show(bitcoinURIViewModel: self?.lastGeneratedBitcoinUri)
        }
    }

    private func retrieveReusableInvoice() -> ReusableInvoiceForURICreation? {
        var reusableInvoice: ReusableInvoiceForURICreation?
        lastGeneratedBitcoinUri.map {
            reusableInvoice = ReusableInvoiceForURICreation(raw: $0.invoice.rawInvoice,
                                                            expiresAt: $0.invoice.expiresAt)
        }

        return reusableInvoice
    }

    private func getCurrentAddressTypeOrDefault() -> AddressTypeViewModel {
        return currentAddressType ?? defaultAddressType()
    }

    private func getAddressBy(addressType: AddressTypeViewModel) -> String {
        switch addressType {
        case .taproot: return getOnChainAddresses().taproot
        case .segwit: return getOnChainAddresses().segwit
        case .legacy: return getOnChainAddresses().legacy
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
                if retrieveReceivePreference() == .UNIFIED {
                    refreshUnifiedQR()
                } else {
                    refreshLightningInvoice()
                }
            }

            let newOpInputCurrency = newOp.amount.inInputCurrency
            let amount = newOpInputCurrency.toAmountPlusCode()
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

    func retrieveReceivePreference() -> ReceiveFormatPreference {
        let preferences = try? userPreferencesSelector.get()
            .toBlocking()
            .first()

        return preferences?.receiveFormatPreference ?? .ONCHAIN
    }

    func defaultAddressType() -> AddressTypeViewModel {
        do {
            let preferences = try userPreferencesSelector.get()
                .toBlocking()
                .single()

            return AddressTypeViewModel.from(model: preferences.defaultAddressType)
        } catch {
            return .segwit
        }
    }
}

extension ReceivePresenter: NotificationsFetcher {}
