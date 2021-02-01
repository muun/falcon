//
//  OpSubmarineSwapViewBuilder.swift
//  falcon
//
//  Created by Juan Pablo Civile on 01/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

class OpSubmarineSwapViewBuilder: OpViewBuilder {

    typealias Transitions =
        NewOperationTransitions
        & OpLoadingTransitions
        & OpConfirmTransitions
        & OpDescriptionTransitions
        & OpAmountTransitions

    typealias AmountDelegate =
        NewOpFilledAmountDelegate
        & CurrencyPickerDelegate

    weak var transitionDelegate: Transitions?
    weak var newOpViewDelegate: NewOpViewDelegate?
    weak var filledDataDelegate: NewOperationView.FilledDataDelegate?
    weak var amountDelegate: AmountDelegate?

    private var params: [String: Any] = [:]

    init(transitionDelegate: Transitions,
         newOpViewDelegate: NewOpViewDelegate,
         filledDataDelegate: NewOperationView.FilledDataDelegate,
         amountDelegate: AmountDelegate?) {
        self.transitionDelegate = transitionDelegate
        self.newOpViewDelegate = newOpViewDelegate
        self.filledDataDelegate = filledDataDelegate
        self.amountDelegate = amountDelegate
    }

    func getNextStep(state: NewOpState, preset: Any? = nil) -> NewOpNextStep {

        let currentState = checkFlow(state: state)

        switch currentState {

        case .loading(let data):
            return .view(NewOpLoadingView(paymentIntent: data.type, delegate: transitionDelegate), filledData: [])

        case .amount(let data):
            let view = NewOpAmountView(data: data,
                                       delegate: newOpViewDelegate,
                                       transitionsDelegate: transitionDelegate,
                                       preset: preset as? MonetaryAmount)

            return .view(view, filledData: [
                buildDestination(type: data.type)
            ])

        case .description(let data):
            // This is the first time where we can know the debt type
            addDebtTypeParam(swapParams: data.params)

            let descriptionView = NewOpDescriptionView(data: data,
                                                       delegate: newOpViewDelegate,
                                                       transitionsDelegate: transitionDelegate,
                                                       preset: preset as? String)
            return .view(descriptionView, filledData: [
                buildDestination(type: data.type),
                buildAmountView(data.amount)
            ])

        case .confirmation(let data):
            let view = NewOpConfirmView(feeState: data.feeState,
                                        delegate: newOpViewDelegate,
                                        transitionDelegate: transitionDelegate)
            view.validityCheck()

            var filledData = [
                buildDestination(type: data.type, confirm: true),
                buildAmountView(data.amount, confirm: true)
            ]
            filledData.append(contentsOf: getFeeViews(data: data))
            filledData.append(contentsOf: [
                buildTotalView(data),
                NewOpDescriptionFilledDataView(descriptionText: data.description)
            ])
            return .view(view, filledData: filledData)

        case .currencyPicker(let data):

            let currencyPicker = CurrencyPickerViewController(exchangeRateWindow: data.feeInfo.exchangeRateWindow,
                                                              delegate: amountDelegate)
            currencyPicker.selectedCurrencyCode = preset as? String

            return .modal(currencyPicker)

        }
    }

    func getLoggingData(state: NewOpState) -> (logName: String, logParams: [String: Any]?)? {

        let currentState = checkFlow(state: state)

        switch currentState {
        case .loading: return ("loading", params)
        case .amount: return ("amount", params)
        case .description: return ("description", params)
        case .confirmation(let data):
            updateFeeParams(data)
            return ("confirmation", params)
        case .currencyPicker:
            // It's a view controller, it controls it's own logging
            return nil
        }
    }

    func shouldDisplayOneConfNotice(state: NewOpState) -> Bool {
        let currentState = checkFlow(state: state)
        let swapParams: SwapExecutionParameters

        switch currentState {
        case .loading, .amount, .currencyPicker:
            return false

        case .description(let data):
            swapParams = data.params

        case .confirmation(let data):
            swapParams = data.params
        }

        return swapParams.confirmationsNeeded >= 1
    }

    private func updateFeeParams(_ data: NewOpSubmarineSwapData.Confirm) {
        switch data.feeState {
        case .noPossibleFee, .feeNeedsChange:
            return
        case .finalFee(_, let rate):
            params["sats_per_virtual_byte"] = "\(rate.satsPerVByte)"
        }
    }

    private func addDebtTypeParam(swapParams: SwapExecutionParameters) {
        if params["debt_type"] != nil {
            return
        }

        params["debt_type"] = swapParams.debtType.rawValue.lowercased()
    }

    private func buildDestination(type: PaymentRequestType, confirm: Bool = false) -> MUView {

        let pubKey = self.getSubmarineSwap(type: type)._receiver.publicKey()
        let moreInfo = BottomDrawerInfo.swapDestination(pubKey: pubKey, destinationInfo: destinationInfo(type: type))

        return NewOpDestinationFilledDataView(type: type,
                                              delegate: filledDataDelegate,
                                              confirm: confirm,
                                              moreInfo: moreInfo)
    }

    private func destinationInfo(type: PaymentRequestType) -> NSAttributedString {
        let swap = getSubmarineSwap(type: type)
        let pubKey = swap._receiver.publicKey()
        let ipAddresses = swap._receiver._networkAddresses.joined(separator: "\n")
        let pubKeyTitle = L10n.OpSubmarineSwapViewBuilder.s1
        let ipAddressesTitle = L10n.OpSubmarineSwapViewBuilder.s2

        var description = """

        \(pubKeyTitle)
        \(pubKey)
        """

        if ipAddresses != "" {
            let ipString = """
            \(ipAddressesTitle)
            \(ipAddresses)
            """
            description.append("\n")
            description.append("\n")
            description.append(ipString)
        }

        let attrDesc = description.attributedForDescription()
            .set(bold: pubKeyTitle, color: Asset.Colors.muunGrayDark.color)
            .set(bold: ipAddressesTitle, color: Asset.Colors.muunGrayDark.color)
        return attrDesc
    }

    private func buildAmountView(_ amount: BitcoinAmount, confirm: Bool = false) -> MUView {
        let filledAmount = NewOpFilledAmount(type: .amount, amount: amount)
        let view = NewOpAmountFilledDataView(filledData: filledAmount, delegate: amountDelegate)
        if !confirm {
            view.showSeparator()
        }

        return view
    }

    private func buildLightningFeeView(_ confirmState: NewOpSubmarineSwapData.Confirm) -> MUView {
        let lightningFeeFilled = NewOpFilledAmount(type: .lightningFee, amount: confirmState.lightningFee())
        return NewOpAmountFilledDataView(filledData: lightningFeeFilled, delegate: amountDelegate)
    }

    private func buildTotalView(_ confirmState: NewOpSubmarineSwapData.Confirm) -> MUView {
        let totalFilled = NewOpFilledAmount(type: .total, amount: calculateTotalAmount(data: confirmState))
        let totalView = NewOpAmountFilledDataView(filledData: totalFilled, delegate: amountDelegate)

        totalView.showSeparator()
        return totalView
    }

    private func calculateTotalAmount(data: NewOpSubmarineSwapData.Confirm) -> BitcoinAmount {
        var amountInInput = data.amount.inInputCurrency.amount
        var amountInPrimary = data.amount.inPrimaryCurrency.amount

        let onChainFee = data.onChainFee()
        amountInInput += onChainFee.inInputCurrency.amount
        amountInPrimary += onChainFee.inPrimaryCurrency.amount

        let routingFee = data.routingFee()
        amountInInput += routingFee.inInputCurrency.amount
        amountInPrimary += routingFee.inPrimaryCurrency.amount

        var totalFee = onChainFee.inSatoshis + routingFee.inSatoshis

        // On LEND swaps we don't need to add the sweep fee because there won't be any on-chain tx
        if data.params.debtType != .LEND {
            let sweepFee = data.sweepFee()
            amountInInput += sweepFee.inInputCurrency.amount
            amountInPrimary += sweepFee.inPrimaryCurrency.amount

            totalFee += sweepFee.inSatoshis
        }

        return BitcoinAmount(
            inSatoshis: data.amount.inSatoshis + totalFee,
            inInputCurrency: MonetaryAmount(amount: amountInInput, currency: data.amount.inInputCurrency.currency),
            inPrimaryCurrency: MonetaryAmount(amount: amountInPrimary, currency: data.amount.inPrimaryCurrency.currency)
        )
    }

    private func getFeeViews(data: NewOpSubmarineSwapData.Confirm) -> [MUView] {
        var views: [MUView] = []
        views.append(buildLightningFeeView(data))

        return views
    }

    private func checkFlow(state: NewOpState) -> SubmarineSwapState {
        guard let currentState = state as? SubmarineSwapState else {
            Logger.fatal("Wrong state: \(state) in Submarine swap flow")
        }

        return currentState
    }

    private func getSubmarineSwap(type: PaymentRequestType) -> SubmarineSwap {
        guard let swapFlow = type as? FlowSubmarineSwap else {
            Logger.fatal("Wrong payment request: \(type) in Submarine swap flow")
        }
        return swapFlow.submarineSwap
    }

}
