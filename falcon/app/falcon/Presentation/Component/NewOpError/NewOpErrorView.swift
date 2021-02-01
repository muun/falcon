//
//  NewOpErrorView.swift
//  falcon
//
//  Created by Manu Herrera on 26/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

protocol NewOpErrorViewDelegate: class {
    func backToHomeTouched()
    func logErrorView(_ name: String, params: [String: Any]?)
    func descriptionTouched(type: NewOpError)
}

extension NewOpErrorViewDelegate {
    // In most cases we dont want to do anything so this is the default implementation
    func descriptionTouched(type: NewOpError) {}
}

class NewOpErrorView: MUView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var firstBox: UIView!
    @IBOutlet private weak var firstTitleLabel: UILabel!
    @IBOutlet private weak var firstLabel: UILabel!
    @IBOutlet private weak var secondBox: UIView!
    @IBOutlet private weak var secondTitleLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var linkButton: LinkButtonView!

    weak var delegate: NewOpErrorViewDelegate?
    public var type: NewOpError? {
        willSet {
            guard let type = newValue else {
                return
            }
            setTexts(type: type)
        }
    }

    override func setUp() {
        backgroundColor = Asset.Colors.background.color
        setUpLabels()
        setUpButton()

        makeViewTestable()
    }

    fileprivate func setUpButton() {
        linkButton.delegate = self
        linkButton.buttonText = L10n.NewOpErrorView.s1
        linkButton.isEnabled = true
    }

    fileprivate func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)

        descriptionLabel.style = .description
        descriptionLabel.isUserInteractionEnabled = true

        firstTitleLabel.textColor = Asset.Colors.muunGrayDark.color
        firstTitleLabel.font = Constant.Fonts.system(size: .helper)

        firstLabel.textColor = Asset.Colors.title.color
        firstLabel.font = Constant.Fonts.description

        secondTitleLabel.textColor = Asset.Colors.muunGrayDark.color
        secondTitleLabel.font = Constant.Fonts.system(size: .helper)

        secondLabel.textColor = Asset.Colors.title.color
        secondLabel.font = Constant.Fonts.description
    }

    private func setTexts(type: NewOpError) {
        titleLabel.text = type.title()
        descriptionLabel.attributedText = type.description()
        setFirstBox(type: type)
        setSecondBox(type: type)

        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .descriptionTouched))
    }

    func setButtonText(_ text: String) {
        linkButton.buttonText = text
    }

    @objc fileprivate func descriptionTouched() {
        if let currentType = type {
            delegate?.descriptionTouched(type: currentType)
        }
    }

    private func setFirstBox(type: NewOpError) {
        if let firstBoxInfo = type.firstBoxTexts() {
            firstTitleLabel.text = firstBoxInfo.title
            firstLabel.attributedText = firstBoxInfo.content
        } else {
            firstBox.removeFromSuperview()
        }
    }

    private func setSecondBox(type: NewOpError) {
        if let secondBoxInfo = type.secondBoxTexts() {
            secondTitleLabel.text = secondBoxInfo.title
            secondLabel.attributedText = secondBoxInfo.content
        } else {
            secondBox.removeFromSuperview()
        }
    }

    override func addTo(_ view: UIView) {
        self.alpha = 0
        super.addTo(view)
        delegate?.logErrorView("new_op_error", params: ["type": type?.loggingName() ?? ""])

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

}

extension NewOpErrorView: LinkButtonViewDelegate {
    func linkButton(didPress linkButton: LinkButtonView) {
        delegate?.backToHomeTouched()
    }
}

// swiftlint:disable cyclomatic_complexity
enum NewOpError {
    case invalidAddress(_ input: String)
    case expiredInvoice, exchangeRateWindowTooOld
    //Swaps
    case invalidInvoice, invoiceExpiresTooSoon, invoiceAlreadyUsed, noPaymentRoute, invoiceMissingAmount
    case invoiceUnreachableNode, cyclicalSwap
    //Fees
    case insufficientFunds(amountPlusFee: String, maxBalance: String)
    case amountBelowDust
    case unexpected

    func title() -> String {
        switch self {
        case .invalidAddress: return L10n.NewOpErrorView.s2
        case .expiredInvoice: return L10n.NewOpErrorView.s3
        case .exchangeRateWindowTooOld: return L10n.NewOpErrorView.s4
        case .invalidInvoice: return L10n.NewOpErrorView.s5
        case .invoiceExpiresTooSoon: return L10n.NewOpErrorView.s6
        case .invoiceAlreadyUsed: return L10n.NewOpErrorView.s7
        case .noPaymentRoute: return L10n.NewOpErrorView.s8
        case .insufficientFunds: return L10n.NewOpErrorView.s9
        case .amountBelowDust: return L10n.NewOpErrorView.s10
        case .invoiceMissingAmount: return L10n.NewOpErrorView.s11
        case .unexpected: return L10n.NewOpErrorView.s12
        case .invoiceUnreachableNode: return L10n.NewOpErrorView.s13
        case .cyclicalSwap: return L10n.NewOpErrorView.s13
        }
    }

    // swiftlint:disable function_body_length
    func description() -> NSAttributedString {
        switch self {
        case .invalidAddress:
            return L10n.NewOpErrorView.s25
                .attributedForDescription(alignment: .center)
        case .expiredInvoice:
            return L10n.NewOpErrorView.s15
                .attributedForDescription(alignment: .center)
        case .exchangeRateWindowTooOld:
            return L10n.NewOpErrorView.s26
                .attributedForDescription(alignment: .center)
        case .invalidInvoice:
            return L10n.NewOpErrorView.s16
                .attributedForDescription(alignment: .center)
        case .invoiceExpiresTooSoon:
            return L10n.NewOpErrorView.s27
                .attributedForDescription(alignment: .center)
        case .invoiceAlreadyUsed:
            return L10n.NewOpErrorView.s28
                .attributedForDescription(alignment: .center)
        case .noPaymentRoute:
            return L10n.NewOpErrorView.s29
                .attributedForDescription(alignment: .center)
                .set(underline: L10n.NewOpErrorView.s17, color: Asset.Colors.muunBlue.color)
        case .insufficientFunds:
            return L10n.NewOpErrorView.s18
                .attributedForDescription(alignment: .center)
        case .amountBelowDust:
            let text = L10n.NewOpErrorView.s30(Satoshis.dust.asDecimal().stringValue())
                .attributedForDescription(alignment: .center)
            return text
        case .invoiceMissingAmount:
            return L10n.NewOpErrorView.s19
                .attributedForDescription(alignment: .center)
        case .unexpected:
            return L10n.NewOpErrorView.s31
                .attributedForDescription(alignment: .center)
                .set(underline: L10n.NewOpErrorView.s17, color: Asset.Colors.muunBlue.color)
        case .invoiceUnreachableNode:
            return L10n.NewOpErrorView.s32
                .attributedForDescription(alignment: .center)
        case .cyclicalSwap:
            return L10n.NewOpErrorView.s21
                .attributedForDescription(alignment: .center)
        }
    }
    // swiftlint:enable function_body_length

    func firstBoxTexts() -> (title: String, content: NSAttributedString)? {
        switch self {
        case .invalidAddress(let input):
            let attText = input.attributedForDescription(alignment: .center)
                .set(bold: input, color: Asset.Colors.title.color)
            return (L10n.NewOpErrorView.s22, attText)
        case .insufficientFunds(let amountPlusFee, _):
            let attText = amountPlusFee.attributedForDescription(alignment: .center)
                .set(bold: amountPlusFee, color: Asset.Colors.title.color)
            return (L10n.NewOpErrorView.s23, attText)
        case .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon, .invoiceAlreadyUsed, .noPaymentRoute,
             .amountBelowDust, .exchangeRateWindowTooOld, .invoiceMissingAmount, .unexpected,
             .invoiceUnreachableNode, .cyclicalSwap:
            return nil
        }
    }

    func secondBoxTexts() -> (title: String, content: NSAttributedString)? {
        switch self {
        case .insufficientFunds(_, let balance):
            let attText = balance.attributedForDescription(alignment: .center)
                .set(bold: balance, color: Asset.Colors.muunRed.color)
            return (L10n.NewOpErrorView.s24, attText)
        case .invalidAddress, .expiredInvoice, .invalidInvoice, .invoiceExpiresTooSoon, .invoiceAlreadyUsed,
             .noPaymentRoute, .amountBelowDust, .exchangeRateWindowTooOld, .invoiceMissingAmount,
             .unexpected, .invoiceUnreachableNode, .cyclicalSwap:
            return nil
        }
    }

    func loggingName() -> String {
        switch self {
        case .invalidAddress: return "invalid_address"
        case .expiredInvoice: return "expired_invoice"
        case .invalidInvoice: return "invalid_invoice"
        case .invoiceExpiresTooSoon: return "invoice_expires_too_soon"
        case .invoiceAlreadyUsed: return "invoice_already_used"
        case .noPaymentRoute: return "no_payment_route"
        case .insufficientFunds: return "insufficient_funds"
        case .amountBelowDust: return "amount_below_dust"
        case .exchangeRateWindowTooOld: return "exchange_rate_window_too_old"
        case .invoiceMissingAmount: return "invoice_missing_amount"
        case .unexpected: return "other"
        case .invoiceUnreachableNode: return "invoice_unreachable_node"
        case .cyclicalSwap: return "cyclical_swap"
        }
    }
}
// swiftlint:enable cyclomatic_complexity

extension NewOpErrorView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp.ErrorView

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(titleLabel, using: .titleLabel)
        makeViewTestable(descriptionLabel, using: .descriptionLabel)
        makeViewTestable(linkButton, using: .button)
    }
}

fileprivate extension Selector {
    static let descriptionTouched = #selector(NewOpErrorView.descriptionTouched)
}
