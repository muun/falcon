//
//  ModalAnimationController.swift
//  falcon
//
//  Created by Federico Bond on 22/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

@objc class ModalAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let presenting: Bool

    init(presenting: Bool) {
        self.presenting = presenting

        super.init()
    }

    public func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
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

@objc class ModalPresentationController: UIPresentationController {

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
