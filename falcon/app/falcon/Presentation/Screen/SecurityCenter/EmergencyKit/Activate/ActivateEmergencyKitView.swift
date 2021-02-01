//
//  ActivateEmergencyKitView.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ActivateEmergencyKitViewDelegate: class {
    func helpLabelTap()
    func verifyCode(_ code: String)
}

final class ActivateEmergencyKitView: UIView {

    private weak var delegate: ActivateEmergencyKitViewDelegate?

    private var titleAndDescriptionView: TitleAndDescriptionView!
    private var textFields: [DeletableTextField]! = []
    private var activationCodeLabel: UILabel!
    private var stackView: UIStackView!
    private var helpLabel: UILabel!

    private let textfieldsCount = 6
    private let textfieldMaxCharacters = 1

    init(delegate: ActivateEmergencyKitViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpTitleAndDescriptionView()
        setUpCodeTextfields()
        setUpLabels()
        makeViewTestable()
    }

    private func setUpTitleAndDescriptionView() {
        titleAndDescriptionView = TitleAndDescriptionView()
        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleAndDescriptionView)
        NSLayoutConstraint.activate([
            titleAndDescriptionView.topAnchor.constraint(equalTo: topAnchor),
            titleAndDescriptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            titleAndDescriptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])

        titleAndDescriptionView.titleText = L10n.ActivateEmergencyKitView.s1
        titleAndDescriptionView.descriptionText = L10n.ActivateEmergencyKitView.activationDescription
            .attributedForDescription()
            .set(bold: L10n.ActivateEmergencyKitView.boldDescription, color: Asset.Colors.title.color)
        titleAndDescriptionView.animate()
    }

    private func setUpCodeTextfields() {
        stackView = UIStackView()
        stackView.spacing = 8

        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: titleAndDescriptionView.bottomAnchor, constant: 32),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        for i in 0..<textfieldsCount {
            let tf = DeletableTextField()
            tf.delegate = self
            tf.deleteDelegate = self
            tf.keyboardType = .numberPad
            tf.tag = i
            makeViewTestable(tf, using: type(for: tf.tag))
            tf.backgroundColor = Asset.Colors.muunAlmostWhite.color
            tf.textColor = Asset.Colors.title.color
            tf.tintColor = Asset.Colors.title.color
            tf.font = Constant.Fonts.monospacedDigitSystemFont(size: .welcomeMessage, weight: .semibold)
            tf.textAlignment = .center
            tf.roundCorners()

            tf.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(tf)
            NSLayoutConstraint.activate([
                tf.heightAnchor.constraint(equalToConstant: 44),
                tf.widthAnchor.constraint(equalToConstant: 32)
            ])
            textFields.append(tf)
        }
    }

    private func setUpLabels() {
        setUpActivationCodeLabel()
        setUpHelpLabel()
    }

    private func setUpActivationCodeLabel() {
        activationCodeLabel = UILabel()
        activationCodeLabel.textColor = Asset.Colors.muunGrayDark.color
        activationCodeLabel.font = Constant.Fonts.system(size: .notice)
        activationCodeLabel.text = L10n.ActivateEmergencyKitView.s4
        activationCodeLabel.numberOfLines = 0
        activationCodeLabel.textAlignment = .center

        activationCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(activationCodeLabel)
        NSLayoutConstraint.activate([
            activationCodeLabel.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 12),
            activationCodeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            activationCodeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    private func resetActivationCodeLabel() {
        activationCodeLabel.textColor = Asset.Colors.muunGrayDark.color
        activationCodeLabel.text = L10n.ActivateEmergencyKitView.s4
    }

    func displayActivationCodeForTesting(_ code: String) {
        activationCodeLabel.text = code
    }

    private func setUpHelpLabel() {
        helpLabel = UILabel()
        helpLabel.style = .description
        helpLabel.attributedText = L10n.ActivateEmergencyKitView.s6
            .attributedForDescription(alignment: .center)
            .set(underline: L10n.ActivateEmergencyKitView.s6, color: Asset.Colors.muunBlue.color)

        helpLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(helpLabel)
        NSLayoutConstraint.activate([
            helpLabel.topAnchor.constraint(equalTo: activationCodeLabel.bottomAnchor, constant: 32),
            helpLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        helpLabel.isUserInteractionEnabled = true
        helpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .helpLabelTap))
    }

    @objc func helpLabelTap() {
        delegate?.helpLabelTap()
    }

    private func tryToVerifyCode() {
        let code = getFinalCode()

        if code.count == textfieldsCount {
            delegate?.verifyCode(code)
        }
    }

    // MARK: - View Controller actions -

    func wrongCode() {
        activationCodeLabel.textColor = Asset.Colors.muunRed.color
        activationCodeLabel.text = L10n.ActivateEmergencyKitView.s8
        activationCodeLabel.shake()
    }

    func oldCode(_ firstDigitsOfOriginalCode: String) {
        activationCodeLabel.attributedText = L10n.ActivateEmergencyKitView.oldCodeError(firstDigitsOfOriginalCode)
            .set(font: Constant.Fonts.system(size: .notice),
                 lineSpacing: Constant.FontAttributes.lineSpacing,
                 kerning: Constant.FontAttributes.kerning,
                 alignment: .center)
            .set(tint: L10n.ActivateEmergencyKitView.oldCodeErrorRed, color: Asset.Colors.muunRed.color)
            .set(bold: firstDigitsOfOriginalCode, color: Asset.Colors.muunGrayDark.color)
        activationCodeLabel.shake()
    }

    func showKeyboard() {
        textFields.first?.becomeFirstResponder()
    }

}

extension ActivateEmergencyKitView: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        resetActivationCodeLabel()

        if let text = textField.text, let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)
            let currentTag = textField.tag

            if range.lowerBound == 0 && range.upperBound == 0 && updatedText.isEmpty {

                // This is a delete on an empty string, so jump back
                selectPreviousField(from: currentTag)

            } else if updatedText.count >= textfieldMaxCharacters {

                // Only change it if we know the new value won't exceed the max characters per textfield
                if text.count < textfieldMaxCharacters {
                    textField.text = updatedText
                }

                // We filled this segment
                selectNextField(from: currentTag)

            } else if updatedText == "" {
                textField.text = updatedText
            }

            tryToVerifyCode()
        }

        return false
    }

    private func selectNextField(from field: Int) {
        let next = field + 1
        if next < textfieldsCount {
            textFields[next].becomeFirstResponder()
        } else {
            endEditing(true)
        }
    }

    private func selectPreviousField(from field: Int) {
        let previous = field - 1

        if previous < textfieldsCount && previous >= 0 {
            textFields[previous].becomeFirstResponder()
        }
    }

    private func getFinalCode() -> String {
        var finalCode = String()
        for t in textFields {
            if let text = t.text {
                finalCode.append(text)
            }
        }

        return finalCode
    }

}

extension ActivateEmergencyKitView: DeletableTextFieldDelegate {
    func textFieldDidDelete(_ textField: DeletableTextField) {
        if let text = textField.text, text == "" {
            selectPreviousField(from: textField.tag)
        }
    }
}

fileprivate extension Selector {
    static let helpLabelTap = #selector(ActivateEmergencyKitView.helpLabelTap)
}

extension ActivateEmergencyKitView: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.ActivatePDF

    func makeViewTestable() {
        self.makeViewTestable(self, using: .root)
        self.makeViewTestable(activationCodeLabel, using: .activationCodeLabel)
    }

    private func type(for index: Int) -> UIElementType {
        switch index {
        case 0: return .segment0
        case 1: return .segment1
        case 2: return .segment2
        case 3: return .segment3
        case 4: return .segment4
        case 5: return .segment5
        default: return .segment0
        }
    }

}
