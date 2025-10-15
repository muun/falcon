//
//  FeedbackViewController.swift
//  falcon
//
//  Created by Manu Herrera on 18/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import Lottie

class FeedbackViewController: MUViewController {

    @IBOutlet fileprivate weak var feedbackIImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var buttonView: ButtonView!
    @IBOutlet fileprivate weak var animationView: LottieAnimationView!
    fileprivate let blockClock = BlockClockView()
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!

    private var feedback: FeedbackModel

    override var screenLoggingName: String {
        return "feedback"
    }

    override func customLoggingParameters() -> [String: Any]? {
        return feedback.loggingParameters
    }

    init(feedback: FeedbackModel) {
        self.feedback = feedback

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
        makeViewTestable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setUpNavigation()
    }

    fileprivate func setUpNavigation() {
        if feedback.buttonText != nil {
            navigationController!.setNavigationBarHidden(true, animated: true)
        }
    }

    fileprivate func setUpView() {
        setUpLabels()
        setUpButton()
        setUpImageView()
        setUpLottieView()
        setUpBlockClock()

        if feedback.blocksLeft != nil {
            stackView.setCustomSpacing(.bigSpacing, after: blockClock)
        } else if feedback.lottieAnimationName != nil {
            stackView.setCustomSpacing(.bigSpacing, after: animationView)
        } else {
            stackView.setCustomSpacing(.bigSpacing, after: feedbackIImageView)
        }

        let containerBottomToAnchor: NSLayoutYAxisAnchor
        if feedback.buttonText == nil {
            containerBottomToAnchor = view.safeAreaLayoutGuide.bottomAnchor
        } else {
            containerBottomToAnchor = buttonView.topAnchor
        }

        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: containerBottomToAnchor)
        ])

        animateView()
    }

    fileprivate func setUpButton() {
        guard let text = feedback.buttonText else {
            buttonView.isHidden = true
            return
        }

        buttonView.delegate = self
        buttonView.buttonText = text
        buttonView.isEnabled = true
        buttonView.alpha = 0
    }

    fileprivate func setUpLabels() {
        titleLabel.text = feedback.title
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.alpha = 0

        descriptionLabel.style = .description
        descriptionLabel.attributedText = feedback.description
        descriptionLabel.alpha = 0
        descriptionLabel.textAlignment = .center
        let ble = descriptionLabel.heightAnchor.constraint(equalToConstant: 0)
        ble.priority = .defaultLow
        NSLayoutConstraint.activate([ble])

        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .descriptionTouched))
    }

    fileprivate func setUpImageView() {
        guard let image = feedback.image else {
            feedbackIImageView.removeFromSuperview()
            return
        }

        feedbackIImageView.image = image
        feedbackIImageView.alpha = 0

        let width = feedbackIImageView.widthAnchor.constraint(equalToConstant: image.size.width)
        width.priority = .defaultLow
        let height = feedbackIImageView.heightAnchor.constraint(equalToConstant: image.size.height)
        height.priority = .defaultLow

        NSLayoutConstraint.activate([
            height,
            width,

            feedbackIImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor,
                                                      constant: -2 * .sideMargin)
        ])
    }

    fileprivate func setUpLottieView() {
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.isHidden = true

        if let animationName = feedback.lottieAnimationName {
            animationView.isHidden = false
            animationView.animation = LottieAnimation.named(animationName)
            animationView.play()

            feedbackIImageView.isHidden = true
        } else {
            animationView.removeFromSuperview()
        }
    }

    fileprivate func setUpBlockClock() {
        guard let blocksLeft = feedback.blocksLeft else {
            return
        }

        blockClock.alpha = 0
        blockClock.translatesAutoresizingMaskIntoConstraints = false
        blockClock.blocks = blocksLeft
        stackView.insertArrangedSubview(blockClock, at: stackView.arrangedSubviews.firstIndex(of: titleLabel)!)

        stackView.setCustomSpacing(-.closeSpacing, after: feedbackIImageView)
    }

    fileprivate func animateView() {
        feedbackIImageView.animate(direction: .topToBottom, duration: .short) {
            if self.blockClock.superview != nil {
                self.blockClock.animate(direction: .topToBottom, duration: .short)
            }

            self.titleLabel.animate(direction: .topToBottom, duration: .short) {
                self.descriptionLabel.animate(direction: .topToBottom, duration: .short)
            }
        }

        buttonView.animate(direction: .bottomToTop, duration: .medium, delay: .short3)
    }

    @objc fileprivate func descriptionTouched() {
        if feedback == FeedbackInfo.deleteWallet {
            let nc = UINavigationController(rootViewController: SupportViewController(type: .feedback))
            navigationController!.present(nc, animated: true)
        }
    }

}

extension FeedbackViewController: ButtonViewDelegate {

    func button(didPress button: ButtonView) {
        switch feedback.buttonAction {
        case .popToRoot:
            navigationController!.popToRootViewController(animated: true)
        case .popTo(let vc):
            navigationController!.popTo(type: vc)
        case .dismiss:
            navigationController!.dismiss(animated: true)
        case .setViewControllers(let vcs):
            navigationController!.setViewControllers(vcs, animated: true)
        case .resetToGetStarted:
            resetWindowToGetStarted()
        case nil:
            // Shouldn't happen
            ()
        }
    }

}

extension FeedbackViewController: UITestablePage {

    typealias UIElementType = UIElements.Pages.FeedbackPage

    fileprivate func makeViewTestable() {
        makeViewTestable(view, using: .root)
        makeViewTestable(buttonView, using: .finishButton)
    }

}

fileprivate extension Selector {
    static let descriptionTouched = #selector(FeedbackViewController.descriptionTouched)
}
