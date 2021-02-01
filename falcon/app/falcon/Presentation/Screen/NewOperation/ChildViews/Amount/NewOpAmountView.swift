//
//  NewOpAmountView.swift
//  falcon
//
//  Created by Manu Herrera on 17/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

protocol OpAmountTransitions: NewOperationTransitions {
    func didEnter(amount: BitcoinAmount, data: NewOperationStateLoaded, takeFeeFromAmount: Bool)
    func requestCurrencyPicker(data: NewOperationStateLoaded, currencyCode: String)
}

class NewOpAmountView: MUView {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var maxAmountLabel: UILabel!
    @IBOutlet private weak var allFundsButton: LinkButtonView!
    /* This text field is hidden and mirrors all relevant properties from the visible
     * field. It's used to avoid a crazy bug that made the textField shrink when
     * the first character was entered (even though it had space to grow).
     * Since this one has no constraints limiting it's width, it can grow as it pleases.
     * And a constraint with priority 999 matches both fields width + 1.
     * This makes the field the right size at all times.
     */
    @IBOutlet private weak var mirrorTextField: UITextField!

    weak var delegate: NewOpViewDelegate?
    weak var transitionsDelegate: OpAmountTransitions?
    private let data: NewOperationStateLoaded
    private var currency: String = "BTC"
    private var useAllFunds = false
    private var amount: String {
        return textField.text != "" && textField.text != nil
            ? textField.text!
            : "0"
    }

    fileprivate lazy var presenter = instancePresenter(NewOpAmountPresenter.init, delegate: self, state: data)

    init(data: NewOperationStateLoaded,
         delegate: NewOpViewDelegate?,
         transitionsDelegate: OpAmountTransitions?,
         preset: MonetaryAmount?) {
        self.data = data
        self.delegate = delegate
        self.transitionsDelegate = transitionsDelegate

        super.init(frame: CGRect.zero)

        self.currency = presenter.getUserPrimaryCurrency()

        if let preset = preset {
            textField.text = LocaleAmountFormatter.string(from: preset)
            mirrorTextField.text = textField.text
            currency = preset.currency
        }

        presenter.validityCheck(amount, currency: currency)
        delegate?.update(buttonText: L10n.NewOpAmountView.s1)

        setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil {
            textField.becomeFirstResponder()
        }
    }

    override func setUp() {
        super.setUp()

        setUpView()
        makeViewTestable()
    }

    private func setUpView() {
        setUpTextField()
        setUpMaxAmountLabel()
        setUpAllFundsButton()
        setUpCurrencyLabel()
    }

    private func setUpTextField() {
        textField.textColor = Asset.Colors.muunBlue.color
        textField.tintColor = Asset.Colors.muunBlue.color
        textField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.muunGrayLight.color]
        )

        mirrorTextField.font = textField.font
    }

    private func setUpMaxAmountLabel() {
        let amount = presenter.totalBalance(in: currency)
        maxAmountLabel.text = L10n.NewOpAmountView.s2(
            LocaleAmountFormatter.string(from: amount),
            CurrencyHelper.string(for: amount.currency)
        )

        maxAmountLabel.font = Constant.Fonts.system(size: .helper)
        maxAmountLabel.textColor = Asset.Colors.muunGrayDark.color
    }

    private func setUpAllFundsButton() {
        allFundsButton.buttonText = L10n.NewOpAmountView.s3
        allFundsButton.delegate = self

        allFundsButton.isEnabled = (presenter.allFunds(in: currency).inSatoshis.asDecimal() > 0)
    }

    private func setUpCurrencyLabel() {
        currencyLabel.text = CurrencyHelper.string(for: currency)
        currencyLabel.font = Constant.Fonts.system(size: .h1)
        currencyLabel.textColor = Asset.Colors.muunGrayDark.color
        currencyLabel.isUserInteractionEnabled = true

        currencyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .currencyTouched))
    }

    @IBAction fileprivate func currencyTouched(_ sender: Any) {
        transitionsDelegate?.requestCurrencyPicker(data: data, currencyCode: currency)
    }

    func updateInfo(newCurrency: Currency) {
        let newAmount = presenter.convert(value: amount, in: currency, to: newCurrency.code)
        var newAmountString: String? = LocaleAmountFormatter.string(from: newAmount)
        if amount == "0" {
            // Clear amount input if amount were 0
            newAmountString = nil
        }

        currency = newCurrency.code
        textField.text = newAmountString
        mirrorTextField.text = textField.text
        setUpView()
        presenter.validityCheck(newAmountString ?? "0", currency: currency)
    }
}

extension NewOpAmountView: NewOperationChildView {

    var willDisplayKeyboard: Bool {
        return true
    }

}

extension NewOpAmountView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        let allFundsString = LocaleAmountFormatter.string(from: presenter.totalBalance(in: currency))
        textField.text = allFundsString
        mirrorTextField.text = textField.text
        useAllFunds = true

        pushNextState()
    }

}

extension NewOpAmountView: UITextFieldDelegate {

    // swiftlint:disable function_body_length
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String)
        -> Bool {

        useAllFunds = false

        if let text = textField.text,
            let textRange = Range(range, in: text) {

            if LocaleAmountFormatter.isSeparator(string) && text.contains(string) {
                // Allow only one separator
                return false
            }

            let replacedString = text.replacingCharacters(in: textRange, with: string)
            let updatedText = LocaleAmountFormatter.format(string: replacedString, in: currency)

            if updatedText.count >= 20 {
                return false
            }

            presenter.validityCheck(updatedText, currency: currency)
            presenter.setLastAmountEntered(LocaleAmountFormatter.number(from: updatedText, in: currency))

            if updatedText == "" {
                mirrorTextField.text = ""
                return true
            }
            textField.text = updatedText
            mirrorTextField.text = updatedText

            var indexInOriginal = text.startIndex
            var indexInNew = updatedText.startIndex

            guard let rangeStart = text.index(text.startIndex, offsetBy: range.lowerBound, limitedBy: text.endIndex)
                else { return false }

            func advance(index: String.Index, in text: String, by offset: Int) -> String.Index {

                var nextIndex = index
                var consumed = 0

                while consumed < offset && nextIndex < text.endIndex {

                    // We usually advance once more than the string can take (since the caret might reach the end)
                    // so check before subscripting
                    if nextIndex < text.endIndex && !LocaleAmountFormatter.isSeparator(String(text[nextIndex])) {
                        consumed += 1
                    }

                    nextIndex = text.index(after: nextIndex)
                }

                return nextIndex
            }

            while true {

                if indexInOriginal < rangeStart {

                    // Consume the next character in the new string and skip over any seperator
                    indexInNew = advance(index: indexInNew, in: updatedText, by: 1)

                    // Advance in the original string
                    indexInOriginal = advance(index: indexInOriginal, in: text, by: 1)
                } else {
                    break
                }

                if indexInNew >= updatedText.endIndex {
                    break
                }

            }

            // indexInNew now has the updated index of the range start so we offset it by the changed text
            if string.isEmpty {
                // The previous code leaves us one char after for deletions, so back up
                indexInNew = advance(index: indexInNew, in: updatedText, by: -1)
            } else {
                indexInNew = advance(index: indexInNew, in: updatedText, by: string.count)
            }

            let distance = updatedText.distance(from: updatedText.startIndex, to: indexInNew)

            guard let newPosition = textField.position(from: textField.beginningOfDocument,
                                                       offset: distance) else {
                                                        return false
            }

            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }

        return false
    }
    // swiftlint:enable function_body_length

}

extension NewOpAmountView: NewOperationChildViewDelegate {

    func pushNextState() {
        let input = textField.text ?? ""
        let amount: BitcoinAmount
        let isUsingAllFunds = useAllFunds || presenter.isSendingAllFundsManually(value: input, currency: currency)

        if isUsingAllFunds {
            amount = presenter.allFunds(in: currency)
        } else {
            amount = presenter.amount(from: input, in: currency)
        }

        let takeFeeFromAmount = data.feeInfo.feeCalculator.shouldTakeFeeFromAmount(amount.inSatoshis)

        transitionsDelegate?.didEnter(amount: amount, data: data, takeFeeFromAmount: takeFeeFromAmount)
    }

}

extension NewOpAmountView: NewOpAmountPresenterDelegate {

    func userDidChangeAmount(state: AmountState) {

        switch state {
        case .zero:
            delegate?.readyForNextState(false, error: nil)
            maxAmountLabel.textColor = Asset.Colors.muunGrayDark.color
            textField.textColor = Asset.Colors.muunBlue.color
            textField.tintColor = Asset.Colors.muunBlue.color

        case .tooBig:
            delegate?.readyForNextState(false, error: L10n.NewOpAmountView.s4)
            textField.textColor = Asset.Colors.muunRed.color
            textField.tintColor = Asset.Colors.muunRed.color
            maxAmountLabel.textColor = Asset.Colors.muunRed.color

        case .tooSmall:
            delegate?.readyForNextState(false, error: L10n.NewOpAmountView.s5)
            textField.textColor = Asset.Colors.muunRed.color
            textField.tintColor = Asset.Colors.muunRed.color
            maxAmountLabel.textColor = Asset.Colors.muunGrayDark.color

        case .valid:
            maxAmountLabel.textColor = Asset.Colors.muunGrayDark.color
            textField.textColor = Asset.Colors.muunBlue.color
            textField.tintColor = Asset.Colors.muunBlue.color
            delegate?.readyForNextState(true, error: nil)
        }

    }

}

fileprivate extension Selector {

    static let currencyTouched = #selector(NewOpAmountView.currencyTouched)

}

extension NewOpAmountView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp.AmountView

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(textField, using: .input)
        makeViewTestable(currencyLabel, using: .currency)
        makeViewTestable(allFundsButton, using: .useAllFunds)
        makeViewTestable(maxAmountLabel, using: .allFunds)
    }
}
