//
//  ScanQRViewController.swift
//  falcon
//
//  Created by Manu Herrera on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class ManuallyEnterQRViewController: MUViewController {

    @IBOutlet private weak var largeTextInputView: LargeTextInputView!
    @IBOutlet private weak var linkButton: LinkButtonView!
    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(ScanQRPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "manually_enter_qr"
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
        largeTextInputView.topText = L10n.ManuallyEnterQRViewController.s1
        _ = largeTextInputView.becomeFirstResponder()
    }

    private func setUpButtons() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.ManuallyEnterQRViewController.s2
        buttonView.isEnabled = false

        linkButton.delegate = self
        linkButton.buttonText = L10n.ManuallyEnterQRViewController.s3
        linkButton.isEnabled = false
    }

    override func clipboardChanged() {
        checkClipboard()
    }

    fileprivate func checkClipboard() {
        if let theString = UIPasteboard.general.string, !presenter.isOwnAddress(theString) {
            linkButton.isEnabled = presenter.isValid(rawAddress: theString)
        }
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = L10n.ManuallyEnterQRViewController.s4
    }

}

extension ManuallyEnterQRViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        do {
            let paymentRequestType = try presenter.getPaymentIntent(for: largeTextInputView.text)
            navigationController!.pushViewController(
                NewOperationViewController(configuration:
                    .standard(paymentIntent: paymentRequestType, origin: .manualInput)
                ),
                animated: true
            )
        } catch {
            largeTextInputView.setError(L10n.ManuallyEnterQRViewController.s5)
        }
    }

}

extension ManuallyEnterQRViewController: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        if let myString = UIPasteboard.general.string, presenter.isValid(rawAddress: myString) {
            largeTextInputView.bottomText = ""
            largeTextInputView.text = myString
            buttonView.isEnabled = true
        } else {
            linkButton.isEnabled = false
        }
    }

}

extension ManuallyEnterQRViewController: LargeTextInputViewDelegate {

    func onTextChange(textInputView: LargeTextInputView, text: String) {
        textInputView.bottomText = ""

        if text.count >= 34 {
            let validAddress = presenter.isValid(rawAddress: text)
            buttonView.isEnabled = validAddress

            if !validAddress {
                textInputView.setError(L10n.ManuallyEnterQRViewController.s5)
            }

        } else {
            buttonView.isEnabled = false
        }
    }

}

extension ManuallyEnterQRViewController: ScanQRPresenterDelegate {

    func checkForClipboardChange() {
        checkClipboard()
    }

}

// Keyboard actions
extension ManuallyEnterQRViewController {

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

extension ManuallyEnterQRViewController: UITestablePage {
    typealias UIElementType = UIElements.Pages.ManuallyEnterQRPage

    func makeViewTestable() {
        makeViewTestable(self.view, using: .root)
        makeViewTestable(largeTextInputView, using: .input)
        makeViewTestable(buttonView, using: .submit)
    }
}
