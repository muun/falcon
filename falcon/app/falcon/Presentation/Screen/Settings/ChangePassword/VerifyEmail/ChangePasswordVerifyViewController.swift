//
//  ChangePasswordVerifyViewController.swift
//  falcon
//
//  Created by Manu Herrera on 29/07/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class ChangePasswordVerifyViewController: MUViewController {

    private var changePwVerifyEmailView: WaitForEmailView!
    private lazy var presenter = instancePresenter(ChangePasswordVerifyPresenter.init, delegate: self)
    internal var emailActionSheet: UIAlertController = UIAlertController()
    private let challengeType: String
    // This uuid is used to validate the challenge update with the backend
    private var pendingUpdateUuid: String
    // This one is to validate the verification email
    private var verificationLinkUuid: String = ""

    private var isPresenterRunning = false
    private var shouldRunVerification = false

    override var screenLoggingName: String {
        return "password_change_verify"
    }

    init(challengeType: String, pendingUpdateUuid: String) {
        self.challengeType = challengeType
        self.pendingUpdateUuid = pendingUpdateUuid

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func loadView() {
        super.loadView()

        setUpView()
    }

    private func setUpView() {
        let email = presenter.getUserEmail()
        changePwVerifyEmailView = WaitForEmailView(delegate: self)
        changePwVerifyEmailView.set(
            title: L10n.ChangePasswordVerifyViewController.s1,
            description: L10n.ChangePasswordVerifyViewController.s2(email)
                .attributedForDescription()
                .set(bold: email, color: Asset.Colors.title.color)
        )

        self.view = changePwVerifyEmailView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
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

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpEmailActionSheet()
    }

    fileprivate func setUpNavigation() {
        title = L10n.ChangePasswordVerifyViewController.s3
        navigationItem.rightBarButtonItem = .stepCounter(step: 2, end: 3)
    }

    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: .didBecomeActive,
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: .willResignActive,
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)

    }

    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    fileprivate func setUpEmailActionSheet() {
        emailActionSheet = UIAlertController(
            title: L10n.ChangePasswordVerifyViewController.s4,
            message: nil,
            preferredStyle: .actionSheet
        )

        addEmailOptions()

        // If this is == 1, that means the user doesnt have any email client app installed
        changePwVerifyEmailView.setButtonEnabled(emailActionSheet.actions.count > 1)
    }

    func runVerification(uuid: String) {
        verificationLinkUuid = uuid

        if isPresenterRunning {
            startLoading()
            presenter.runVerification(uuid: uuid)
        } else {
            shouldRunVerification = true
        }
    }

    func startLoading() {
        changePwVerifyEmailView.startLoading()
    }

    func stopLoading() {
        changePwVerifyEmailView.stopLoading()
    }

    @objc fileprivate func didBecomeActive() {
        if !isPresenterRunning {
            presenter.setUp()
            isPresenterRunning = true

            if shouldRunVerification {
                startLoading()
                presenter.runVerification(uuid: verificationLinkUuid)
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

}

extension ChangePasswordVerifyViewController: WaitForEmailViewDelegate {

    func didTapOpenEmailClient() {
        navigationController!.present(emailActionSheet, animated: true)
    }

}

extension ChangePasswordVerifyViewController: ChangePasswordVerifyPresenterDelegate {

    func onEmailVerified() {
        navigationController!.pushViewController(
            ChangePasswordEnterNewViewController(pendingUpdateUuid: pendingUpdateUuid),
            animated: true
        )
    }

    func showLoading() {
        startLoading()
    }

}

extension ChangePasswordVerifyViewController: EmailClientsPicker {}

fileprivate extension Selector {

    static let didBecomeActive = #selector(ChangePasswordVerifyViewController.didBecomeActive)
    static let willResignActive = #selector(ChangePasswordVerifyViewController.willResignActive)

}
