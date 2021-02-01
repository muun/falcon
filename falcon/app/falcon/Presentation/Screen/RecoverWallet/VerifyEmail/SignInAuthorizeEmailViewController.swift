//
//  SignInAuthorizeEmailViewController.swift
//  falcon
//
//  Created by Manu Herrera on 29/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

class SignInAuthorizeEmailViewController: MUViewController {

    fileprivate lazy var presenter = instancePresenter(SignInAuthorizeEmailPresenter.init, delegate: self)
    private var verifyView: WaitForEmailView!

    private var nextVc: UIViewController!
    internal var emailActionSheet: UIAlertController = UIAlertController()
    private var isPresenterRunning = false
    private var shouldRunVerification = false
    private var uuid: String?

    override var screenLoggingName: String {
        return "authorize_email"
    }

    init(nextVc: UIViewController) {
        self.nextVc = nextVc

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
        let email = presenter.getUserEmail()
        verifyView = WaitForEmailView(delegate: self)
        verifyView.set(
            title: L10n.SignInAuthorizeEmailViewController.s1,
            description: L10n.SignInAuthorizeEmailViewController.s4(email)
                .attributedForDescription()
                .set(bold: email, color: Asset.Colors.title.color)
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
        title = L10n.SignInAuthorizeEmailViewController.s2
    }

    fileprivate func setUpEmailActionSheet() {
        emailActionSheet = UIAlertController(
            title: L10n.SignInAuthorizeEmailViewController.s3,
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

extension SignInAuthorizeEmailViewController: WaitForEmailViewDelegate {

    func didTapOpenEmailClient() {
        navigationController!.present(emailActionSheet, animated: true)
    }

}

extension SignInAuthorizeEmailViewController: SignInAuthorizeEmailPresenterDelegate {

    func onEmailVerified() {
        emailActionSheet.dismiss(animated: true, completion: nil)
        verifyView.stopLoading()
        navigationController!.pushViewController(nextVc, animated: false)
    }

    func emailExpired() {
        emailActionSheet.dismiss(animated: true, completion: nil)
        verifyView.displayErrorMessage()
    }

}

extension SignInAuthorizeEmailViewController: EmailClientsPicker {}

fileprivate extension Selector {

    static let didBecomeActive = #selector(SignInAuthorizeEmailViewController.didBecomeActive)
    static let willResignActive = #selector(SignInAuthorizeEmailViewController.willResignActive)

}
