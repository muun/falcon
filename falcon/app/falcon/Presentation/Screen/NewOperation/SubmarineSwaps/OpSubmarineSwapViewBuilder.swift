//
//  OpSubmarineSwapViewBuilder.swift
//  falcon
//
//  Created by Juan Pablo Civile on 01/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core
import Libwallet

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
    private var origin: Constant.NewOpAnalytics.Origin

    private var params: [String: Any] = [:]

    init(transitionDelegate: Transitions,
         newOpViewDelegate: NewOpViewDelegate,
         filledDataDelegate: NewOperationView.FilledDataDelegate,
         amountDelegate: AmountDelegate?,
         origin: Constant.NewOpAnalytics.Origin) {
        self.transitionDelegate = transitionDelegate
        self.newOpViewDelegate = newOpViewDelegate
        self.filledDataDelegate = filledDataDelegate
        self.amountDelegate = amountDelegate
        self.origin = origin
    }

    func getNextStep(state: NewOpState) -> NewOpNextStep {
        switch state {

        case .loading(let data):
            return .view(NewOpLoadingView(paymentIntent: data.type,
                                          delegate: transitionDelegate,
                                          origin: origin),
                         filledData: [])

        case .amount(let data):
            let view = NewOpAmountView(data: data,
                                       delegate: newOpViewDelegate,
                                       transitionsDelegate: transitionDelegate)

            return .view(view, filledData: [
                buildDestination(type: data.type)
            ])

        case .description(let data):
            let descriptionView = NewOpDescriptionView(data: data,
                                                       delegate: newOpViewDelegate,
                                                       transitionsDelegate: transitionDelegate)
            return .view(descriptionView, filledData: [
                buildDestination(type: data.type),
                buildAmountView(data.amount)
            ])

        case .confirmation(let data):
            addAnalyticsParams(data: data)

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

        case .currencyPicker(let data, let selectedCurrency):

            let currencyPicker = CurrencyPickerViewController.createForCurrencySelection(
                exchangeRateWindow: data.exchangeRateWindow,
                delegate: amountDelegate,
                selectedCurrency: selectedCurrency
            )

            return .modal(currencyPicker)

        default:
            Logger.fatal("unhandled state: \(state)")
        }

    }

    private func addAnalyticsParams(data: NewOpData.Confirm) {
        data.getLightningAnalyticsParams().forEach {
            params[$0] = $1
        }
    }

    func getLoggingData(state: NewOpState) -> (logName: String, logParams: [String: Any]?)? {

        switch state {
        case .loading: return ("loading", params)
        case .amount: return ("amount", params)
        case .description: return ("description", params)
        case .confirmation(let data):
            updateFeeParams(data)
            return ("confirmation", params)
        case .currencyPicker:
            // It's a view controller, it controls it's own logging
            return nil
        default:
            return nil
        }
    }

    func shouldDisplayOneConfNotice(state: NewOpState) -> Bool {
        switch state {
        case .loading, .amount, .currencyPicker:
            return false

        case .description(let data):
            return data.isOneConf

        case .confirmation(let data):
            return data.isOneConf

        default:
            Logger.fatal("unhandled state: \(state)")
        }
    }

    private func updateFeeParams(_ data: NewOpData.Confirm) {
        switch data.feeState {
        case .noPossibleFee, .feeNeedsChange:
            return
        case .finalFee(_, let rate):
            params["sats_per_virtual_byte"] = "\(rate.satsPerVByte)"
        }
    }

    private func buildDestination(type: PaymentRequestType, confirm: Bool = false) -> MUView {

        let submarineSwap = getSubmarineSwap(type: type)

        let pubKey = submarineSwap.receiver!.publicKey
        let moreInfo = BottomDrawerInfo.swapDestination(
            pubKey: pubKey, destinationInfo: destinationInfo(type: type))

        return NewOpDestinationFilledDataView(type: type,
                                              delegate: filledDataDelegate,
                                              confirm: confirm,
                                              moreInfo: moreInfo)
    }

    private func destinationInfo(type: PaymentRequestType) -> NSAttributedString {

        let submarineSwap = getSubmarineSwap(type: type)

        let pubKey = submarineSwap.receiver!.publicKey
        let ipAddresses = submarineSwap.receiver!.networkAddresses
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

    private func buildAmountView(_ amount: BitcoinAmountWithSelectedCurrency, confirm: Bool = false) -> MUView {
        let filledAmount = NewOpFilledAmount(type: .amount, amountWithCurrency: amount)
        let view = NewOpAmountFilledDataView(filledData: filledAmount, delegate: amountDelegate)
        if !confirm {
            view.showSeparator()
        }

        return view
    }

    private func buildLightningFeeView(_ confirmState: NewOpData.Confirm) -> MUView {
        guard case .finalFee(let fee, rate: _) = confirmState.feeState else {
            Logger.fatal("expected fee to be final for lightning payments")
        }
        let selectedCurrency = confirmState.amount.selectedCurrency
        let amountWithCurrency = BitcoinAmountWithSelectedCurrency(bitcoinAmount: fee,
                                                                   selectedCurrency: selectedCurrency)
        let lightningFeeFilled = NewOpFilledAmount(type: .lightningFee, amountWithCurrency: amountWithCurrency)
        return NewOpAmountFilledDataView(filledData: lightningFeeFilled, delegate: amountDelegate)
    }

    private func buildTotalView(_ confirmState: NewOpData.Confirm) -> MUView {
        let selectedCurrency = confirmState.amount.selectedCurrency
        let bitcoinAmountWithCurrency = BitcoinAmountWithSelectedCurrency(bitcoinAmount: confirmState.total,
                                                                          selectedCurrency: selectedCurrency)
        let totalFilled = NewOpFilledAmount(type: .total,
                                            amountWithCurrency: bitcoinAmountWithCurrency)
        let totalView = NewOpAmountFilledDataView(filledData: totalFilled, delegate: amountDelegate)

        totalView.showSeparator()
        return totalView
    }

    private func getFeeViews(data: NewOpData.Confirm) -> [MUView] {
        var views: [MUView] = []
        views.append(buildLightningFeeView(data))

        return views
    }

    private func getSubmarineSwap(type: PaymentRequestType) -> NewopSubmarineSwap {
        guard let swapFlow = type as? FlowSubmarineSwap else {
            Logger.fatal("Wrong payment request: \(type) in Submarine swap flow")
        }
        return swapFlow.submarineSwap.toLibwallet()
    }

}
