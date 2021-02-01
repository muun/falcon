//
//  NewOpViewBuilder.swift
//  falcon
//
//  Created by Manu Herrera on 01/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class OpToAddressViewBuilder: OpViewBuilder {

    typealias Transitions =
        NewOperationTransitions
        & OpLoadingTransitions
        & OpConfirmTransitions
        & OpAmountTransitions
        & OpDescriptionTransitions
        & SelectFeeDelegate
        & NewOpFilledAmountTransitions

    typealias AmountDelegate =
        NewOpFilledAmountDelegate
        & CurrencyPickerDelegate

    weak var transitionDelegate: Transitions?
    weak var newOpViewDelegate: NewOpViewDelegate?
    weak var filledDataDelegate: NewOperationView.FilledDataDelegate?
    weak var amountDelegate: AmountDelegate?

    init(transitionDelegate: Transitions,
         newOpViewDelegate: NewOpViewDelegate,
         filledDataDelegate: NewOperationView.FilledDataDelegate,
         amountDelegate: AmountDelegate) {
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
            return .view(NewOpAmountView(data: data,
                                         delegate: newOpViewDelegate,
                                         transitionsDelegate: transitionDelegate,
                                         preset: preset as? MonetaryAmount),
                         filledData: [buildDestinationView(type: data.type)])

        case .description(let data):
            let descriptionView = NewOpDescriptionView(data: data,
                                                       delegate: newOpViewDelegate,
                                                       transitionsDelegate: transitionDelegate,
                                                       preset: preset as? String)
            return .view(descriptionView, filledData: [
                buildDestinationView(type: data.type),
                buildAmountView(data.amount, takeFeeFromAmount: false)
            ])

        case .confirmation(let data):
            let view = NewOpConfirmView(feeState: data.feeState,
                                        delegate: newOpViewDelegate,
                                        transitionDelegate: transitionDelegate)
            view.validityCheck()
            return .view(view, filledData: [
                buildDestinationView(type: data.type, confirm: true),
                buildAmountView(data.amount, takeFeeFromAmount: data.takeFeeFromAmount, confirm: true),
                buildOnChainFeeView(data),
                buildTotalView(data),
                NewOpDescriptionFilledDataView(descriptionText: data.description)
            ])

        case .feeEditor(let data, let calculateFee):

            let state = FeeEditor.State(feeState: data.feeState,
                                        calculateFee: calculateFee,
                                        feeCalculator: data.feeInfo.feeCalculator,
                                        amount: data.amount.inSatoshis,
                                        feeConfirmationTargets: getConfirmationTargets(data))

            return .modal(SelectFeeViewController(delegate: transitionDelegate,
                                                  state: state))

        case .currencyPicker(let data):
            let currencyPicker = CurrencyPickerViewController(
                exchangeRateWindow: data.feeInfo.exchangeRateWindow,
                delegate: amountDelegate
            )
            currencyPicker.selectedCurrencyCode = preset as? String

            return .modal(currencyPicker)
        }
    }

    func getLoggingData(state: NewOpState) -> (logName: String, logParams: [String: Any]?)? {

        let currentState = checkFlow(state: state)

        switch currentState {

        case .loading: return ("loading", nil)
        case .amount: return ("amount", nil)
        case .description: return ("description", nil)
        case .confirmation(let data): return ("confirmation", getFeeParams(data))
        case .feeEditor, .currencyPicker:
            // These are view controller, they control their own logging
            return nil
        }
    }

    func shouldDisplayOneConfNotice(state: NewOpState) -> Bool {
        // This is only for submarine swaps
        return false
    }

    private func getConfirmationTargets(_ data: NewOpToAddressData.Confirm) -> FeeConfirmationTargets {
        let feeWindow = data.feeInfo.feeWindow
        return (
            slow: feeWindow.slowConfTarget ?? 1,
            medium: feeWindow.mediumConfTarget ?? 1,
            fast: feeWindow.fastConfTarget ?? 1
        )
    }

    private func getFeeParams(_ data: NewOpToAddressData.Confirm) -> [String: Any]? {
        let feeWindow = data.feeInfo.feeWindow
        let fastFee = feeWindow.targetedFees[feeWindow.fastConfTarget ?? 1]
        let mediumFee = feeWindow.targetedFees[feeWindow.mediumConfTarget ?? 1]
        let slowFee = feeWindow.targetedFees[feeWindow.slowConfTarget ?? 1]

        var params = [String: String]()

        switch data.feeState {
        case .noPossibleFee, .feeNeedsChange:
            return params
        case .finalFee(_, let rate):
            switch rate.satsPerVByte {
            case fastFee?.satsPerVByte:
                params["fee_type"] = "fast"
            case mediumFee?.satsPerVByte:
                params["fee_type"] = "medium"
            case slowFee?.satsPerVByte:
                params["fee_type"] = "slow"
            default:
                params["fee_type"] = "custom"
            }

            params["sats_per_virtual_byte"] = "\(rate.satsPerVByte)"
        }

        return params
    }

    private func buildDestinationView(type: PaymentRequestType, confirm: Bool = false) -> MUView {
        let moreInfo = BottomDrawerInfo.newOpDestination(address: getToAddressFlow(type: type).address())

        return NewOpDestinationFilledDataView(type: type,
                                              delegate: filledDataDelegate,
                                              confirm: confirm,
                                              moreInfo: moreInfo)
    }

    private func calculateTotalAmount(data: NewOpToAddressData.Confirm) -> BitcoinAmount {
        var amountInInput = data.amount.inInputCurrency.amount
        var amountInPrimary = data.amount.inPrimaryCurrency.amount

        let fee = getOnChainFee(data: data).value
        let finalFee = fee.inSatoshis
        amountInInput += fee.inInputCurrency.amount
        amountInPrimary += fee.inPrimaryCurrency.amount

        return BitcoinAmount(
            inSatoshis: data.amount.inSatoshis + finalFee,
            inInputCurrency: MonetaryAmount(amount: amountInInput, currency: data.amount.inInputCurrency.currency),
            inPrimaryCurrency: MonetaryAmount(amount: amountInPrimary, currency: data.amount.inPrimaryCurrency.currency)
        )
    }

    func getOnChainFee(data: NewOpToAddressData.Confirm) -> (value: BitcoinAmount, isValid: Bool) {

        switch data.feeState {
        case .feeNeedsChange(let displayFee, _):
            return (displayFee, false)
        case .finalFee(let fee, _):
            return (fee, true)
        case .noPossibleFee:
            Logger.fatal("Trying to display no possible fee")
        }
    }

    private func buildAmountView(_ amount: BitcoinAmount, takeFeeFromAmount: Bool, confirm: Bool = false) -> MUView {
        var notice: Notice?
        if takeFeeFromAmount {

            let boldText = L10n.OpToAddressViewBuilder.s1
            let allText = L10n.OpToAddressViewBuilder.s4
            notice = Notice(notice: allText, bold: boldText, boldColor: Asset.Colors.muunWarning.color)
        }

        let filledAmount = NewOpFilledAmount(type: .amount, amount: amount, notice: notice)
        let view = NewOpAmountFilledDataView(filledData: filledAmount,
                                             delegate: amountDelegate,
                                             transitionsDelegate: transitionDelegate)

        if !confirm {
            view.showSeparator()
        }
        return view
    }

    private func buildOnChainFeeView(_ confirmState: NewOpToAddressData.Confirm) -> MUView {
        let fee = getOnChainFee(data: confirmState)
        let text = L10n.OpToAddressViewBuilder.s2
        let notice: Notice? = fee.isValid
            ? nil
            : Notice(notice: text, bold: L10n.OpToAddressViewBuilder.s1, boldColor: Asset.Colors.muunWarning.color)
        let feeFilled = NewOpFilledAmount(type: .onchainFee,
                                          amount: fee.value,
                                          notice: notice)

        let view = NewOpAmountFilledDataView(
            filledData: feeFilled,
            delegate: amountDelegate,
            transitionsDelegate: transitionDelegate
        )

        if !fee.isValid {
            view.setAmountColor(Asset.Colors.muunRed.color)
        }

        return view
    }

    private func buildTotalView(_ confirmState: NewOpToAddressData.Confirm) -> MUView {
        let fee = getOnChainFee(data: confirmState)

        let totalFilled = NewOpFilledAmount(type: .total,
                                            amount: calculateTotalAmount(data: confirmState))

        let totalView = NewOpAmountFilledDataView(filledData: totalFilled,
                                                  delegate: amountDelegate,
                                                  transitionsDelegate: transitionDelegate)
        totalView.showSeparator()

        if !fee.isValid {
            totalView.setAmountColor(Asset.Colors.muunGrayLight.color)
        }

        return totalView
    }

    private func checkFlow(state: NewOpState) -> ToAddressState {
        guard let currentState = state as? ToAddressState else {
            Logger.fatal("Wrong state: \(state) in Op To Address flow")
        }

        return currentState
    }

    private func getToAddressFlow(type: PaymentRequestType) -> FlowToAddress {
        guard let toAddressFlow = type as? FlowToAddress else {
            Logger.fatal("Wrong payment request: \(type) in To Address swap flow")
        }
        return toAddressFlow
    }

}
