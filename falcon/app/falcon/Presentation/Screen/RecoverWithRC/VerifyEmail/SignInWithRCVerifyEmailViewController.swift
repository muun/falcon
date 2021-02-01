//
//  SignInWithRCVerifyEmailViewController.swift
//  falcon
//
//  Created by Manu Herrera on 21/09/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class SignInWithRCVerifyEmailViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(
        SignInWithRCVerifyEmailPresenter.init,
        delegate: self,
        state: recoveryCode
    )
    private var verifyView: WaitForEmailView!

    internal var emailActionSheet: UIAlertController = UIAlertController()
    private var isPresenterRunning = false
    private var shouldRunVerification = false
    private var uuid: String?

    private var obfuscatedEmail: String
    private var recoveryCode: String

    override var screenLoggingName: String {
        return "sign_in_with_rc_authorize_email"
    }

    init(obfuscatedEmail: String, recoveryCode: String) {
        self.obfuscatedEmail = obfuscatedEmail
        self.recoveryCode = recoveryCode

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        super.loadView()

        setUpView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpEmailActionSheet()
    }

    private func setUpView() {
        verifyView = WaitForEmailView(delegate: self)
        verifyView.set(
            title: L10n.SignInWithRCVerifyEmailViewController.s1,
            description: L10n.SignInWithRCVerifyEmailViewController.s4(obfuscatedEmail)
                .attributedForDescription()
                .set(bold: obfuscatedEmail, color: Asset.Colors.title.color)
        )

        self.view = verifyView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        addObservers()
        setUpNavigation()

        presenter.setUp()
        isPresenterRunning = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        removeObservers()

        presenter.tearDown()
        isPresenterRunning = false
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: .didBecomeActive,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: .willResignActive,
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }

    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        title = L10n.SignInWithRCVerifyEmailViewController.s2
    }

    fileprivate func setUpEmailActionSheet() {
        emailActionSheet = UIAlertController(
            title: L10n.SignInWithRCVerifyEmailViewController.s3,
            message: nil,
            preferredStyle: .actionSheet
        )

        addEmailOptions()

        // If this is == 1, that means the user doesnt have any email client app installed
        verifyView.setButtonEnabled(emailActionSheet.actions.count > 1)
    }

    @objc fileprivate func didBecomeActive() {
        if !isPresenterRunning {
            presenter.setUp()
            isPresenterRunning = true

            if shouldRunVerification, let uuid = uuid {
                verifyView.startLoading()
                presenter.runVerification(uuid: uuid)
            }
        }
    }

    @objc fileprivate func willResignActive() {
        emailActionSheet.dismiss(animated: true, completion: nil)

        if isPresenterRunning {
            presenter.tearDown()
            isPresenterRunning = false
        }
    }

    func runVerification(uuid: String) {
        self.uuid = uuid

        if isPresenterRunning {
            verifyView.startLoading()
            presenter.runVerification(uuid: uuid)
        } else {
            shouldRunVerification = true
        }
    }

}

extension SignInWithRCVerifyEmailViewController: WaitForEmailViewDelegate {

    func didTapOpenEmailClient() {
        navigationController!.present(emailActionSheet, animated: true)
    }

}

extension SignInWithRCVerifyEmailViewController: SignInWithRCVerifyEmailPresenterDelegate {

    func signInCompleted() {
        logEvent("sign_in_successful", parameters: ["type": "recovery_code_and_email"])

        emailActionSheet.dismiss(animated: true, completion: nil)
        verifyView.stopLoading()
        navigationController!.pushViewController(
            PinViewController(state: .choosePin, isExistingUser: true),
            animated: false
        )
    }

    func emailExpired() {
        emailActionSheet.dismiss(animated: true, completion: nil)
        verifyView.displayErrorMessage()
    }

}

extension SignInWithRCVerifyEmailViewController: EmailClientsPicker {}

fileprivate extension Selector {

    static let didBecomeActive = #selector(SignInWithRCVerifyEmailViewController.didBecomeActive)
    static let willResignActive = #selector(SignInWithRCVerifyEmailViewController.willResignActive)

}
