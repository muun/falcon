//
//  NewOpLoadingPresenter.swift
//  falcon
//
//  Created by Manu Herrera on 27/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import RxSwift
import Libwallet

protocol NewOpLoadingPresenterDelegate: BasePresenterDelegate {
    func loadingDidFinish(feeInfo: FeeInfo,
                          user: User,
                          paymentRequestType: PaymentRequestType)
    func expiredInvoice()
    func invalidAddress()
    func swapError(_ error: NewOpError)
    func unexpectedError()
    func invoiceMissingAmount()
}

class NewOpLoadingPresenter<Delegate: NewOpLoadingPresenterDelegate>: BasePresenter<Delegate> {

    private struct CombinedSingleResult {
        let feeInfo: FeeInfo
        let paymentRequestType: PaymentRequestType
        let user: User
    }

    private let paymentIntent: PaymentIntent
    private let feeCalculatorAction: FeeCalculatorAction
    private let userSelector: UserSelector
    private let submarineSwapAction: SubmarineSwapAction
    private let bip70Action: BIP70Action
    private let preloadFeeDataAction: PreloadFeeDataAction
    private let featureFlagsRepository: FeatureFlagsRepository
    private let feeBumpFunctionsProvider: FeeBumpFunctionsProvider

    init(delegate: Delegate,
         state: PaymentIntent,
         feeCalculatorAction: FeeCalculatorAction,
         userSelector: UserSelector,
         submarineSwapAction: SubmarineSwapAction,
         bip70Action: BIP70Action,
         preloadFeeDataAction: PreloadFeeDataAction,
         featureFlagsRepository: FeatureFlagsRepository,
         feeBumpFunctionsProvider: FeeBumpFunctionsProvider) {
        self.paymentIntent = state
        self.feeCalculatorAction = feeCalculatorAction
        self.userSelector = userSelector
        self.submarineSwapAction = submarineSwapAction
        self.bip70Action = bip70Action
        self.preloadFeeDataAction = preloadFeeDataAction
        self.featureFlagsRepository = featureFlagsRepository
        self.feeBumpFunctionsProvider = feeBumpFunctionsProvider

        super.init(delegate: delegate)
    }

    func startLoading(origin: Constant.NewOpAnalytics.Origin) {

        let paymentRequestType: Single<PaymentRequestType>
        var isSwap = false

        switch paymentIntent {
        case .toAddress(let uri):
            paymentRequestType = Single.just(FlowToAddress(uri: uri))

        case .submarineSwap(let invoice):
            paymentRequestType = createSubmarineSwap(invoice: invoice, origin: origin)
            isSwap = true

        case .fromHardwareWallet,
             .toHardwareWallet,
             .toContact,
             .lnurlWithdraw:
            preconditionFailure()
        }

        // baseSingle always will be executed, feeDataSyncer.getValue() in loadSingle
        // only will be executed when effectiveFeesCalculation FF is ON.
        let baseSingle: Single<CombinedSingleResult> = Single.zip(feeCalculatorAction.getValue(),
                                                                  paymentRequestType,
                                                                  userSelector.get())
            .map { CombinedSingleResult(feeInfo: $0, paymentRequestType: $1, user: $2) }

        let loadSingle: Single<CombinedSingleResult>
        if shouldLoadFeeData() {
            preloadFeeDataAction.reset()
            loadSingle = preloadFeeDataAction.getValue()
                .flatMap { _ in
                    baseSingle
                }
        } else {
            loadSingle = baseSingle
        }

        subscribeTo(loadSingle) { [weak self] result in
            self?.didLoad(feeInfo: result.feeInfo,
                          paymentRequestType: result.paymentRequestType,
                          user: result.user)
        }

        feeCalculatorAction.run(isSwap: isSwap)

        if shouldLoadFeeData() {
            preloadFeeDataAction.forceRun(refreshPolicy: .newOpBlockingly)
        }
    }

    private func shouldLoadFeeData() -> Bool {
        let isEffectiveFeesCalculationTurnedOn = featureFlagsRepository.fetch()
            .contains(.effectiveFeesCalculation)
        let areFeeBumpFunctionsInvalidated = feeBumpFunctionsProvider.areFeeBumpFunctionsInvalidated()
        return isEffectiveFeesCalculationTurnedOn && areFeeBumpFunctionsInvalidated
    }

    private func createSubmarineSwap(invoice: LibwalletInvoice,
                                     origin: Constant.NewOpAnalytics.Origin) -> Single<PaymentRequestType> {
        submarineSwapAction.run(invoice: invoice.rawInvoice, origin: origin.rawValue)

        return submarineSwapAction.getValue().map({ submarineSwapCreated -> PaymentRequestType in
            return FlowSubmarineSwap(
                invoice: invoice,
                submarineSwapCreated: submarineSwapCreated
            )
        })
    }

    func didLoad(feeInfo: FeeInfo, paymentRequestType: PaymentRequestType, user: User) {
        delegate?.loadingDidFinish(feeInfo: feeInfo,
                                   user: user,
                                   paymentRequestType: paymentRequestType)
    }

    override func handleError(_ e: Error) {
        if let error = e as? Errors {
            switch error {

            case .expiredInvoice:
                DispatchQueue.main.async {
                    self.delegate.expiredInvoice()
                }

            case .invalidAddress:
                DispatchQueue.main.async {
                    self.delegate.invalidAddress()
                }

            case .invoiceMissingAmount:
                DispatchQueue.main.async {
                    self.delegate.invoiceMissingAmount()
                }
            }

        } else if let swapError = swapError(e) {
            delegate.swapError(swapError)
        } else {
            delegate.unexpectedError()
        }
    }

    private func swapError(_ e: Error) -> NewOpError? {
        if e.isKindOf(.invalidInvoice) {
            return .invalidInvoice
        } else if e.isKindOf(.invoiceAlreadyUsed) {
            return .invoiceAlreadyUsed
        } else if e.isKindOf(.invoiceExpiresTooSoon) {
            return .invoiceExpiresTooSoon
        } else if e.isKindOf(.noPaymentRoute) {
            return .noPaymentRoute
        } else if e.isKindOf(.swapFailed) {
            return .swapFailed
        } else if e.isKindOf(.invoiceUnreachableNode) {
            return .invoiceUnreachableNode
        } else if e.isKindOf(.cyclicalSwap) {
            return .cyclicalSwap
        } else if e.isKindOf(.amountLessInvoicesNotSupported) {
            return .invoiceMissingAmount
        }

        return nil
    }

    enum Errors: Error {
        case expiredInvoice
        case invalidAddress
        case invoiceMissingAmount
    }

}
