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

    func getNextStep(state: NewOpState) -> NewOpNextStep {
        switch state {

        case .loading(let data):
            return .view(NewOpLoadingView(paymentIntent: data.type, delegate: transitionDelegate), filledData: [])

        case .amount(let data):
            return .view(NewOpAmountView(data: data,
                                         delegate: newOpViewDelegate,
                                         transitionsDelegate: transitionDelegate),
                         filledData: [buildDestinationView(type: data.type)])

        case .description(let data):
            let descriptionView = NewOpDescriptionView(data: data,
                                                       delegate: newOpViewDelegate,
                                                       transitionsDelegate: transitionDelegate)
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
                buildOnChainFeeView(data, currency: data.amount.selectedCurrency),
                buildTotalView(data),
                NewOpDescriptionFilledDataView(descriptionText: data.description)
            ])

        case .feeEditor(let data):
            return .modal(SelectFeeViewController(delegate: transitionDelegate,
                                                  state: data))

        case .currencyPicker(let data, let selectedCurrency):
            let currencyPicker = CurrencyPickerViewController.createForCurrencySelection(
                exchangeRateWindow: data.exchangeRateWindow,
                delegate: amountDelegate,
                selectedCurrency: selectedCurrency
            )

            return .modal(currencyPicker)
        }
    }

    func getLoggingData(state: NewOpState) -> (logName: String, logParams: [String: Any]?)? {
        switch state {

        case .loading: return ("loading", nil)
        case .amount: return ("amount", nil)
        case .description: return ("description", nil)
        case .confirmation(let data):
            // TODO(newop): this will not log again if we don't recreate the view
            return ("confirmation", getFeeParams(data))
        case .feeEditor, .currencyPicker:
            // These are view controller, they control their own logging
            return nil
        }
    }

    func shouldDisplayOneConfNotice(state: NewOpState) -> Bool {
        // This is only for submarine swaps
        return false
    }

    private func getFeeParams(_ data: NewOpData.Confirm) -> [String: Any]? {
        let feeWindow = data.feeWindow
        let fastFee = feeWindow.getTargetedFees(feeWindow.fastConfTarget)
        let mediumFee = feeWindow.getTargetedFees(feeWindow.mediumConfTarget)
        let slowFee = feeWindow.getTargetedFees(feeWindow.slowConfTarget)

        var params = [String: String]()

        switch data.feeState {
        case .noPossibleFee, .feeNeedsChange:
            return params
        case .finalFee(_, let rate):
            switch (rate.satsPerVByte as NSDecimalNumber).doubleValue {
            case fastFee:
                params["fee_type"] = "fast"
            case mediumFee:
                params["fee_type"] = "medium"
            case slowFee:
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

    func getOnChainFee(data: NewOpData.Confirm) -> (value: BitcoinAmount, isValid: Bool) {

        switch data.feeState {
        case .feeNeedsChange(let displayFee, _):
            return (displayFee, false)
        case .finalFee(let fee, _):
            return (fee, true)
        case .noPossibleFee:
            Logger.fatal("Trying to display no possible fee")
        }
    }

    private func buildAmountView(_ amount: BitcoinAmountWithSelectedCurrency,
                                 takeFeeFromAmount: Bool,
                                 confirm: Bool = false) -> MUView {
        var notice: Notice?
        if takeFeeFromAmount {

            let boldText = L10n.OpToAddressViewBuilder.s1
            let allText = L10n.OpToAddressViewBuilder.s4
            notice = Notice(notice: allText, bold: boldText, boldColor: Asset.Colors.muunWarning.color)
        }

        let filledAmount = NewOpFilledAmount(type: .amount, amountWithCurrency: amount, notice: notice)
        let view = NewOpAmountFilledDataView(filledData: filledAmount,
                                             delegate: amountDelegate,
                                             transitionsDelegate: transitionDelegate)

        if !confirm {
            view.showSeparator()
        }
        return view
    }

    private func buildOnChainFeeView(_ confirmState: NewOpData.Confirm, currency: Currency) -> MUView {
        let fee = getOnChainFee(data: confirmState)
        let text = L10n.OpToAddressViewBuilder.s2
        let notice: Notice? = fee.isValid
            ? nil
            : Notice(notice: text, bold: L10n.OpToAddressViewBuilder.s1, boldColor: Asset.Colors.muunWarning.color)
        let btcAmountWithSelectedCurrency = BitcoinAmountWithSelectedCurrency(bitcoinAmount: fee.value,
                                                                              selectedCurrency: currency)
        let feeFilled = NewOpFilledAmount(type: .onchainFee,
                                          amountWithCurrency: btcAmountWithSelectedCurrency,
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

    private func buildTotalView(_ confirmState: NewOpData.Confirm) -> MUView {
        let fee = getOnChainFee(data: confirmState)
        let bitcoinAmount = BitcoinAmountWithSelectedCurrency(bitcoinAmount: confirmState.total,
                                                              selectedCurrency: confirmState.amount.selectedCurrency)
        let totalFilled = NewOpFilledAmount(type: .total,
                                            amountWithCurrency: bitcoinAmount)

        let totalView = NewOpAmountFilledDataView(filledData: totalFilled,
                                                  delegate: amountDelegate,
                                                  transitionsDelegate: transitionDelegate)
        totalView.showSeparator()

        if !fee.isValid {
            totalView.setAmountColor(Asset.Colors.muunGrayLight.color)
        }

        return totalView
    }

    private func getToAddressFlow(type: PaymentRequestType) -> FlowToAddress {
        guard let toAddressFlow = type as? FlowToAddress else {
            Logger.fatal("Wrong payment request: \(type) in To Address swap flow")
        }
        return toAddressFlow
    }

}
