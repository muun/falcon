//
//  GenerateRecoveryCodeViewController.swift
//  falcon
//
//  Created by Juan Pablo Civile on 06/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class GenerateRecoveryCodeViewController: MUViewController {

    @IBOutlet private weak var buttonView: ButtonView!
    @IBOutlet private weak var recoveryView: RecoveryView!
    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!

    @IBOutlet private weak var buttonBottomConstraint: NSLayoutConstraint!

    fileprivate lazy var presenter = instancePresenter(GenerateRecoveryCodePresenter.init, delegate: self)
    fileprivate var recoveryCode: RecoveryCode?

    private var wording: SetUpRecoveryCodeWording

    override var screenLoggingName: String {
        return "set_up_recovery_code_generate"
    }

    init(wording: SetUpRecoveryCodeWording) {
        self.wording = wording

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

        presenter.setUp()
        setUpNavigation()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        presenter.tearDown()
    }

    fileprivate func setUpNavigation() {
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Constant.Images.back,
            style: .plain,
            target: self,
            action: .abortRCSetup
        )

        title = wording.navigationTitle()
        navigationItem.rightBarButtonItem = .stepCounter(step: 1, end: 3)
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpRecoveryView()
        setUpButton()

        animateView()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.GenerateRecoveryCodeViewController.s1
        let descText = L10n.GenerateRecoveryCodeViewController.s2
        titleAndDescriptionView.descriptionText = descText.attributedForDescription()
    }

    fileprivate func setUpRecoveryView() {
        recoveryView.delegate = self
        recoveryView.alpha = 0
        recoveryView.style = .display
        recoveryView.isLoading = true
    }

    fileprivate func setUpButton() {
        buttonView.delegate = self
        buttonView.buttonText = L10n.GenerateRecoveryCodeViewController.s3
        buttonView.isEnabled = false
        buttonView.alpha = 0
    }

    fileprivate func animateView() {
        titleAndDescriptionView.animate {
            self.recoveryView.animate(direction: .topToBottom, duration: .short)
        }

        buttonView.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
    }

    @objc func abortSetup() {
        let desc = L10n.GenerateRecoveryCodeViewController.s7
        let alert = UIAlertController(title: L10n.GenerateRecoveryCodeViewController.s4,
                                      message: desc,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.GenerateRecoveryCodeViewController.s5, style: .default, handler: { _ in
            alert.dismiss(animated: true)
        }))

        alert.addAction(UIAlertAction(title: L10n.GenerateRecoveryCodeViewController.s6, style: .destructive, handler: { _ in
            self.logEvent("setup_recovery_code_aborted")
            self.navigationController!.popTo(type: SecurityCenterViewController.self)
        }))

        alert.view.tintColor = Asset.Colors.muunGrayDark.color

        self.navigationController!.present(alert, animated: true)
    }

}

extension GenerateRecoveryCodeViewController: GenerateRecoveryCodePresenterDelegate {

    func didGenerate(code: RecoveryCode) {
        recoveryCode = code

        recoveryView.presetValues = code.segments
        recoveryView.isLoading = false
        buttonView.isEnabled = true
    }

}

extension GenerateRecoveryCodeViewController: RecoveryViewDelegate {}

extension GenerateRecoveryCodeViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {

        guard let recoveryCode = recoveryCode else {
            Logger.log(.err, "button was tapped with no recovery code")
            return
        }

        navigationController?.pushViewController(
            VerifyRecoveryCodeViewController(code: recoveryCode, wording: wording),
            animated: true
        )
    }

}

fileprivate extension Selector {

    static let abortRCSetup =  #selector(GenerateRecoveryCodeViewController.abortSetup)

}

extension GenerateRecoveryCodeViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.GenerateRecoveryCodePage

    func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(recoveryView, using: .codeView)
        makeViewTestable(buttonView, using: .continueButton)
    }

}
