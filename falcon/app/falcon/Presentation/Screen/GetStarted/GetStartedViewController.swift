//
//  GetStartedViewController.swift
//  falcon
//
//  Created by Manu Herrera on 10/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import Lottie

class GetStartedViewController: MUViewController {

    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var muunLogo: AnimationView!
    @IBOutlet private weak var createWalletButton: ButtonView!
    @IBOutlet private weak var recoverWalletButton: LinkButtonView!

    override var screenLoggingName: String {
        return "get_started"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        beginShowUpAnimation()

        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController!.setNavigationBarHidden(true, animated: true)
    }

    private func setUpView() {
        setUpLabels()
        setUpButtons()
        setUpLottieView()
    }

    private func setUpLabels() {
        descriptionLabel.attributedText = L10n.GetStartedViewController.s1
            .attributedForDescription(alignment: .center)
        descriptionLabel.textColor = Asset.Colors.title.color
    }

    private func setUpButtons() {
        createWalletButton.delegate = self
        createWalletButton.buttonText = L10n.GetStartedViewController.s5
        createWalletButton.isEnabled = true

        recoverWalletButton.delegate = self
        recoverWalletButton.buttonText = L10n.GetStartedViewController.s6
        recoverWalletButton.isEnabled = true
    }

    private func setUpLottieView() {
        muunLogo.animation = Animation.named("animation")
        muunLogo.animationSpeed = 1.25
        muunLogo.contentMode = .scaleAspectFit
        muunLogo.loopMode = .playOnce
    }

    private func beginShowUpAnimation() {
        hideEverything()

        muunLogo.play(toProgress: 0.7) { (_) in
            UIView.animate(withDuration: 0.4, animations: {
                let scale = CGAffineTransform(scaleX: 0.8, y: 0.8)
                let translate = CGAffineTransform(translationX: 0, y: -80)
                self.muunLogo.transform = scale.concatenating(translate)

                self.descriptionLabel.animate(direction: .bottomToTop, duration: .short, delay: .short)
                self.createWalletButton.animate(direction: .bottomToTop, duration: .short, delay: .short2)
                self.recoverWalletButton.animate(direction: .bottomToTop, duration: .short, delay: .short2)
                self.muunLogo.pause()
            })
        }
    }

    private func hideEverything() {
        descriptionLabel.alpha = 0
        createWalletButton.alpha = 0
        recoverWalletButton.alpha = 0
    }

}

extension GetStartedViewController: ButtonViewDelegate {
    func button(didPress button: ButtonView) {
        navigationController!.pushViewController(
            PinViewController(state: .choosePin, isExistingUser: false, lockDelegate: nil),
            animated: true
        )
    }
}

extension GetStartedViewController: LinkButtonViewDelegate {
    func linkButton(didPress linkButton: LinkButtonView) {
        navigationController!.pushViewController(SignInEmailViewController(), animated: true)
    }
}

extension GetStartedViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.GetStartedPage

    func makeViewTestable() {
        self.makeViewTestable(self.view, using: .root)
        self.makeViewTestable(self.createWalletButton, using: .createWalletButton)
        self.makeViewTestable(self.recoverWalletButton, using: .recoverWalletButton)
    }

}
