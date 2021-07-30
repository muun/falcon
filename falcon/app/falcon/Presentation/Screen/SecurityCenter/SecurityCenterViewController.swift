//
//  SecurityCenterViewController.swift
//  falcon
//
//  Created by Manu Herrera on 20/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class SecurityCenterViewController: MUViewController {

    @IBOutlet fileprivate weak var stackView: UIStackView!

    @IBOutlet fileprivate weak var backUpInProgressView: UIView!
    @IBOutlet fileprivate weak var backUpInProgressProgressionBox: UIView!
    @IBOutlet fileprivate weak var backUpInProgressProgression: UIView!
    @IBOutlet fileprivate weak var backUpInProgressLabel: UILabel!
    @IBOutlet fileprivate weak var backUpInProgressProgressionWidthConstraint: NSLayoutConstraint!

    @IBOutlet fileprivate weak var backUpCompleteView: UIView!
    @IBOutlet fileprivate weak var backUpCompleteTitleLabel: UILabel!

    fileprivate let stepEmail = ActionCardView()
    fileprivate let stepRecoveryCode = ActionCardView()
    fileprivate let stepEmergencyKit = ActionCardView()
    fileprivate let exportAgainButton = LightButtonView()

    static var origin: Constant.SecurityCenterOrigin = .shieldButton

    fileprivate lazy var presenter = instancePresenter(SecurityCenterPresenter.init, delegate: self)

    override var screenLoggingName: String {
        return "security_center"
    }

    override func customLoggingParameters() -> [String: Any]? {
        return [
            "next_step": presenter.nextStepLogParam(),
            "email_status": presenter.emailStatusLogParam(),
            "origin": SecurityCenterViewController.origin.rawValue
        ]
    }

    init(origin: Constant.SecurityCenterOrigin) {
        SecurityCenterViewController.origin = origin

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        additionalSafeAreaInsets = .zero
        setUpNavigation()

        presenter.setUp()

        // These methods needs to be here so the view can refresh whenever it is popped
        decideTopViewAndExportAgainButton()
        setUpStepViewsContent()
        makeViewTestable()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)

        navigationItem.title = L10n.SecurityCenterViewController.s1
    }

    private func setUpView() {
        setUpBackUpInProgressView()
        setUpBackUpCompleteView()
        addStepViews()
        setUpExportKeysAgainButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateProgressBar()
    }

    private func setUpBackUpInProgressView() {
        backUpInProgressProgressionBox.roundCorners(cornerRadius: backUpInProgressProgressionBox.bounds.height / 2)
        backUpInProgressProgressionBox.backgroundColor = Asset.Colors.muunAlmostWhite.color

        backUpInProgressProgression.roundCorners(cornerRadius: backUpInProgressProgression.bounds.height / 2)
        backUpInProgressProgression.backgroundColor = Asset.Colors.muunRed.color

        backUpInProgressLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        backUpInProgressLabel.textColor = Asset.Colors.title.color

        stackView.setCustomSpacing(24, after: backUpInProgressView)
    }

    private func setUpBackUpCompleteView() {
        backUpCompleteTitleLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        backUpCompleteTitleLabel.textColor = Asset.Colors.title.color
        backUpCompleteTitleLabel.text = L10n.SecurityCenterViewController.s2
        stackView.setCustomSpacing(24, after: backUpCompleteView)
    }

    private func addStepViews() {
        stepEmail.delegate = self
        stackView.addArrangedSubview(stepEmail)
        stackView.setCustomSpacing(0, after: stepEmail)

        stepRecoveryCode.delegate = self
        stackView.addArrangedSubview(stepRecoveryCode)
        stackView.setCustomSpacing(0, after: stepRecoveryCode)

        stepEmergencyKit.delegate = self
        stackView.addArrangedSubview(stepEmergencyKit)
        stackView.setCustomSpacing(0, after: stepEmergencyKit)
    }

    private func setUpStepViewsContent() {
        stepEmail.setUp(actionCard: presenter.getEmailCard())
        stepRecoveryCode.setUp(actionCard: presenter.getRecoveryCodeCard())
        stepEmergencyKit.setUp(actionCard: presenter.getEmergencyKitCard())
    }

    private func setUpExportKeysAgainButton() {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(container)

        exportAgainButton.translatesAutoresizingMaskIntoConstraints = false
        exportAgainButton.delegate = self
        exportAgainButton.isHidden = true
        container.addSubview(exportAgainButton)

        NSLayoutConstraint.activate([
            exportAgainButton.topAnchor.constraint(equalTo: container.topAnchor),
            exportAgainButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            exportAgainButton.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            container.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])
    }

    private func updateProgressBar() {
        backUpInProgressProgressionWidthConstraint =
            backUpInProgressProgressionWidthConstraint.setMultiplier(multiplier: presenter.backUpProgressMultiplier())

        UIView.animate(withDuration: 0.3) {
            self.backUpInProgressView.layoutIfNeeded()
        }
    }

    private func decideTopViewAndExportAgainButton() {
        setExportAgainButtonText()

        if presenter.isBackUpProgressFinished() {
            backUpInProgressView.isHidden = true
            backUpCompleteView.isHidden = false
            exportAgainButton.isHidden = false

        } else {
            backUpInProgressProgression.backgroundColor = backUpProgressColor()
            backUpInProgressLabel.text = presenter.backUpProgressMessage()

            backUpInProgressView.isHidden = false
            backUpCompleteView.isHidden = true
            exportAgainButton.isHidden = true
        }
    }

    private func setExportAgainButtonText() {
        if presenter.didExportEmergencyKit() {
            exportAgainButton.buttonText = L10n.SecurityCenterViewController.s3
        } else {
            exportAgainButton.buttonText = L10n.SecurityCenterViewController.s4
        }
    }

    private func backUpProgressColor() -> UIColor {
        if presenter.isBackUpProgressStarted() {
            return Asset.Colors.muunGreen.color
        }

        return Asset.Colors.muunRed.color
    }

}

extension SecurityCenterViewController: SecurityCenterPresenterDelegate {}

extension SecurityCenterViewController: LightButtonViewDelegate {

    func lightButton(didPress lightButton: LightButtonView) {
        navigationController!.pushViewController(EmergencyKitSlidesViewController(), animated: true)
    }

}

extension SecurityCenterViewController: ActionCardDelegate {

    func push(nextViewController: UIViewController) {
        navigationController!.pushViewController(nextViewController, animated: true)
    }

}

extension SecurityCenterViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.SecurityCenterPage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(stepEmail, using: .emailSetup)
        makeViewTestable(stepRecoveryCode, using: .recoveryCodeSetup)
        makeViewTestable(stepEmergencyKit, using: .emergencyKit)
        makeViewTestable(exportAgainButton, using: .exportEmergencyKitAgainButton)

        if presenter.didExportEmergencyKit() {
            makeViewTestable(stepEmergencyKit, using: .recoveryTool)
        }

    }

}
