//
//  OpSubmarineSwapMachine.swift
//  falcon
//
//  Created by Manu Herrera on 07/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import RxSwift
import core

class OpSubmarineSwapMachine<Delegate: NewOpStateMachineDelegate>: BasePresenter<Delegate>, OpStateMachine {

    private let operationActions: OperationActions
    private let computeSwapFeesAction: ComputeSwapFeesAction

    private var states: [SubmarineSwapState]
    private let initialState: PaymentIntent

    init(delegate: Delegate,
         state: NewOperationConfiguration,
         operationActions: OperationActions,
         computeSwapFeesAction: ComputeSwapFeesAction) {

        self.initialState = state.paymentIntent
        self.operationActions = operationActions
        self.computeSwapFeesAction = computeSwapFeesAction
        self.states = []

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        if states.isEmpty {
            let initialState = SubmarineSwapState.loading(NewOpSubmarineSwapData.Loading(type: self.initialState))
            delegate.requestNextStep(initialState, preset: nil)
            states.append(initialState)
        }
    }

    fileprivate func submit(_ operation: core.Operation, with parameters: SwapExecutionParameters) {
        subscribeTo(operationActions.newOperation(operation, with: parameters), onSuccess: self.operationCreated)
    }

    func operationCreated(op: core.Operation) {
        delegate.operationCompleted(op)
    }

    private func checkExpiration(_ paymentRequestType: PaymentRequestType) -> ActionNeeded? {
        if let expiresTime = paymentRequestType.expiresTime() {
            let timeLeft = expiresTime - Date().timeIntervalSince1970
            if timeLeft > 0 {
                delegate.setExpires(expiresTime)
            } else {
                return .expiredInvoice
            }
        }

        return nil
    }

    override func handleError(_ e: Error) {

        if e.isKindOf(.exchangeRateWindowTooOld) {
            delegate.showExchangeRateWindowTooOldError()
        } else {
            super.handleError(e)
            delegate.operationError()
        }

    }

}

extension OpSubmarineSwapMachine: NewOperationTransitions {

    func back() {

        if states.count == 1 {
            delegate?.cancel()
        } else if let currentState = states.popLast(),
            let previousState = states.last {

            switch previousState {
            case .loading:
                delegate?.cancel()
                states.append(currentState)

            case .amount(let state):
                var preset: BitcoinAmount?
                switch currentState {
                case .description(let data):
                    preset = data.amount
                case .confirmation(let data):
                    preset = data.amount
                default:
                    preset = nil
                }
                delegate.requestNextStep(SubmarineSwapState.amount(state), preset: preset)

            case .description(let state):
                var preset: String?
                switch currentState {
                case .confirmation(let data): preset = data.description
                default: preset = nil
                }
                delegate.requestNextStep(SubmarineSwapState.description(state), preset: preset)

            case .confirmation:
                // Do nothing since the request is in flight
                break

            case .currencyPicker:
                // Do nothing since it's impossible to touch the back button in these states
                break
            }
        }
    }

    fileprivate enum ActionNeeded {
        case expiredInvoice
        case invalidAddress
        case notEnoughBalance(amountPlusFee: String, totalBalance: String)
        case nextState(state: SubmarineSwapState)
    }

    fileprivate func stepAfterAmount(amount: BitcoinAmount,
                                     flow: FlowSubmarineSwap,
                                     feeInfo: FeeInfo,
                                     user: User) -> ActionNeeded {

        let swap = flow.submarineSwap

        let swapParams = computeSwapFeesAction.run(swap: swap, amount: amount.inSatoshis, feeInfo: feeInfo)
        switch swapParams {
        case .valid(let params, let totalFee, let feeRate, let updatedAmount):
            let feeAmount = BitcoinAmount.from(satoshis: totalFee, with: feeInfo.exchangeRateWindow, mirroring: amount)
            let feeState = FeeState.finalFee(feeAmount, rate: feeRate)
            let amount = BitcoinAmount.from(satoshis: updatedAmount,
                                            with: feeInfo.exchangeRateWindow,
                                            mirroring: amount)

            if let description = flow.presetDescription() {

                let payReq = PaymentRequest(type: flow, amount: amount, description: description)

                // If amount is preset we cant take fee from amount
                let nextState = SubmarineSwapState.confirmation(NewOpSubmarineSwapData.Confirm(
                    feeInfo: feeInfo,
                    user: user,
                    request: payReq,
                    fee: feeAmount,
                    feeState: feeState,
                    params: params
                ))
                return .nextState(state: nextState)

            } else {
                let nextState = SubmarineSwapState.description(
                    NewOpSubmarineSwapData.Description(
                        feeInfo: feeInfo,
                        user: user,
                        amount: amount,
                        flow: flow,
                        fee: feeAmount,
                        feeState: feeState,
                        params: params
                    )
                )

                return .nextState(state: nextState)
            }
        case .invalid(let amountPlusFee):
            let totalBalance = feeInfo.feeCalculator.totalBalance()
            return .notEnoughBalance(amountPlusFee: amountPlusFee.toBTC().toString(),
                                     totalBalance: totalBalance.toBTC().toString())
        }
    }

    fileprivate func checkRequestData(_ feeInfo: FeeInfo,
                                      _ flow: FlowSubmarineSwap,
                                      _ user: User) -> ActionNeeded {

        if let amount = flow.presetAmount() {

            if amount <= Satoshis(value: 0) {
                // We can't pay negative satoshis
                return .invalidAddress
            }

            let userPrimaryCurrency = user.primaryCurrencyWithValidExchangeRate(window: feeInfo.exchangeRateWindow)

            let invoiceAmount = BitcoinAmount.from(inputCurrency: amount.toBTC(),
                                                   with: feeInfo.exchangeRateWindow,
                                                   primaryCurrency: userPrimaryCurrency)

            return stepAfterAmount(amount: invoiceAmount,
                                   flow: flow,
                                   feeInfo: feeInfo,
                                   user: user)

        } else {

            // The invoice doesn't have a set amount
            let nextState = SubmarineSwapState.amount(
                NewOpSubmarineSwapData.Amount(feeInfo: feeInfo, user: user, flow: flow)
            )

            return .nextState(state: nextState)
        }
    }

    func getConfirmationData() -> NewOpSubmarineSwapData.Confirm {
        switch states.last {
        case .confirmation(let data):
            return data
        default:
            Logger.fatal("No confirmation data")
        }
    }

}

extension OpSubmarineSwapMachine: OpLoadingTransitions {

    func didLoad(feeInfo: FeeInfo,
                 user: User,
                 paymentRequestType: PaymentRequestType) {

        guard let swapFlow = paymentRequestType as? FlowSubmarineSwap else {
            Logger.fatal("Not swap flow")
        }

        let action = checkExpiration(paymentRequestType)
            .orElse(checkRequestData(feeInfo, swapFlow, user))

        switch action {
        case .invalidAddress:
            delegate.invalidAddress()
        case .notEnoughBalance(let amountPlusFee, let totalBalance):
            delegate.notEnoughBalance(amountPlusFee: amountPlusFee, totalBalance: totalBalance)
        case .expiredInvoice:
            delegate.expiredInvoice()
        case .nextState(let state):
            states.append(state)
            delegate.requestNextStep(state, preset: nil)
        case .none:
            Logger.log(.warn, "Next action = 'none' in opSwapDidLoad")
        }
    }

    func swapError(_ error: NewOpError) {
        delegate.swapError(error)
    }

    func invalidAddress() {
        delegate.invalidAddress()
    }

    func expiredInvoice() {
        delegate.expiredInvoice()
    }

    func invoiceMissingAmount() {
        delegate.invoiceMissingAmount()
    }

    func unexpectedError() {
        delegate.unexpectedError()
    }
}

extension OpSubmarineSwapMachine: OpConfirmTransitions {

    func didConfirm() {

        let operation: core.Operation
        let parameters: SwapExecutionParameters
        switch states.last {
        case .some(.confirmation(let data)):

            // FIXME: This is wrong
            let swap = data.getFlowData().submarineSwap
            parameters = data.params

            operation = BuildOperationAction.swap(swap,
                                                  amount: data.amount,
                                                  fee: data.fee,
                                                  description: data.description,
                                                  exchangeRateWindow: data.feeInfo.exchangeRateWindow,
                                                  outpoints: data.feeInfo.feeCalculator.getOutpoints())
        default:
            Logger.fatal("Found invalid last state")
        }

        delegate.requestFinish(operation)

        submit(operation, with: parameters)
    }
}

extension OpSubmarineSwapMachine: OpDescriptionTransitions {
    func didEnter(description: String, data: NewOperationStateAmount) {

        let payReq = PaymentRequest(type: data.type,
                                    amount: data.amount,
                                    description: description)
        guard let data = data as? NewOpSubmarineSwapData.Description else {
            Logger.fatal("Not swap flow")
        }

        let nextState = SubmarineSwapState.confirmation(
            NewOpSubmarineSwapData.Confirm(feeInfo: data.feeInfo,
                                           user: data.user,
                                           request: payReq,
                                           fee: data.fee,
                                           feeState: data.feeState,
                                           params: data.params)
        )

        states.append(nextState)
        delegate.requestNextStep(nextState, preset: nil)

    }
}

extension OpSubmarineSwapMachine: OpAmountTransitions {

    func didEnter(amount: BitcoinAmount, data: NewOperationStateLoaded, takeFeeFromAmount: Bool) {

        guard let data = data as? NewOpSubmarineSwapData.Amount else {
            Logger.fatal("Got invalid previous data")
        }

        let action = stepAfterAmount(amount: amount,
                                     flow: data.flow,
                                     feeInfo: data.feeInfo,
                                     user: data.user)

        switch action {
        case .expiredInvoice, .invalidAddress:
            Logger.fatal("Can't get to this state, didEnter \(amount.inSatoshis) in expired invoice or invalidAddress")
        case .notEnoughBalance(let amountPlusFee, let totalBalance):
            delegate.notEnoughBalance(amountPlusFee: amountPlusFee, totalBalance: totalBalance)
        case .nextState(let state):
            states.append(state)
            delegate.requestNextStep(state, preset: nil)
        }

    }

    func requestCurrencyPicker(data: NewOperationStateLoaded, currencyCode: String) {

        guard let data = data as? NewOpSubmarineSwapData.Amount else {
            fatalError("Got invalid previous data")
        }

        delegate.requestNextStep(SubmarineSwapState.currencyPicker(data), preset: currencyCode)
    }
}
