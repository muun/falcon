//
//  ScanQRViewController.swift
//  falcon
//
//  Created by Manu Herrera on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class ManuallyEnterQRViewController: MUViewController {

    @IBOutlet private weak var largeTextInputView: LargeTextInputView!
    @IBOutlet private weak var linkButton: LinkButtonView!
    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pasteControlContainer: UIView!

    fileprivate lazy var presenter = instancePresenter(AddressInputPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "manually_enter_qr"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        if #unavailable(iOS 16.0) {
            addClipboardObserver()
        }

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

        if #unavailable(iOS 16.0) {
            removeClipboardObserver()
        }
        removeKeyboardObservers()

        presenter.tearDown()
    }

    private func setUpView() {
        setUpButtons()
        setUpNativePasteControl()
        setUpTextView()
        setUpCopyButton()
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
        if #unavailable(iOS 16.0) {
            linkButton.delegate = self
            linkButton.buttonText = L10n.ManuallyEnterQRViewController.s3
            linkButton.isEnabled = false
        }
    }

    override func clipboardChanged() {
        if #unavailable(iOS 16.0) {
            checkClipboard()
        }
    }

    fileprivate func checkClipboard() {
        if #unavailable(iOS 16.0) {
            if let theString = UIPasteboard.general.string {
                linkButton.isEnabled = presenter.isValid(rawAddress: theString)
            }
        }
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = L10n.ManuallyEnterQRViewController.s4
    }

    fileprivate func pushToNewOperation(_ paymentIntent: PaymentIntent) {

        switch paymentIntent {
        case .lnurlWithdraw(let lnurl):
            navigationController!.pushViewController(
                LNURLWithdrawViewController(qr: lnurl),
                animated: true
            )
        default:
            navigationController!.pushViewController(
                NewOperationViewController(
                    paymentIntent: paymentIntent,
                    origin: .manualInput
                ),
                animated: true
            )
        }
    }

}

extension ManuallyEnterQRViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        do {
            let paymentIntent = try presenter.getPaymentIntent(for: largeTextInputView.text)

            pushToNewOperation(paymentIntent)
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
            setUserOwnAddressWarningIfNeeded(address: myString)
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

            guard validAddress else {
                textInputView.setError(L10n.ManuallyEnterQRViewController.s5)
                return
            }

            setUserOwnAddressWarningIfNeeded(address: text)
        } else {
            buttonView.isEnabled = false
        }
    }
}

extension ManuallyEnterQRViewController: AddressInputPresenterDelegate {
    func checkForClipboardChange() {
        if #unavailable(iOS 16.0) {
            checkClipboard()
        }
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

extension ManuallyEnterQRViewController {
    override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        return itemProviders.first?.canLoadObject(ofClass: String.self) ?? false
    }

    override func paste(itemProviders: [NSItemProvider]) {
        if #available(iOS 16.0, *) {
            guard let clipboardValue = itemProviders.first else {
                return
            }

            if clipboardValue.canLoadObject(ofClass: String.self) {
                _ = clipboardValue.loadObject(ofClass: String.self) { [weak self] textFromClipboard, error in
                    guard error == nil else {
                        error.map { Logger.log(error: $0) }
                        self?.showError(error: L10n.ManuallyEnterQRViewController.s8)
                        return
                    }
                    textFromClipboard.map { self?.onTextRetrievedFromUIPasteControl(textFromClipboard: $0) }
                }
            } else {
                // paste button should never be enabled with something that is not an String.
                Logger.log(error: NSError(domain: "paste_button_enabled_with_not_supported_content", code: 19993))
            }
        }
    }
}

private extension ManuallyEnterQRViewController {
    func onTextRetrievedFromUIPasteControl(textFromClipboard: String) {
        let address = textFromClipboard.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)

        guard address.count > 0 else {
            self.showError(error: L10n.ManuallyEnterQRViewController.s7)
            return
        }

        guard self.presenter.isValid(rawAddress: address) else {
            DispatchQueue.main.async {
                self.largeTextInputView.text = address
            }
            self.showError(error: L10n.ManuallyEnterQRViewController.s5)
            return
        }

        DispatchQueue.main.async {
            if self.presenter.isOwnAddress(address) {
                self.largeTextInputView.setWarning(L10n.ManuallyEnterQRViewController.s6)
            } else {
                self.largeTextInputView.bottomText = ""
            }
            self.largeTextInputView.text = address
            self.buttonView.isEnabled = true
        }
    }

    func setUpNativePasteControl() {
        if #available(iOS 16.0, *) {
            let configuration = UIPasteControl.Configuration()
            configuration.cornerStyle = .medium
            configuration.displayMode = .labelOnly
            configuration.baseBackgroundColor = Asset.Colors.muunBlue.color
            let pasteControl = UIPasteControl(configuration: configuration)
            pasteControl.target = self

            pasteConfiguration = UIPasteConfiguration(forAccepting: String.self)
            pasteControlContainer.addSubviewWrappingParent(child: pasteControl)
        }
    }

    func showError(error: String) {
        DispatchQueue.main.async {
            self.buttonView.isEnabled = false
            self.largeTextInputView.setError(error)
        }
    }

    func setUserOwnAddressWarningIfNeeded(address: String) {
        if presenter.isOwnAddress(address) {
            self.largeTextInputView.setWarning(L10n.ManuallyEnterQRViewController.s6)
        }
    }

    func setUpCopyButton() {
        if #available(iOS 16.0, *) {
            linkButton.isHidden = true
            pasteControlContainer.isHidden = false
        } else {
            pasteControlContainer.isHidden = true
        }
    }
}
