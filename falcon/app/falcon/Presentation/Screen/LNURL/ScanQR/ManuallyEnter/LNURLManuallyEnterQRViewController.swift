//
//  ScanQRViewController.swift
//  falcon
//
//  Created by Manu Herrera on 03/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

// TODO: implement a strategy pattern for this and for manuallyEnterQRViewController
class LNURLManuallyEnterQRViewController: MUViewController {

    @IBOutlet private weak var largeTextInputView: LargeTextInputView!
    @IBOutlet private weak var linkButton: LinkButtonView!
    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pasteControlContainer: UIView!

    fileprivate lazy var presenter = instancePresenter(LNURLScanQRPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "lnurl_manually_enter_qr"
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
        setUpTextView()
        setUpButtons()
        setUpNativePasteControl()
        setUpCopyButton()
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
        if #unavailable(iOS 16.0) {
            checkClipboard()
        }
    }

    fileprivate func checkClipboard() {
        if #unavailable(iOS 16.0), let theString = UIPasteboard.general.string, presenter.validate(qr: theString) {
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
        if #unavailable(iOS 16.0) {
            checkClipboard()
        }
    }

}

// Keyboard actions
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

extension LNURLManuallyEnterQRViewController {
    override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        return itemProviders.first?.canLoadObject(ofClass: String.self) ?? false
    }

    override func paste(itemProviders: [NSItemProvider]) {
        if #available(iOS 16.0, *) {
            guard let clipboardValue = itemProviders.first else {
                self.showError(error: L10n.LNURLManuallyEnterQRViewController.emptyClipboard)
                return
            }

            if clipboardValue.canLoadObject(ofClass: String.self) {
                _ = clipboardValue.loadObject(ofClass: String.self) { [weak self] textFromClipboard, error in
                    guard error == nil else {
                        error.map { Logger.log(error: $0) }
                        self?.showError(error: L10n.LNURLManuallyEnterQRViewController.unexpectedError)
                        DispatchQueue.main.async {
                            self?.largeTextInputView.text = ""
                        }
                        return
                    }
                    textFromClipboard.map { self?.onTextRetrievedFromUIPasteControl(valueFromClipboard: $0) }
                }
            } else {
                // Paste button should never be enabled with something that is not an String.
                Logger.log(error: NSError(domain: "paste_button_enabled_with_not_supported_content", code: 19993))
            }
        }
    }
}

private extension LNURLManuallyEnterQRViewController {
    func onTextRetrievedFromUIPasteControl(valueFromClipboard: String) {
        let linkRemovingSpaces = valueFromClipboard.replacingOccurrences(of: " ", with: "",
                                                                         options: .literal,
                                                                         range: nil)

        guard linkRemovingSpaces.count > 0 else {
            self.showError(error: L10n.LNURLManuallyEnterQRViewController.emptyClipboard)
            return
        }
        guard self.presenter.validate(qr: linkRemovingSpaces) else {
            DispatchQueue.main.async {
                self.largeTextInputView.text = linkRemovingSpaces
            }
            self.showError(error: L10n.LNURLManuallyEnterQRViewController.invalid)
            return
        }

        DispatchQueue.main.async {
            self.largeTextInputView.bottomText = ""
            self.largeTextInputView.text = linkRemovingSpaces
            self.buttonView.isEnabled = true
            _ = self.largeTextInputView.becomeFirstResponder()
        }
    }

    func showError(error: String) {
        DispatchQueue.main.async {
            self.buttonView.isEnabled = false
            self.largeTextInputView.setError(error)
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

    func setUpCopyButton() {
        if #available(iOS 16.0, *) {
            linkButton.isHidden = true
            pasteControlContainer.isHidden = false
        } else {
            pasteControlContainer.isHidden = true
        }
    }
}
