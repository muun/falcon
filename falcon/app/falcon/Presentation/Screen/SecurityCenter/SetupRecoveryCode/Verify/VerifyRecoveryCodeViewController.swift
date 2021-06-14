//
//  VerifyRecoveryCodeViewController.swift
//  falcon
//
//  Created by Manu Herrera on 30/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class VerifyRecoveryCodeViewController: MUViewController {

    @IBOutlet private weak var recoveryView: RecoveryView!
    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!
    @IBOutlet private weak var hintLabel: UILabel!
    @IBOutlet private weak var continueButton: ButtonView!
    @IBOutlet private weak var continueButtonBottomConstraint: NSLayoutConstraint!

    private var recoveryCode: RecoveryCode
    private var wording: SetUpRecoveryCodeWording

    override var screenLoggingName: String {
        return "set_up_recovery_code_verify"
    }

    init(code: RecoveryCode, wording: SetUpRecoveryCodeWording) {
        self.recoveryCode = code
        self.wording = wording

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addKeyboardObservers()

        setUpNavigation()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeKeyboardObservers()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        navigationItem.rightBarButtonItem = .stepCounter(step: 2, end: 3)
        title = wording.navigationTitle()
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpRecoveryView()
        setUpButton()

        animateView()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.VerifyRecoveryCodeViewController.s1
        titleAndDescriptionView.descriptionText = nil

        hintLabel.text = L10n.VerifyRecoveryCodeViewController.s2
        hintLabel.style = .error
        hintLabel.isHidden = true
    }

    fileprivate func setUpRecoveryView() {
        recoveryView.delegate = self
        recoveryView.alpha = 0
        recoveryView.style = .editable
        recoveryView.isLoading = false
    }

    fileprivate func setUpButton() {
        continueButton.delegate = self
        continueButton.buttonText = L10n.VerifyRecoveryCodeViewController.s3
        continueButton.isEnabled = false
        continueButton.alpha = 0
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate {
            self.recoveryView.animate(direction: .topToBottom, duration: .short)
            self.continueButton.animate(direction: .topToBottom, duration: .short)
        }
    }

}

extension VerifyRecoveryCodeViewController: RecoveryViewDelegate {

    enum RecoveryCodeErrorParam: String {
        case did_not_match
    }

    func recoveryViewDidChange(_ recoveryView: RecoveryView, code: RecoveryCode?) {

        guard let code = code else {
            continueButton.isEnabled = false
            hintLabel.isHidden = true
            return
        }

        let isValidCode = (recoveryCode == code)

        hintLabel.isHidden = isValidCode
        continueButton.isEnabled = isValidCode

        if !isValidCode {
            logEvent("recovery_code", parameters: ["error": RecoveryCodeErrorParam.did_not_match.rawValue])
        }
    }

}

extension VerifyRecoveryCodeViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        navigationController!.pushViewController(
            FinishRecoveryCodeSetupViewController(code: recoveryCode, wording: wording),
            animated: true
        )
    }

}

// Keyboard actions
extension VerifyRecoveryCodeViewController {

    override func keyboardWillHide(notification: NSNotification) {
        animateScrollTransition(height: 0)
    }

    override func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = getKeyboardSize(notification) {
            let safeAreaBottomHeight = view.safeAreaInsets.bottom
            animateScrollTransition(height: keyboardSize.height - safeAreaBottomHeight)
        }
    }

    fileprivate func animateScrollTransition(height: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            self.continueButtonBottomConstraint.constant = height

            self.view.layoutIfNeeded()
        }
    }

}

extension VerifyRecoveryCodeViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.VerifyRecoveryCodePage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(recoveryView, using: .codeView)
        makeViewTestable(hintLabel, using: .errorLabel)
        makeViewTestable(continueButton, using: .continueButton)
    }

}
