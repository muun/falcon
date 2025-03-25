//
//  FinishEmailSetupViewController.swift
//  falcon
//
//  Created by Manu Herrera on 21/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit


class FinishEmailSetupViewController: MUViewController {

    @IBOutlet private weak var button: ButtonView!
    @IBOutlet private weak var stackView: UIStackView!

    private let titleAndDescriptionView = TitleAndDescriptionView()
    private let firstCheck = CheckView()
    private let secondCheck = CheckView()
    private let whyLabel = UILabel()

    fileprivate lazy var presenter = instancePresenter(FinishEmailSetupPresenter.init, delegate: self)
    private let passphrase: String
    private var wording: SetUpEmailWording

    override var screenLoggingName: String {
        return "finish_email_setup"
    }

    init(passphrase: String, wording: SetUpEmailWording) {
        self.passphrase = passphrase
        self.wording = wording

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()

        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    private func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        title = wording.navigationTitle()
        navigationItem.rightBarButtonItem = .stepCounter(step: 4, end: 4)

        let backImage = Constant.Images.back
        let newBackButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: .backButtonTouched)
        navigationItem.leftBarButtonItem = newBackButton
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpChecks()
        setUpButton()
        setUpWhyButton()
        setUpStackView()

        makeViewTestable()

        animateView()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.FinishEmailSetupViewController.s1
        titleAndDescriptionView.descriptionText = nil
    }

    fileprivate func setUpStackView() {
        stackView.addArrangedSubview(titleAndDescriptionView)
        stackView.setCustomSpacing(16, after: titleAndDescriptionView)
        stackView.addArrangedSubview(firstCheck)
        stackView.addArrangedSubview(secondCheck)
        stackView.setCustomSpacing(16, after: secondCheck)
        stackView.addArrangedSubview(whyLabel)
    }

    fileprivate func setUpButton() {
        button.delegate = self
        button.buttonText = L10n.FinishEmailSetupViewController.s2
        button.isEnabled = false
        button.alpha = 0
    }

    fileprivate func setUpChecks() {
        firstCheck.labelText = wording.firstUnderstandingCheck()
        firstCheck.delegate = self
        firstCheck.alpha = 0
        secondCheck.labelText = wording.secondUnderstandingCheck()
        secondCheck.delegate = self
        secondCheck.alpha = 0
    }

    fileprivate func setUpWhyButton() {
        whyLabel.style = .description

        let text = L10n.FinishEmailSetupViewController.s3
        whyLabel.attributedText = text
            .attributedForDescription()
            .set(underline: text, color: Asset.Colors.muunBlue.color)

        whyLabel.numberOfLines = 0
        whyLabel.alpha = 0
        whyLabel.isUserInteractionEnabled = true
        whyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .whyTouched))
    }

    @objc func whyTouched() {
        let overlayVc = BottomDrawerOverlayViewController(info: BottomDrawerInfo.signUpPassword)
        navigationController!.present(overlayVc, animated: true)
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate()
        firstCheck.animate(direction: .topToBottom, duration: .short)
        secondCheck.animate(direction: .topToBottom, duration: .short)
        whyLabel.animate(direction: .topToBottom, duration: .short)
        button.animate(direction: .bottomToTop, duration: .medium, delay: .short)
    }

    @objc func presentAlertView() {
        let msg = L10n.FinishEmailSetupViewController.s4
        let alert = UIAlertController(
            title: L10n.FinishEmailSetupViewController.s5,
            message: msg,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.FinishEmailSetupViewController.s6, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(
            UIAlertAction(title: L10n.FinishEmailSetupViewController.s7, style: .destructive, handler: { _ in
                self.logEvent("email_setup_aborted")
                self.navigationController!.popTo(type: SecurityCenterViewController.self)
            })
        )

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.present(alert, animated: true)
    }

}

extension FinishEmailSetupViewController: FinishEmailSetupPresenterDelegate {

    func setLoading(_ isLoading: Bool) {
        button.isLoading = isLoading
    }

    func passwordSetUp() {
        logEvent("email_setup_successful")
        navigationController!.pushViewController(
            FeedbackViewController(feedback: FeedbackInfo.emailSetupSuccess(wording: wording)),
            animated: true
        )
    }

}

extension FinishEmailSetupViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        presenter.requestChallenge(password: passphrase)
    }

}

extension FinishEmailSetupViewController: CheckViewDelegate {

    func onCheckChanged(checked: Bool) {
        button.isEnabled = firstCheck.isChecked && secondCheck.isChecked
    }

}

fileprivate extension Selector {

    static let backButtonTouched = #selector(FinishEmailSetupViewController.presentAlertView)
    static let whyTouched = #selector(FinishEmailSetupViewController.whyTouched)

}

extension FinishEmailSetupViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.FinishEmailSetupPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(firstCheck, using: .firstCheck)
        makeViewTestable(secondCheck, using: .secondCheck)
        makeViewTestable(button, using: .continueButton)
    }

}
