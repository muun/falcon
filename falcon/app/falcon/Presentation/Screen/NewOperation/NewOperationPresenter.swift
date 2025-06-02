//
//  NewOperationPresenter.swift
//  falcon
//
//  Created by Federico Bond on 06/07/2021.
//  Copyright © 2021 muun. All rights reserved.
//

// swiftlint:disable force_try

import Foundation

import Libwallet
import RxSwift

protocol NewOperationPresenterDelegate: BasePresenterDelegate {
    func requestNextStep(_ data: NewOpState)
    func requestFinish(_ operation: Operation)
    func updateStep(_ data: NewOpState)

    func operationCompleted(_ operation: Operation)

    // Errors
    func operationError()
    func showExchangeRateWindowTooOldError()
    func showSwapFailedError()
    func notEnoughBalance(amountPlusFee: MonetaryAmount, totalBalance: MonetaryAmount)
    func expiredInvoice()
    func invalidAddress()
    func swapError(_ error: NewOpError)
    func amountBelowDust()
    func invoiceMissingAmount()
    func unexpectedError()
    func nfc2faError()

    func setExpires(_ expiresTime: Double)
    func cancel(confirm: Bool)
}

// swiftlint:disable type_body_length
/// This class acts as new operations coordinator.
/// It asks libWallet to validate each state of the operation and presents screens in order to complete an operation.
class NewOperationPresenter<Delegate: NewOperationPresenterDelegate>: BasePresenter<Delegate> {

    let operationActions: OperationActions

    let stateMachine = NewOperationStateMachine()

    var submarineSwapCreated: SubmarineSwapCreated? // TODO(newop): can we remove this hack somehow?

    /// Go to: [BitcoinAmountWithSelectedCurrency](x-source-tag://BitcoinAmountWithSelectedCurrency)
    var lastSelectedCurrency: Currency?

    var hasNfc2fa: Bool {
        userRepository.isCardActivated()
    }

    private let userRepository: UserRepository = resolve()
    private let featureFlagsRepository: FeatureFlagsRepository = resolve()
    private let signMessageAction: SignMessageAction = SignMessageAction()
    private let disposeBag = DisposeBag()

    init(delegate: Delegate, operationActions: OperationActions) {
        self.operationActions = operationActions
        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()
        subscribeTo(stateMachine.asObservable(), onNext: self.onStateChanged)
    }

    func start(uri: String) {
        do {
            try stateMachine.withState { (state: NewopStartState) in
                try state.resolve(uri, network: Environment.current.network)
            }
        } catch {
            Logger.fatal(error: error)
        }
    }

    func start(invoice: LibwalletInvoice) {
        do {
            try stateMachine.withState { (state: NewopStartState) in
                try state.resolve(invoice, network: Environment.current.network)
            }
        } catch {
            Logger.fatal(error: error)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    func onStateChanged(_ state: NewopStateProtocol) {
        // this is a dismiss from an abort dialog, so we can do nothing
        if state.getUpdate() == NewopUpdateEmpty {
            return
        }

        switch state {
        case _ as NewopStartState:
            break // do nothing

        case let state as NewopResolveState:
            handleResolveState(state)

        case let state as NewopEnterAmountState:
            handleEnterAmountState(state)

        case let state as NewopEnterDescriptionState:
            handleEnterDescriptionState(state)

        case let state as NewopValidateState:
            handleValidateState(state)

        case let state as NewopValidateLightningState:
            handleValidateLightningState(state)

        case let state as NewopConfirmState:
            handleConfirmState(state)

        case let state as NewopConfirmLightningState:
            handleConfirmLightningState(state)

        case let state as NewopEditFeeState:
            handleEditFeeState(state)

        case let state as NewopErrorState:
            handleErrorState(state)

        case let state as NewopBalanceErrorState:
            handleBalanceErrorState(state)

        case let state as NewopAbortState:
            handleAbortState(state)

        default:
            Logger.fatal("unrecognized new operation state: \(state)")
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func handleResolveState(_ state: NewopResolveState) {
        let paymentIntent = state.paymentIntent!.adapt()

        switch paymentIntent {
        case .submarineSwap(let invoice):
            delegate.setExpires(Double(invoice.expiry))

        case .fromHardwareWallet,
             .toContact,
             .toHardwareWallet,
             .lnurlWithdraw,
             .toAddress:
                () // Nothing extra to do
        }

        let newOpState = NewOpState.loading(NewOpData.Loading(type: paymentIntent))

        delegate.requestNextStep(newOpState)
    }

    private func handleEnterAmountState(_ state: NewopEnterAmountState) {
        let type = createPaymentRequestType(state.resolved!.paymentIntent!)
        let primaryCurrency = state.resolved!.paymentContext!.primaryCurrency
        let totalBalance = state.totalBalance!.adapt()
        loadLastSelectedCurrencyIfNeeded(totalBalance)
        let amount = state.amount!.adapt()
        let newOpState = NewOpState.amount(
            NewOpData.Amount(
                type: type,
                amount: amount,
                primaryCurrency: primaryCurrency,
                selectedCurrency: lastSelectedCurrency!,
                totalBalance: totalBalance,
                exchangeRateWindow: state.resolved!.paymentContext!.exchangeRateWindow!
            ))

        if state.getUpdate() == NewopUpdateInPlace {

            delegate.updateStep(newOpState)
        } else {

            delegate.requestNextStep(newOpState)
        }
    }

    private func handleEnterDescriptionState(_ state: NewopEnterDescriptionState) {
        let amount = state.amountInfo!.amount!.adapt()
        let type = createPaymentRequestType(state.resolved!.paymentIntent!)
        let primaryCurrency = state.resolved!.paymentContext!.primaryCurrency
        let totalBalance = state.amountInfo!.totalBalance!.adapt()
        loadLastSelectedCurrencyIfNeeded(totalBalance)
        let newOpState = NewOpState.description(
            NewOpData.Description(
                amount: BitcoinAmountWithSelectedCurrency(bitcoinAmount: amount,
                                                          selectedCurrency: lastSelectedCurrency!),
                description: state.note,
                type: type,
                primaryCurrency: primaryCurrency,
                totalBalance: totalBalance,
                isOneConf: state.validated?.swapInfo?.isOneConf ?? false,
                exchangeRateWindow: state.resolved!.paymentContext!.exchangeRateWindow!
            ))

        delegate.requestNextStep(newOpState)
    }

    private func handleValidateState(_ state: NewopValidateState) {
        do {
            try state.continue()
        } catch {
            Logger.fatal(error: error)
        }
    }

    private func handleValidateLightningState(_ state: NewopValidateLightningState) {
        do {
            try state.continue()
        } catch {
            Logger.fatal(error: error)
        }
    }

    private func handleConfirmState(_ state: NewopConfirmState) {
        handleConfirmState(ConfirmStateViewModel.fromConfirm(state: state))
    }

    // This flow can be executed from both lightning and bitcoin.
    private func handleConfirmState(_ state: ConfirmStateViewModel) {
        let type = createPaymentRequestType(state.paymentIntent)
        let amount = state.getAmount(lastSelectedCurrency: lastSelectedCurrency)
        let total = state.total
        let totalBalance = state.totalBalance
        let feeState = state.feeState
        let minMempoolFeeRate = state.minMempoolFeeRate

        // If the URI has a message the flow will come right to this state
        loadLastSelectedCurrencyIfNeeded(totalBalance)

        let newOpState = NewOpState.confirmation(
            NewOpData.Confirm(
                type: type,
                amount: amount,
                total: total,
                description: state.note,
                feeState: feeState,
                takeFeeFromAmount: state.takeFeeFromAmount,
                primaryCurrency: state.primaryCurrency,
                totalBalance: totalBalance,
                onchainFee: state.onchainFee,
                feeNeedsChange: state.feeNeedsChange,
                routingFeeInSat: state.routingFeesInSats,
                confirmationsNeeded: state.confirmationsNeeded,
                debtAmountInSat: state.debtAmountInSat,
                outputAmountInSat: state.outputAmountInSat,
                outputPaddingInSat: state.outputPaddingInSat,
                isOneConf: state.isOneConf,
                debtType: state.debtType,
                exchangeRateWindow: state.exchangeRateWindow,
                feeWindow: state.feeWindow,
                minMempoolFeeRate: minMempoolFeeRate
            )
        )

        delegate.requestNextStep(newOpState)
    }

    private func handleConfirmLightningState(_ state: NewopConfirmLightningState) {
        handleConfirmState(ConfirmStateViewModel.fromConfirmLightning(state: state))
    }

    func handleEditFeeState(_ state: NewopEditFeeState) {
        let type = createPaymentRequestType(state.resolved!.paymentIntent!)

        let calculateFee = { (rate: FeeRate) -> NewopFeeState in
            let feeRate = Double((rate.satsPerVByte as NSDecimalNumber).doubleValue)
            // TODO currently forgets input currency, which is important for amount display
            return try! state.calculateFee(feeRate)
        }

        let minFeeRate: (UInt) -> FeeRate = { target in
            var feeRate: Double = 0
            try! state.minFeeRate(forTarget: Int(target), ret0_: &feeRate)
            return FeeRate(satsPerVByte: Decimal(feeRate))
        }

        let feeRate = FeeRate(satsPerVByte: Decimal(state.amountInfo!.feeRateInSatsPerVByte))

        let feeState: FeeState
        if state.validated!.feeNeedsChange {
            feeState = .feeNeedsChange(displayFee: state.validated!.fee!.adapt(), rate: feeRate)
        } else {
            feeState = .finalFee(state.validated!.fee!.adapt(),
                                 rate: feeRate,
                                 feeBumpInfo: state.validated?.feeBumpInfo?.adapt())
        }

        let primaryCurrency = state.resolved!.paymentContext!.primaryCurrency
        let totalBalance = state.amountInfo!.totalBalance!.adapt()
        let satsPerByte = Decimal(state.resolved!.paymentContext!.minFeeRateInSatsPerVByte)
        let selectedCurrency = getLastSelectedCurrencyWithBitcoinDefaultInCaseOfBitcoin()
        let newOpState = NewOpState.feeEditor(
            NewOpData.FeeEditor(
                type: type,
                amount: BitcoinAmountWithSelectedCurrency(bitcoinAmount: state.amountInfo!.amount!.adapt(),
                                                          selectedCurrency: selectedCurrency),
                total: state.validated!.total!.adapt(),
                feeState: feeState,
                takeFeeFromAmount: state.amountInfo!.takeFeeFromAmount,
                primaryCurrency: primaryCurrency,
                totalBalance: totalBalance,
                feeWindow: state.resolved!.paymentContext!.feeWindow!,
                minMempoolFeeRate: FeeRate(satsPerVByte: satsPerByte),
                calculateFee: calculateFee,
                minFeeRate: minFeeRate
            )
        )

        delegate.requestNextStep(newOpState)
    }

    /// Fee screens should not use bitcoin selected unit on contex.
    private func getLastSelectedCurrencyWithBitcoinDefaultInCaseOfBitcoin() -> Currency {
        if self.lastSelectedCurrency is BitcoinCurrency {
            return BitcoinCurrency() // Bitcoin unit by default on a BitcoinCurrency comes from userDefaults
        }
        return lastSelectedCurrency!
    }

    private func handleErrorState(_ state: NewopErrorState) {
        switch state.error {
        case NewopOperationErrorAmountTooSmall:
            delegate.amountBelowDust()
        case NewopOperationErrorInvoiceExpired:
            delegate.expiredInvoice()
        case NewopOperationErrorInvalidAddress:
            delegate.invalidAddress()
        default:
            Logger.fatal("unhandled error state: \(state.error)")
        }
    }

    private func handleBalanceErrorState(_ state: NewopBalanceErrorState) {
        switch state.error {
        case NewopOperationErrorUnpayable, NewopOperationErrorAmountGreaterThanBalance:
            let amountPlusFee = state.totalAmount!.adapt()
            let totalBalance = state.balance!.adapt()
            delegate.notEnoughBalance(amountPlusFee: amountPlusFee, totalBalance: totalBalance)
        default:
            Logger.fatal("unhandled error state: \(state.error)")
        }
    }

    private func handleAbortState(_ state: NewopAbortState) {
        delegate.cancel(confirm: true)
    }

    fileprivate func createOperation() {

        do {
            try stateMachine.withState { (state: NewopConfirmState) in
                createOpToAddress(state: state)
            }
            try stateMachine.withState { (state: NewopConfirmLightningState) in
                createOpSubmarineSwap(state: state)
            }
        } catch {
            Logger.fatal(error: error)
        }

    }

    private func createOpToAddress(state: NewopConfirmState) {

        // TODO(newop): libwallet make it easy to extract address from this
        let address = state.resolved!.paymentIntent!.uri!.address

        let exchangeRateWindow = state.resolved!.paymentContext!.exchangeRateWindow!

        // TODO(newop): careful what happens when this is empty, read something about
        // returning nil when one of the outpoints is empty
        let outpoints: [String] = state.resolved!.paymentContext!.nextTransactionSize!
            .getOutpoints().split(separator: "\n").map { String($0) }

        let operation = BuildOperationAction.toAddress(
            address,
            amount: state.amountInfo!.amount!.adapt(),
            fee: state.validated!.fee!.adapt(),
            description: state.note,
            exchangeRateWindow: exchangeRateWindow,
            outpoints: outpoints
        )

        guard operation.amount.inSatoshis >= Satoshis.dust else {
            // We cannot pay an amount below dust
            delegate.amountBelowDust()
            return
        }

        delegate.requestFinish(operation)

        subscribeTo(operationActions.newOperation(operation), onSuccess: self.operationCreated)
    }

    private func createOpSubmarineSwap(state: NewopConfirmLightningState) {

        let exchangeRateWindow = state.resolved!.paymentContext!.exchangeRateWindow!

        // TODO(newop): careful what happens when this is empty, read something about
        // returning nil when one of the outpoints is empty
        let outpoints: [String] = state.resolved!.paymentContext!.nextTransactionSize!
            .getOutpoints().split(separator: "\n").map { String($0) }

        let operation = BuildOperationAction.swap(
            submarineSwapCreated!.swap,
            amount: state.amountInfo!.amount!.adapt(),
            fee: state.validated!.swapInfo!.onchainFee!.adapt(),
            description: state.note,
            exchangeRateWindow: exchangeRateWindow,
            outpoints: outpoints
        )

        let params = state.validated!.swapInfo!.swapFees!.adapt()
        let maxAlternativeTransactionCount = submarineSwapCreated!.maxAlternativeTransactionCount

        submarineSwapCreated = nil

        delegate.requestFinish(operation)

        subscribeTo(
            operationActions.newOperation(operation,
                                          with: params,
                                          maxAlternativeTransactionCount: maxAlternativeTransactionCount),
            onSuccess: self.operationCreated
        )
    }

    private func operationCreated(_ operation: Operation) {
        delegate.operationCompleted(operation)
    }

    func cancelAbort() {
        try! stateMachine.withState { (state: NewopAbortState) in
            state.cancel()
        }
    }

    override func handleError(_ e: Error) {
        if e.isKindOf(.exchangeRateWindowTooOld) {
            delegate.showExchangeRateWindowTooOldError()
        } else if e.isKindOf(.swapFailed) {
            delegate.showSwapFailedError()
        } else {
            super.handleError(e)
            delegate.operationError()
        }
    }

    private func createPaymentRequestType(_ intent: NewopPaymentIntent) -> PaymentRequestType {
        switch intent.adapt() {
        case .toAddress(let uri):
            return FlowToAddress(uri: uri)
        case .submarineSwap(let invoice):
            return FlowSubmarineSwap(invoice: invoice, submarineSwapCreated: submarineSwapCreated!)
        default:
            Logger.fatal("Could not produce a valid PaymentRequestType: \(intent)")
        }
    }
}

extension NewOperationPresenter: NewOperationTransitions {
    func back() {
        try! stateMachine.withState({ (state: NewopStateProtocol) in
            switch state {
            case _ as NewopResolveState,
                 _ as NewopStartState:
                // BIP70 and invoices need a request before transitioning out of start and resolve, respectively.
                // Allow the user abort the flow during the resulting spinner
                delegate.cancel(confirm: false)
            case let state as NewopConfirmState:
                try state.back()
            case let state as NewopConfirmLightningState:
                try state.back()
            case let state as NewopEnterDescriptionState:
                try state.back()
            case let state as NewopEnterAmountState:
                try state.back()
            default:
                Logger.fatal("attempted back in state which does not support it: \(state)")
            }
        })
    }

    private func loadLastSelectedCurrencyIfNeeded(_ totalBalance: BitcoinAmount) {
        if lastSelectedCurrency == nil {
            let primaryCurrency = totalBalance.inPrimaryCurrency.currency
            lastSelectedCurrency = GetCurrencyForCode().runAssumingCrashPosibility(code: primaryCurrency)
        }
    }
}

extension NewOperationPresenter: OpLoadingTransitions {
    func didLoad(feeInfo: FeeInfo, user: User, paymentRequestType: PaymentRequestType) {

        let context = NewopInitialPaymentContext()
        context.feeWindow = feeInfo.feeWindow.toLibwallet()
        context.nextTransactionSize = feeInfo.nextTransactionSize.toLibwallet()
        context.exchangeRateWindow = feeInfo.exchangeRateWindow.toLibwallet()
        context.primaryCurrency = user.primaryCurrencyWithValidExchangeRate(window: feeInfo.exchangeRateWindow)
        context.minFeeRateInSatsPerVByte = feeInfo.minFeeRateInSatsPerVByte

        if let flowSwap = paymentRequestType as? FlowSubmarineSwap {
            submarineSwapCreated = flowSwap.submarineSwapCreated
            context.submarineSwap = flowSwap.submarineSwapCreated.swap.toLibwallet()
        }

        try! stateMachine.withState { (state: NewopResolveState) in
            try state.setContext(context)
        }
    }

    func expiredInvoice() {
        delegate.expiredInvoice()
    }

    func invalidAddress() {
        delegate.invalidAddress()
    }

    func swapError(_ error: NewOpError) {
        delegate.swapError(error)
    }

    func unexpectedError() {
        delegate.unexpectedError()
    }

    func invoiceMissingAmount() {
        delegate.invoiceMissingAmount()
    }

}

extension NewOperationPresenter: OpConfirmTransitions {
    func didConfirm() {
        if hasNfc2fa
            && featureFlagsRepository.fetch().contains(.nfcCard) {
            let message = "testing NFC in iOS"
            signMessageAction.run(message: message, slot: 0)
                .subscribe(onSuccess: { signedMessage in
                    guard let signedMessage else {
                        self.delegate.nfc2faError()
                        return
                    }
                    Logger.log(.debug, "Card signed message response: \(signedMessage)")

                    // if signed was successful, continue with the operation.
                    // we will check the signed message in Libwallet in the final implementation
                    self.createOperation()

                }, onError: { _ in
                    self.delegate.nfc2faError()
                }).disposed(by: disposeBag)
        } else {
            createOperation()
        }
    }
}

extension NewOperationPresenter: OpAmountTransitions {

    func didEnter(amount: BitcoinAmount, data: NewOperationStateLoaded, takeFeeFromAmount: Bool) {

        try! stateMachine.withState { (state: NewopEnterAmountState) in
            let monetaryAmount = amount.inInputCurrency.toLibwallet()
            try state.enterAmount(monetaryAmount, takeFeeFromAmount: takeFeeFromAmount)
        }
    }

    func requestCurrencyPicker(data: NewOperationStateLoaded, currency: Currency) {

        try! stateMachine.withState({ (state: NewopEnterAmountState) in
            let type = createPaymentRequestType(state.resolved!.paymentIntent!)
            let primaryCurrency = state.resolved!.paymentContext!.primaryCurrency
            let totalBalance = state.totalBalance!.adapt()
            loadLastSelectedCurrencyIfNeeded(totalBalance)

            let newOpState = NewOpState.currencyPicker(
                NewOpData.Amount(
                    type: type,
                    amount: state.amount!.adapt(),
                    primaryCurrency: primaryCurrency,
                    selectedCurrency: lastSelectedCurrency!,
                    totalBalance: totalBalance,
                    exchangeRateWindow: state.resolved!.paymentContext!.exchangeRateWindow!
                ),
                selectedCurrency: currency
            )

            delegate.requestNextStep(newOpState)

        })
    }

    func changeCurrency(_ currency: Currency) {
        lastSelectedCurrency = currency
        try! stateMachine.withState { (state: NewopEnterAmountState) in
            try state.changeCurrency(currency.code)
        }
    }

}

extension NewOperationPresenter: OpDescriptionTransitions {
    func didEnter(description: String, data: NewOperationStateAmount) {
        try! stateMachine.withState { (state: NewopEnterDescriptionState) in
            try state.enterDescription(description)
        }
    }

}

extension NewOperationPresenter: SelectFeeDelegate {
    func selected(fee: BitcoinAmount, rate: FeeRate) {

        try! stateMachine.withState { (state: NewopEditFeeState) in
            let rateInSatsPerVByte = (rate.satsPerVByte as NSDecimalNumber).doubleValue
            try state.setFeeRate(rateInSatsPerVByte)
        }
    }

    func cancel() {
        try! stateMachine.withState { (state: NewopEditFeeState) in
            try state.closeEditor()
        }
    }
}

extension NewOperationPresenter: NewOpFilledAmountTransitions {
    func requestFeeEditor() {

        try! stateMachine.withState { (state: NewopConfirmState) in
            try state.openFeeEditor()
        }
    }

}

extension NewopPaymentIntent {

    func adapt() -> PaymentIntent {
        // TODO(newop): cleanup logic
        if let invoice = uri!.invoice {
            return try! AddressHelper.parse(invoice.rawInvoice)
        }
        return .toAddress(uri: uri!.adapt())
    }

}

extension NewopFeeState {

    // TODO(newop): remove
    func adapt() -> FeeState {
        switch state {
        case NewopFeeStateFinalFee:

            return .finalFee(amount!.adapt(),
                             rate: FeeRate(satsPerVByte: Decimal(rateInSatsPerVByte)),
                             feeBumpInfo: feeBumpInfo?.adapt())
        case NewopFeeStateNeedsChange:
            return .feeNeedsChange(
                displayFee: amount!.adapt(),
                rate: FeeRate(satsPerVByte: Decimal(rateInSatsPerVByte))
            )
        case NewopFeeStateNoPossibleFee:
            return .noPossibleFee
        default:
            Logger.fatal("unrecognized fee state: \(state)")
        }
    }
}
