//
//  TextInputView.swift
//  falcon
//
//  Created by Manu Herrera on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol TextInputViewDelegate: AnyObject {
    func onTextChange(textInputView: TextInputView, text: String)
}

@IBDesignable
class TextInputView: MUView {

    @IBOutlet private weak var textfieldTopLabel: UILabel!
    @IBOutlet private weak var textfield: UITextField!
    @IBOutlet private weak var textfieldBottomLabel: UILabel!
    @IBOutlet private weak var textfieldBottomBar: UIView!
    @IBOutlet private weak var textfieldBottomBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var accessoryButton: UIButton!

    fileprivate var bottomIsError = false

    weak var delegate: TextInputViewDelegate?

    public var isPassword: Bool = false {
        didSet {
            textfield.isSecureTextEntry = isPassword
            updateAccessoryButtonImage()
            setKeyboardAppearance(isPassword: isPassword)
        }
    }

    public var topLabel: String {
        get { return textfieldTopLabel.text ?? "" }
        set {
            textfieldTopLabel.text = newValue
            if !textfield.isFirstResponder {
                textfield.placeholder = newValue
            }
        }
    }

    public var bottomLabel: String {
        get { return textfieldBottomLabel.text ?? "" }
        set {
            resetBottomLabel()
            textfieldBottomLabel.text = newValue
        }
    }

    public var text: String {
        get { return textfield.text ?? "" }
        set { textfield.text = newValue }
    }

    public var placeholder: String = ""

    override func setUp() {
        isPassword = false

        setUpLabels()
        setUpTextfield()
        accessoryButton.isHidden = true

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        textfieldTopLabel.textColor = Asset.Colors.muunBlue.color
        textfieldTopLabel.font = Constant.Fonts.system(size: .helper)
        textfieldTopLabel.alpha = 0

        textfieldBottomLabel.alpha = 0

        resetBottomLabel()
    }

    fileprivate func resetBottomLabel() {
        textfieldBottomLabel.textColor = Asset.Colors.muunGrayDark.color
        textfieldBottomLabel.font = Constant.Fonts.system(size: .helper)
        bottomIsError = false
    }

    fileprivate func setUpTextfield() {
        textfield.delegate = self
        textfield.placeholder = ""
        textfield.tintColor = Asset.Colors.muunBlue.color
        textfield.font = Constant.Fonts.system(size: .h1, weight: .light)
        textfield.clearsOnBeginEditing = false
        textfield.textColor = Asset.Colors.title.color

        textfieldBottomBar.backgroundColor = Asset.Colors.muunGrayLight.color
        textfieldBottomBarHeightConstraint.constant = 1
    }

    @IBAction fileprivate func accessoryButtonTouched(_ sender: Any) {
        if isPassword {
            togglePasswordVisibility()
        } else {
            textfield.text = ""
        }
    }

    fileprivate func togglePasswordVisibility() {
        textfield.isSecureTextEntry = !textfield.isSecureTextEntry

        updateAccessoryButtonImage()
    }

    fileprivate func updateAccessoryButtonImage() {

        let image: UIImage?

        if isPassword {
            image = textfield.isSecureTextEntry
                ? Asset.Assets.passwordShow.image
                : Asset.Assets.passwordHide.image
        } else {
            image = Asset.Assets.navClose.image
        }

        accessoryButton.setImage(image, for: .normal)
    }

    override func becomeFirstResponder() -> Bool {
        return textfield.becomeFirstResponder()
    }

    fileprivate func setKeyboardAppearance(isPassword: Bool) {
        let keyboardType: UIKeyboardType = isPassword
            ? .default
            : .emailAddress

        let textType: UITextContentType = isPassword
            ? .password
            : .emailAddress

        textfield.keyboardType = keyboardType
        textfield.textContentType = textType
    }

    func setError(_ message: String) {
        textfieldBottomLabel.text = message
        textfieldBottomLabel.style = .error

        if textfieldBottomLabel.alpha == 0 {
            textfieldBottomLabel.animate(direction: .topToBottom, duration: .short)
        }

        bottomIsError = true
    }

}

extension TextInputView: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textfield.placeholder = placeholder

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textfieldTopLabel.alpha == 0 {
            textfieldTopLabel.animate(direction: .bottomToTop, duration: .short)
        }

        if textfieldBottomLabel.alpha == 0 && textfieldBottomLabel.text != "" {
            textfieldBottomLabel.animate(direction: .topToBottom, duration: .short)
        }

        textfieldBottomBar.backgroundColor = Asset.Colors.muunBlue.color
        textfieldBottomBarHeightConstraint.constant = 2

        accessoryButton.isHidden = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textfield.placeholder = textfieldTopLabel.text

        textfieldBottomBar.backgroundColor = Asset.Colors.muunGrayLight.color
        textfieldBottomBarHeightConstraint.constant = 1

        if !bottomIsError && textfieldBottomLabel.alpha != 0 {
            textfieldBottomLabel.animateOut(direction: .bottomToTop, duration: .short)
        }

        if textfield.text == "" {
            textfieldTopLabel.animateOut(direction: .topToBottom, duration: .short)
        }

        accessoryButton.isHidden = true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {

        if let text = textField.text,
            let textRange = Range(range, in: text) {

            if bottomIsError {
                textfieldBottomLabel.text = ""
                resetBottomLabel()
            }
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            delegate?.onTextChange(textInputView: self, text: updatedText)

            accessoryButton.isHidden = (updatedText == "")
        }
        return true
    }

}

extension TextInputView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.TextInputViewPage

    func makeViewTestable() {
        self.makeViewTestable(self.textfieldTopLabel, using: .topLabel)
        self.makeViewTestable(self.textfieldBottomLabel, using: .bottomLabel)
        self.makeViewTestable(self.textfield, using: .textfield)
    }
}
