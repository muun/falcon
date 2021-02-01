//
//  BottomDrawerOverlayViewController.swift
//  falcon
//
//  Created by Manu Herrera on 14/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

class BottomDrawerOverlayViewController: UIViewController {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var linkButtonView: LinkButtonView!

    private var titleText = ""
    private var descriptionText: NSAttributedString = NSAttributedString(string: "")
    private var type: MoreInfoType = .password
    private var action: MoreInfoAction?

    override func customLoggingParameters() -> [String: Any]? {
        return ["type": type.loggingName()]
    }

    override var screenLoggingName: String {
        return "more_info"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        logScreen()
    }

    init(info: MoreInfo) {
        self.titleText = info.title
        self.descriptionText = info.description
        self.type = info.type
        self.action = info.action

        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        contentView.backgroundColor = Asset.Colors.cellBackground.color
        setUpLabels()
        setUpOverlay()
        setUpLinkButton()
    }

    private func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.attributedText = titleText.set(font: Constant.Fonts.system(size: .desc, weight: .semibold),
                                                  lineSpacing: Constant.FontAttributes.lineSpacing,
                                                  kerning: Constant.FontAttributes.kerning)

        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        descriptionLabel.attributedText = descriptionText
    }

    fileprivate func setUpOverlay() {
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: .overlayViewTouched)
        )
    }

    fileprivate func setUpLinkButton() {
        if let action = action {
            linkButtonView.delegate = self
            linkButtonView.buttonText = action.text
            linkButtonView.isEnabled = true
        } else {
            linkButtonView.removeFromSuperview()
        }
    }

    @objc fileprivate func overlayTouched() {
        self.dismiss(animated: true)
    }

}

extension BottomDrawerOverlayViewController: LinkButtonViewDelegate {
    func linkButton(didPress linkButton: LinkButtonView) {
        if let action = action {
            action.action()
        }
    }
}

extension BottomDrawerOverlayViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return AnimationController(presenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(presenting: false)
    }

    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {

        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

}

@objc private class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting

        super.init()
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let containerView = transitionContext.containerView

        if presenting {
            let view = transitionContext.view(forKey: .to)!

            containerView.addSubview(view)

            view.frame = containerView.bounds
            view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

            func animation() {
                view.transform = CGAffineTransform.identity
            }

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: animation,
                           completion: transitionContext.completeTransition)
        } else {
            let view = transitionContext.view(forKey: .from)!

            func animation() {
                view.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
            }

            func completion(completed: Bool) {
                transitionContext.completeTransition(completed)
                view.removeFromSuperview()
            }

            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           animations: animation,
                           completion: completion)
        }
    }

}

@objc private class PresentationController: UIPresentationController {

    let overlayView = UIView()

    override func presentationTransitionWillBegin() {

        guard let containerView = containerView,
            let transitionCoordinator = presentedViewController.transitionCoordinator else {
            return
        }

        containerView.addSubview(overlayView)
        overlayView.frame = containerView.bounds
        overlayView.backgroundColor = UIColor.black
        overlayView.alpha = 0

        transitionCoordinator.animate(alongsideTransition: { _ in
            self.overlayView.alpha = 0.4
        }, completion: nil)
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            overlayView.removeFromSuperview()
        }
    }

    override func dismissalTransitionWillBegin() {
        guard let transitionCoordinator = presentedViewController.transitionCoordinator else {
                return
        }

        transitionCoordinator.animate(alongsideTransition: { _ in
            self.overlayView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed {
            containerView?.removeFromSuperview()
        }
    }

}

fileprivate extension Selector {

    static let overlayViewTouched =
        #selector(BottomDrawerOverlayViewController.overlayTouched)

}

typealias MoreInfo = (title: String, description: NSAttributedString, type: MoreInfoType, action: MoreInfoAction?)
typealias MoreInfoAction = (text: String, action: () -> Void)
enum BottomDrawerInfo {}

enum MoreInfoType {
    case password
    case selectFee
    case manualFee
    case lightningFee
    case confsNeeded
    case oneConfNotice
    case whatIsTheRecoveryCode
    case newOpDestination
    case forgotPassword
    case loadWallet
    case segwitLegacyInfo
    case onChainAddress
    case lightningInvoice
    case whyEmail
    case cloudStorage
    case rbf

    // Just too many cases
    // swiftlint:disable cyclomatic_complexity
    func loggingName() -> String {
        switch self {
        case .password: return "password"
        case .selectFee: return "select_fee"
        case .manualFee: return "manual_fee"
        case .lightningFee: return "lightning_fee"
        case .confsNeeded: return "confirmation_needed"
        case .oneConfNotice: return "one_conf_notice"
        case .whatIsTheRecoveryCode: return "what_is_the_recovery_code"
        case .newOpDestination: return "new_op_destination"
        case .forgotPassword: return "forgot_password"
        case .loadWallet: return "load_wallet"
        case .segwitLegacyInfo: return "segwit_legacy"
        case .onChainAddress: return "on_chain_address"
        case .lightningInvoice: return "lightning_invoice"
        case .whyEmail: return "email_explanation"
        case .cloudStorage: return "cloud_storage"
        case .rbf: return "rbf"
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
