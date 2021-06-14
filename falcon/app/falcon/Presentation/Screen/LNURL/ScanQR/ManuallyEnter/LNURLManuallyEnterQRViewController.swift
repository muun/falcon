//
//  ScanQRViewController.swift
//  falcon
//
//  Created by Manu Herrera on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class LNURLManuallyEnterQRViewController: MUViewController {

    @IBOutlet private weak var largeTextInputView: LargeTextInputView!
    @IBOutlet private weak var linkButton: LinkButtonView!
    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(LNURLScanQRPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "lnurl_manually_enter_qr"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        addClipboardObserver()
        addKeyboardObservers()

        presenter.setUp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeClipboardObserver()
        removeKeyboardObservers()

        presenter.tearDown()
    }

    private func setUpView() {
        setUpTextView()
        setUpButtons()
    }

    fileprivate func setUpTextView() {
        largeTextInputView.delegate = self
        largeTextInputView.bottomText = ""
        largeTextInputView.topText = L10n.LNURLManuallyEnterQRViewController.inputLabel
        _ = largeTextInputView.becomeFirstResponder()
    }

    private func setUpButtons() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.LNURLManuallyEnterQRViewController.confirm
        buttonView.isEnabled = false

        linkButton.delegate = self
        linkButton.buttonText = L10n.LNURLManuallyEnterQRViewController.pasteFromClipboard
        linkButton.isEnabled = false
    }

    override func clipboardChanged() {
        checkClipboard()
    }

    fileprivate func checkClipboard() {
        if let theString = UIPasteboard.general.string, presenter.validate(qr: theString) {
            linkButton.isEnabled = true
        }
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = L10n.LNURLManuallyEnterQRViewController.title
    }

}

extension LNURLManuallyEnterQRViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        let qr = largeTextInputView.text
        navigationController!.pushViewController(
            LNURLWithdrawViewController(qr: qr),
            animated: true
        )
    }

}

extension LNURLManuallyEnterQRViewController: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        if let myString = UIPasteboard.general.string, presenter.validate(qr: myString) {
            largeTextInputView.bottomText = ""
            largeTextInputView.text = myString
            buttonView.isEnabled = true
        } else {
            linkButton.isEnabled = false
        }
    }

}

extension LNURLManuallyEnterQRViewController: LargeTextInputViewDelegate {

    func onTextChange(textInputView: LargeTextInputView, text: String) {
        textInputView.bottomText = ""

        let isValid = presenter.validate(qr: text)
        buttonView.isEnabled = isValid

        if !isValid {
            textInputView.setError(L10n.LNURLManuallyEnterQRViewController.invalid)
        }
    }

}

extension LNURLManuallyEnterQRViewController: LNURLScanQRPresenterDelegate {

    func checkForClipboardChange() {
        checkClipboard()
    }

}

//Keyboard actions
extension LNURLManuallyEnterQRViewController {

    override func keyboardWillHide(notification: NSNotification) {
        animateButtonTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateButtonTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateButtonTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.buttonBottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension LNURLManuallyEnterQRViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.LNURLManuallyEnterQRPage

    func makeViewTestable() {
        makeViewTestable(self.view, using: .root)
        makeViewTestable(largeTextInputView, using: .input)
        makeViewTestable(buttonView, using: .submit)
    }
}
