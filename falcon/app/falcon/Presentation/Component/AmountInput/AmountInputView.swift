//
//  AmountInputView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 04/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import UIKit
import core

protocol AmountInputViewDelegate: AnyObject {
    func didInput(amount: String, currency: Currency)
    func didTapCurrency()
}

@IBDesignable
class AmountInputView: UIView {

    enum State {
        case zero
        case valid
        case tooSmall
        case tooBig
    }

    typealias CurrencyConverter = (String, Currency, Currency) -> MonetaryAmount

    private var textField: UITextField!
    private var currencyLabel: UILabel!
    private var subLabel: UILabel!
    /* This text field is hidden and mirrors all relevant properties from the visible
     * field. It's used to avoid a crazy bug that made the textField shrink when
     * the first character was entered (even though it had space to grow).
     * Since this one has no constraints limiting it's width, it can grow as it pleases.
     * And a constraint with priority 999 matches both fields width + 1.
     * This makes the field the right size at all times.
     */
    private var mirrorTextField: UITextField!

    // The last amount actually typed by the user
    private var typedAmount: MonetaryAmountWithCompleteDataOfCurrency?

    var value: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
            mirrorTextField.text = newValue
        }
    }

    var currency: Currency {
        willSet {
            // This needs to happen before we forget the old value!
            convert(to: newValue)
        }
        didSet {
            currencyLabel.text = currency.displayCode
        }
    }

    var subtitle: String {
        get {
            subLabel.text ?? ""
        }
        set {
            subLabel.text = newValue
        }
    }

    var state: State {
        didSet {
            renderState()
        }
    }

    private let converter: CurrencyConverter
    private weak var delegate: AmountInputViewDelegate?

    required init?(coder: NSCoder) {
        fatalError()
    }

    init(delegate: AmountInputViewDelegate?, converter: @escaping CurrencyConverter) {
        self.currency = GetBTCDefaultSelectedUnit.run()
        self.state = .zero
        self.converter = converter
        self.delegate = delegate

        super.init(frame: .zero)

        buildViews()
        makeViewTestable()
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    private func convert(to newCurrency: Currency) {

        // So, why the weird typedAmount thingy? 
        // This allows us to avoid reconverting the amount back and forth when the user changes
        // currencies. We keep record of the amount actually typed in by the user and convert that
        // between currencies. If the user switches from BTC to USD and back, the amount will be
        // exactly the same without

        let toConvert: String
        let fromCurrency: Currency
        if let typedAmount = typedAmount {
            toConvert = typedAmount.toAmountWithoutCode(btcCurrencyFormat: .short)
            fromCurrency = typedAmount.currency
        } else {
            toConvert = value
            fromCurrency = currency
        }

        let newAmount = converter(toConvert, fromCurrency, newCurrency)
        if newAmount.amount == 0 {
            value = ""
        } else {
            value = newCurrency.toAmountWithoutCode(amount: newAmount.amount,
                                                    btcCurrencyFormat: .long)
        }
    }

    @objc fileprivate func didTapCurrency(_ sender: Any) {
        delegate?.didTapCurrency()
    }

    private func renderState() {

        switch state {
        case .zero:
            subLabel.textColor = Asset.Colors.muunGrayDark.color
            textField.textColor = Asset.Colors.muunBlue.color
            textField.tintColor = Asset.Colors.muunBlue.color

        case .tooBig:
            textField.textColor = Asset.Colors.muunRed.color
            textField.tintColor = Asset.Colors.muunRed.color
            subLabel.textColor = Asset.Colors.muunRed.color

        case .tooSmall:
            textField.textColor = Asset.Colors.muunRed.color
            textField.tintColor = Asset.Colors.muunRed.color
            subLabel.textColor = Asset.Colors.muunGrayDark.color

        case .valid:
            subLabel.textColor = Asset.Colors.muunGrayDark.color
            textField.textColor = Asset.Colors.muunBlue.color
            textField.tintColor = Asset.Colors.muunBlue.color
        }
    }

}

extension AmountInputView: UITextFieldDelegate {

    // swiftlint:disable function_body_length
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String)
        -> Bool {

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

            let newAmount = currency.formattedNumber(from: updatedText)
            typedAmount = MonetaryAmountWithCompleteDataOfCurrency(monetaryAmount: newAmount,
                                                                   currency: currency)

            delegate?.didInput(amount: updatedText, currency: currency)

            if updatedText == "" {
                mirrorTextField.text = ""
                return true
            }
            textField.text = updatedText
            mirrorTextField.text = updatedText

            var indexInOriginal = text.startIndex
            var indexInNew = updatedText.startIndex

            guard let rangeStart = text.index(text.startIndex,
                                              offsetBy: range.lowerBound,
                                              limitedBy: text.endIndex)
                else { return false }

            func advance(index: String.Index, in text: String, by offset: Int) -> String.Index {

                var nextIndex = index
                var consumed = 0

                while consumed < offset && nextIndex < text.endIndex {

                    // We usually advance once more than the string can take (since the caret might
                    // reach the end) so check before subscripting.
                    if nextIndex < text.endIndex
                        && !LocaleAmountFormatter.isSeparator(String(text[nextIndex])) {
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

            // indexInNew now has the updated index of the range start so we offset it by the
            // changed text
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
    // swiftlint:enable function_body_length cyclomatic_complexity

}

fileprivate extension AmountInputView {

    func buildViews() {

        let inputContainer = UIView()
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(inputContainer)

        textField = buildTextField()
        textField.delegate = self
        inputContainer.addSubview(textField)

        mirrorTextField = buildMirrorTextField()
        addSubview(mirrorTextField)

        subLabel = buildSubLabel()
        addSubview(subLabel)

        currencyLabel = buildCurrencyLabel()
        inputContainer.addSubview(currencyLabel)

        let chevron = buildChevron()
        inputContainer.addSubview(chevron)

        // textField is slightly larger than mirrorTextField
        // mirrorTextField has no size constraints so when it decides it's instrinsic size it uses
        // as much space as it wants. But textField is has limits due to the size available to it's
        // parent. Adding those magic constants keeps iOS from deciding it needs to reduce the font
        // size magically.
        let heightConstraint = textField.heightAnchor.constraint(equalTo: mirrorTextField.heightAnchor, constant: 2)
        let widthConstraint = textField.widthAnchor.constraint(equalTo: mirrorTextField.widthAnchor, constant: 12)

        // We want to be that size, but not bad enough that we don't fit where we're supposed to
        widthConstraint.priority = .required - 1

        NSLayoutConstraint.activate([
            // Position inputContainer horizontally to be centered but not exceed its parent
            centerXAnchor.constraint(equalTo: inputContainer.centerXAnchor),
            leadingAnchor.constraint(lessThanOrEqualTo: inputContainer.leadingAnchor, constant: 8),
            trailingAnchor.constraint(greaterThanOrEqualTo: inputContainer.trailingAnchor,
                                      constant: 8),

            // inputContainer sits below the top border
            topAnchor.constraint(equalTo: inputContainer.topAnchor, constant: 8),

            // subLabel sits between inputContainer and its parent bottom border
            subLabel.topAnchor.constraint(equalTo: inputContainer.bottomAnchor, constant: 16),
            subLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),

            // subLabel is horizontally centered
            subLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            // textField is right of inputContainer left border
            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor),

            // textField sets its parent height
            textField.topAnchor.constraint(equalTo: inputContainer.topAnchor),
            textField.lastBaselineAnchor.constraint(equalTo: inputContainer.bottomAnchor),

            // mirrorTextField sits at 0, 0 of the view with no other limits so it can grow
            mirrorTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            mirrorTextField.topAnchor.constraint(equalTo: topAnchor),

            heightConstraint,
            widthConstraint,

            // currencyLabel sits to the right of textField
            currencyLabel.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 6),

            // currencyLabel is baseline aligned with textField
            currencyLabel.firstBaselineAnchor.constraint(equalTo: textField.firstBaselineAnchor),

            // chevron sits to the right of currency and borders its parent right edge
            chevron.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor),
            chevron.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 4),

            // chevron is vertically aligned with currencyLabel
            chevron.centerYAnchor.constraint(equalTo: currencyLabel.centerYAnchor)
        ])
    }

    private func buildTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false

        textField.minimumFontSize = 17
        textField.font = Constant.Fonts.system(size: .amountInput, weight: .thin)
        textField.textAlignment = .center
        textField.clearButtonMode = .never
        textField.keyboardType = .decimalPad

        textField.textColor = Asset.Colors.muunBlue.color
        textField.tintColor = Asset.Colors.muunBlue.color
        textField.attributedPlaceholder = NSAttributedString(
            string: "0",
            attributes: [NSAttributedString.Key.foregroundColor: Asset.Colors.muunGrayLight.color]
        )

        textField.adjustsFontSizeToFitWidth = true

        // We want to be exactly the size we want, no more no less

        textField.setContentCompressionResistancePriority(.required - 2, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required - 1, for: .vertical)

        return textField
    }

    private func buildMirrorTextField() -> UITextField {

        let textField = buildTextField()

        textField.adjustsFontSizeToFitWidth = false
        textField.isHidden = true

        // We want to be exactly the size we want, no more no less
        textField.setContentHuggingPriority(.required, for: .horizontal)
        textField.setContentCompressionResistancePriority(.required, for: .horizontal)
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)

        return textField
    }

    private func buildSubLabel() -> UILabel {
        let subLabel = UILabel()
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        subLabel.numberOfLines = 1
        subLabel.font = Constant.Fonts.system(size: .helper)
        subLabel.textColor = Asset.Colors.muunGrayDark.color

        return subLabel
    }

    private func buildCurrencyLabel() -> UILabel {
        let currencyLabel = UILabel()
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false

        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
        currencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        currencyLabel.setContentHuggingPriority(.defaultLow + 1, for: .vertical)

        currencyLabel.text = currency.displayCode
        currencyLabel.font = Constant.Fonts.system(size: .h1)
        currencyLabel.numberOfLines = 1
        currencyLabel.textColor = Asset.Colors.muunGrayDark.color
        currencyLabel.isUserInteractionEnabled = true

        currencyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: .didTapCurrency))

        return currencyLabel
    }

    private func buildChevron() -> UIButton {
        let chevron = UIButton()
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.setImage(Asset.Assets.openArrow.image, for: .normal)

        chevron.setContentCompressionResistancePriority(.required, for: .horizontal)
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.setContentHuggingPriority(.defaultLow + 1, for: .vertical)

        chevron.addTarget(self, action: .didTapCurrency, for: .touchUpInside)

        return chevron
    }
}

extension AmountInputView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.AmountInput

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(textField, using: .input)
        makeViewTestable(subLabel, using: .subtitle)
        makeViewTestable(currencyLabel, using: .currency)
    }
}

fileprivate extension Selector {

    static let didTapCurrency = #selector(AmountInputView.didTapCurrency)

}
