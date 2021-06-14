//
//  TextInputView.swift
//  falcon
//
//  Created by Manu Herrera on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol LargeTextInputViewDelegate: AnyObject {
    func onTextChange(textInputView: LargeTextInputView, text: String)
}

@IBDesignable
class LargeTextInputView: MUView {

    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var bottomBar: UIView!
    @IBOutlet private weak var bottomBarHeightConstraint: NSLayoutConstraint!

    weak var delegate: LargeTextInputViewDelegate?

    public var topText: String {
        get { return topLabel.text ?? "" }
        set { topLabel.text = newValue }
    }

    public var bottomText: String {
        get { return bottomLabel.text ?? "" }
        set {
            resetBottomLabel()
            bottomLabel.text = newValue
        }
    }

    public var text: String {
        get { return textView.text ?? "" }
        set { textView.text = newValue }
    }

    override func setUp() {
        setUpLabels()
        setUpTextView()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        topLabel.textColor = Asset.Colors.muunBlue.color
        topLabel.font = Constant.Fonts.system(size: .helper)
        topLabel.alpha = 0

        resetBottomLabel()
    }

    fileprivate func resetBottomLabel() {
        bottomLabel.textColor = Asset.Colors.muunGrayDark.color
        bottomLabel.font = Constant.Fonts.system(size: .helper, weight: .medium)
    }

    fileprivate func setUpTextView() {
        textView.delegate = self
        textView.tintColor = Asset.Colors.muunBlue.color
        textView.font = Constant.Fonts.system(size: .h1, weight: .light)
        textView.text = ""
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textColor = Asset.Colors.title.color

        bottomBar.backgroundColor = Asset.Colors.muunGrayLight.color
        bottomBarHeightConstraint.constant = 1
    }

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    func setError(_ message: String) {
        bottomLabel.text = message
        bottomLabel.style = .error

        bottomBar.backgroundColor = Asset.Colors.muunRed.color
        topLabel.style = .error
    }

}

extension LargeTextInputView: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        topLabel.animate(direction: .bottomToTop, duration: .short)

        bottomBar.backgroundColor = Asset.Colors.muunBlue.color
        bottomBarHeightConstraint.constant = 2
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        topLabel.alpha = 0

        bottomBar.backgroundColor = Asset.Colors.muunGrayLight.color
        bottomBarHeightConstraint.constant = 1
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText string: String) -> Bool {

        bottomBar.backgroundColor = Asset.Colors.muunBlue.color
        topLabel.textColor = Asset.Colors.muunBlue.color
        topLabel.font = Constant.Fonts.system(size: .helper)

        if let text = textView.text,
            let textRange = Range(range, in: text) {

            let updatedText = text.replacingCharacters(in: textRange, with: string)
            delegate?.onTextChange(textInputView: self, text: updatedText)
        }

        return true
    }

}

extension LargeTextInputView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.LargeTextInputViewPage

    func makeViewTestable() {
        self.makeViewTestable(self.topLabel, using: .topLabel)
        self.makeViewTestable(self.bottomLabel, using: .bottomLabel)
        self.makeViewTestable(self.textView, using: .textView)
    }
}
