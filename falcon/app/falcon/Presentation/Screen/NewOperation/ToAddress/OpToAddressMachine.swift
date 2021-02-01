//
//  OpToAddressStateMachine.swift
//  falcon
//
//  Created by Manu Herrera on 07/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import RxSwift
import core

class OpToAddressStateMachine<Delegate: NewOpStateMachineDelegate>: BasePresenter<Delegate>, OpStateMachine {

    private let operationActions: OperationActions

    private var states: [ToAddressState]
    private let initialState: PaymentIntent

    init(delegate: Delegate,
         state: NewOperationConfiguration,
         operationActions: OperationActions) {

        self.initialState = state.paymentIntent
        self.operationActions = operationActions
        self.states = []

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        if states.isEmpty {
            let initialState = ToAddressState.loading(NewOpToAddressData.Loading(type: self.initialState))
            delegate.requestNextStep(initialState, preset: nil)
            states.append(initialState)
        }
    }

    fileprivate func submit(_ operation: core.Operation) {
        subscribeTo(operationActions.newOperation(operation), onSuccess: self.operationCreated)
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
            delegate.operationError()
        }

    }

}

extension OpToAddressStateMachine: NewOperationTransitions {

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
                var preset: MonetaryAmount?
                switch currentState {
                case .confirmation(let data): preset = data.amount.inInputCurrency
                case .description(let data): preset = data.amount.inInputCurrency
                default: preset = nil
                }
                delegate.requestNextStep(ToAddressState.amount(state), preset: preset)

            case .description(let state):
                var preset: String?
                switch currentState {
                case .confirmation(let data): preset = data.description
                default: preset = nil
                }
                delegate.requestNextStep(ToAddressState.description(state), preset: preset)

            case .confirmation:
                // Do nothing since the request is in flight
                break

            case .feeEditor, .currencyPicker:
                // Do nothing since it's impossible to touch the back button in these states
                break
            }

        }
    }

    fileprivate enum ActionNeeded {
        case invalidAddress
        case notEnoughBalance(amountPlusFee: String, totalBalance: String)
        case belowDust
        case expiredInvoice
        case nextState(state: ToAddressState)
    }

    fileprivate func checkRequestData(_ feeInfo: FeeInfo,
                                      _ paymentRequestType: PaymentRequestType,
                                      _ user: User) -> ActionNeeded {

        let feeCalculator = feeInfo.feeCalculator
        let exchangeRateWindow = feeInfo.exchangeRateWindow

        if let amount = paymentRequestType.presetAmount() {

            if amount <= Satoshis(value: 0) {
                // We can't pay negative satoshis
                return .invalidAddress
            }

            if amount < Satoshis.dust {
                return .belowDust
            }

            if !feeCalculator.isAmountPayableWithMinimumFee(amount) {
                return .notEnoughBalance(
                    amountPlusFee: (amount + feeCalculator.calculateMinimumFee()).toBTC().toString(),
                    totalBalance: feeCalculator.totalBalance().toBTC().toString()
                )
            }

            let userPrimaryCurrency = user.primaryCurrencyWithValidExchangeRate(window: exchangeRateWindow)

            let fullAmount = BitcoinAmount.from(inputCurrency: amount.toBTC(),
                                                with: exchangeRateWindow,
                                                primaryCurrency: userPrimaryCurrency)

            if let description = paymentRequestType.presetDescription() {

                let payReq = PaymentRequest(type: paymentRequestType, amount: fullAmount, description: description)
                let feeState = calculateFee(amount: fullAmount, type: payReq.type, feeInfo: feeInfo)

                if case .noPossibleFee = feeState {
                    let amountPlusFee = (amount + feeCalculator.calculateMinimumFee()).toBTC().toString()
                    return .notEnoughBalance(amountPlusFee: amountPlusFee,
                                             totalBalance: feeCalculator.totalBalance().toBTC().toString())

                }

                // If amount is preset we cant take fee from amount
                let data = NewOpToAddressData.Confirm(feeInfo: feeInfo,
                                                      request: payReq,
                                                      feeState: feeState,
                                                      takeFeeFromAmount: false,
                                                      user: user)

                return .nextState(state: ToAddressState.confirmation(data))
            } else {
                // If amount is preset we cant take fee from amount
                let nextState = ToAddressState.description(NewOpToAddressData.Description(feeInfo: feeInfo,
                                                                                           amount: fullAmount,
                                                                                           type: paymentRequestType,
                                                                                           user: user))

                return .nextState(state: nextState)
            }
        } else {
            let nextState = ToAddressState.amount(NewOpToAddressData.Amount(feeInfo: feeInfo,
                                                                             type: paymentRequestType,
                                                                             user: user))
            return .nextState(state: nextState)
        }
    }

    private func calculateFee(amount: BitcoinAmount,
                              type: PaymentRequestType,
                              feeInfo: FeeInfo) -> FeeState {

        let outputAmountInSatoshis = amount.inSatoshis
        let exchangeRateWindow = feeInfo.exchangeRateWindow
        let feeCalculator = feeInfo.feeCalculator

        do {
            let fee = try feeCalculator.feeFor(amount: outputAmountInSatoshis, confirmationTarget: 1)
            return feeState(from: fee, exchangeRateWindow: exchangeRateWindow, amount: amount)
        } catch {
            return .noPossibleFee
        }
    }

    fileprivate func feeState(from result: FeeCalculator.Result,
                              exchangeRateWindow: ExchangeRateWindow,
                              amount: BitcoinAmount) -> FeeState {

        switch result {
        case .valid(let fee, let rate):
            let feeAmount = BitcoinAmount.from(satoshis: fee, with: exchangeRateWindow, mirroring: amount)
            return .finalFee(feeAmount, rate: rate)
        case .invalid(let fee, let rate):
            let feeAmount = BitcoinAmount.from(satoshis: fee, with: exchangeRateWindow, mirroring: amount)
            return .feeNeedsChange(displayFee: feeAmount, rate: rate)
        }
    }

    func getConfirmationData() -> NewOpToAddressData.Confirm {
        switch states.last {
        case .confirmation(let data):
            return data
        default:
            Logger.fatal("No confirmation data")
        }
    }

}

extension OpToAddressStateMachine: OpLoadingTransitions {

    func didLoad(feeInfo: FeeInfo,
                 user: User,
                 paymentRequestType: PaymentRequestType) {

        if let action = checkExpiration(paymentRequestType)
            .orElse(checkRequestData(feeInfo, paymentRequestType, user)) {

            switch action {
            case .invalidAddress:
                delegate.invalidAddress()
            case .notEnoughBalance(let amountPlusFee, let totalBalance):
                delegate.notEnoughBalance(amountPlusFee: amountPlusFee, totalBalance: totalBalance)
            case .belowDust:
                delegate.amountBelowDust()
            case .expiredInvoice:
                delegate.expiredInvoice()
            case .nextState(let state):
                states.append(state)
                delegate.requestNextStep(state, preset: nil)
            }
        }
    }

    func swapError(_ error: NewOpError) {
        fatalError("Got a swap error while not being a swap")
    }

    func invalidAddress() {
        delegate.invalidAddress()
    }

    func expiredInvoice() {
        delegate.expiredInvoice()
    }

    func invoiceMissingAmount() {
        fatalError("Got a swap error while not being a swap")
    }

    func unexpectedError() {
        delegate.unexpectedError()
    }
}

extension OpToAddressStateMachine: OpConfirmTransitions {

    func didConfirm() {

        let operation: core.Operation

        switch states.last {
        case .some(.confirmation(let data)):

            // FIXME: This needs to go
            guard case .finalFee(let fee, _) = data.feeState else {
                Logger.fatal("OMG")
            }

            // FIXME: Fuck this up
            guard let toAddressData = data.type as? FlowToAddress,
                let address = toAddressData.uri.address else {
                Logger.fatal("So much pain")
            }

            operation = BuildOperationAction.toAddress(address,
                                                       amount: data.amount,
                                                       fee: fee,
                                                       description: data.description,
                                                       exchangeRateWindow: data.feeInfo.exchangeRateWindow,
                                                       outpoints: data.feeInfo.feeCalculator.getOutpoints())
        default:
            Logger.fatal("Got confirm with invalid last state")
        }

        guard operation.amount.inSatoshis >= Satoshis.dust else {
            // We cannot pay an amount below dust
            delegate.amountBelowDust()
            return
        }

        delegate.requestFinish(operation)

        submit(operation)
    }
}

extension OpToAddressStateMachine: OpDescriptionTransitions {

    func didEnter(description: String, data: NewOperationStateAmount) {

        let feeState = calculateFee(amount: data.amount,
                                    type: data.type,
                                    feeInfo: data.feeInfo)

        if case .noPossibleFee = feeState {
            let feeCalculator = data.feeInfo.feeCalculator
            let amountPlusFee = (data.amount.inSatoshis + feeCalculator.calculateMinimumFee()).toBTC().toString()
            delegate.notEnoughBalance(amountPlusFee: amountPlusFee,
                                      totalBalance: feeCalculator.totalBalance().toBTC().toString())

            return
        }

        let takeFeeFromAmount = data.feeInfo.feeCalculator.shouldTakeFeeFromAmount(data.amount.inSatoshis)
        let amount: BitcoinAmount

        if takeFeeFromAmount {

            let fee: Satoshis
            switch feeState {
            case .finalFee(let feeAmount, _),
                 .feeNeedsChange(let feeAmount, _):
                fee = feeAmount.inSatoshis
            case .noPossibleFee:
                fatalError("Got no possible fee after checking for it")
            }

            amount = BitcoinAmount.from(satoshis: data.feeInfo.feeCalculator.totalBalance() - fee,
                                        with: data.feeInfo.exchangeRateWindow,
                                        mirroring: data.amount)
        } else {
            amount = data.amount
        }

        let payReq = PaymentRequest(type: data.type,
                                    amount: amount,
                                    description: description)

        let nextState = ToAddressState.confirmation(NewOpToAddressData.Confirm(
            feeInfo: data.feeInfo,
            request: payReq,
            feeState: feeState,
            takeFeeFromAmount: takeFeeFromAmount,
            user: data.user
        ))

        states.append(nextState)
        delegate.requestNextStep(nextState, preset: nil)
    }
}

extension OpToAddressStateMachine: OpAmountTransitions {

    func didEnter(amount: BitcoinAmount, data: NewOperationStateLoaded, takeFeeFromAmount: Bool) {

        guard let data = data as? NewOpToAddressData.Amount else {
            Logger.fatal("Got bad previous state")
        }

        if amount.inSatoshis < Satoshis.dust {
            delegate.amountBelowDust()
            return
        }

        if let description = data.type.presetDescription() {

            let payReq = PaymentRequest(type: data.type,
                                        amount: amount,
                                        description: description)
            let feeState = calculateFee(amount: amount,
                                        type: payReq.type,
                                        feeInfo: data.feeInfo)

            if case .noPossibleFee = feeState {
                let feeCalculator = data.feeInfo.feeCalculator
                let amountPlusFee = (amount.inSatoshis + feeCalculator.calculateMinimumFee()).toBTC().toString()
                delegate.notEnoughBalance(amountPlusFee: amountPlusFee,
                                          totalBalance: feeCalculator.totalBalance().toBTC().toString())

                return
            }

            let nextState = ToAddressState.confirmation(NewOpToAddressData.Confirm(
                feeInfo: data.feeInfo,
                request: payReq,
                feeState: feeState,
                takeFeeFromAmount: takeFeeFromAmount,
                user: data.user
            ))
            states.append(nextState)
            delegate.requestNextStep(nextState, preset: nil)

        } else {

            let nextState = ToAddressState.description(NewOpToAddressData.Description(
                feeInfo: data.feeInfo, amount: amount, type: data.type, user: data.user
            ))

            states.append(nextState)
            delegate.requestNextStep(nextState, preset: nil)
        }
    }

    func requestCurrencyPicker(data: NewOperationStateLoaded, currencyCode: String) {
        guard let data = data as? NewOpToAddressData.Amount else {
            Logger.fatal("Got bad previous state")
        }

        delegate.requestNextStep(ToAddressState.currencyPicker(data), preset: currencyCode)
    }

}

extension OpToAddressStateMachine: SelectFeeDelegate {

    func selected(fee: BitcoinAmount, rate: FeeRate) {

        let data: NewOpToAddressData.Confirm
        switch states.removeLast() {
        case .confirmation(let confirmData):
            data = confirmData
        default:
            Logger.fatal("Found wrong state")
        }

        let nextState: ToAddressState

        if data.takeFeeFromAmount {

            let amount = BitcoinAmount.from(satoshis: data.feeInfo.feeCalculator.totalBalance() - fee.inSatoshis,
                                            with: data.feeInfo.exchangeRateWindow,
                                            mirroring: data.amount)

            let updatedRequest = PaymentRequest(type: data.request.type,
                                                amount: amount,
                                                description: data.request.description)

            nextState = .confirmation(NewOpToAddressData.Confirm(
                feeInfo: data.feeInfo,
                request: updatedRequest,
                feeState: .finalFee(fee, rate: rate),
                takeFeeFromAmount: data.takeFeeFromAmount,
                user: data.user
            ))
        } else {

            nextState = .confirmation(NewOpToAddressData.Confirm(
                feeInfo: data.feeInfo,
                request: data.request,
                feeState: .finalFee(fee, rate: rate),
                takeFeeFromAmount: data.takeFeeFromAmount,
                user: data.user
            ))
        }

        states.append(nextState)
        delegate.requestNextStep(nextState, preset: nil)
    }

}

extension OpToAddressStateMachine: NewOpFilledAmountTransitions {

    func requestFeeEditor() {

        let data: NewOpToAddressData.Confirm
        switch states.last {
        case .some(.confirmation(let confirmData)):
            data = confirmData
        default:
            Logger.fatal("Found wrong state")
        }

        let calculateFee: FeeEditor.CalculateFee = { rate in
            do {
                var amount = data.amount.inSatoshis
                if data.takeFeeFromAmount {
                    // If the operation is taking the fee from the amount it means the user is trying to send all funds.
                    // In this case we need to calculate the fee for the total balance.
                    amount = data.feeInfo.feeCalculator.totalBalance()
                }
                let feeResult = try data.feeInfo.feeCalculator.feeFor(amount: amount, rate: rate)

                return self.feeState(from: feeResult,
                                     exchangeRateWindow: data.feeInfo.exchangeRateWindow,
                                     amount: data.amount)
            } catch {
                return .noPossibleFee
            }
        }

        delegate.requestNextStep(ToAddressState.feeEditor(data, calculateFee: calculateFee),
                                 preset: nil)
    }

}
