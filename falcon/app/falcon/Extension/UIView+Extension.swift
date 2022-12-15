//
//  UIView+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

enum AnimationDuration: Double {
    case short = 0.3
    case medium = 0.45
    case opsBadge = 0.8
    case long = 1.0
}

enum AnimationDelay: Double {
    case none = 0
    case short = 0.15
    case short2 = 0.3
    case short3 = 0.45
    case medium = 0.6
    case medium2 = 0.75
    case medium3 = 0.9
    case opsBadge = 0.8
    case long = 1.0
    case toast = 3.0
}

enum AnimationDirection {
    case topToBottom
    case bottomToTop
    case leftToRight
    case rightToLeft
}

extension UIView {

    func circleView() {
        // Only for perfect square views (width == height)
        let cornerRadius = self.frame.size.width / 2
        roundCorners(cornerRadius: cornerRadius)
    }

    func roundCorners(cornerRadius: CGFloat = 4, clipsToBounds: Bool = true) {
        layer.cornerRadius = cornerRadius
        self.clipsToBounds = clipsToBounds
    }

    func shake(duration: TimeInterval = 0.25, translation: CGFloat = -20, completion: (() -> Void)? = nil) {
        self.transform = CGAffineTransform(translationX: translation, y: 0)

        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 1,
            options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransform.identity
        }, completion: { _ in
            completion?()
        })
    }

    func setUpShadow(color: UIColor = Asset.Colors.muunGrayLight.color,
                     opacity: Float = 0.3,
                     offset: CGSize = CGSize.zero,
                     radius: CGFloat = 10) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }

    func animate(direction: AnimationDirection,
                 offset: CGFloat = 20,
                 duration: AnimationDuration,
                 delay: AnimationDelay = .none,
                 options: UIView.AnimationOptions = [],
                 completion: (() -> Void)? = nil) {

        func actuallyAnimate() {
            var (x, y): (CGFloat, CGFloat) = (0, 0)

            switch direction {
            case .topToBottom:
                (x, y) = (0, -offset)
            case .bottomToTop:
                (x, y) = (0, offset)
            case .leftToRight:
                (x, y) = (-offset, 0)
            case .rightToLeft:
                (x, y) = (offset, 0)
            }

            self.transform = CGAffineTransform(translationX: x, y: y)
            self.alpha = 0

            UIView.animate(withDuration: duration.rawValue, delay: delay.rawValue, options: options, animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: { _ in
                completion?()
            })
        }

        actuallyAnimate()
    }

    func animateOut(direction: AnimationDirection,
                    offset: CGFloat = 20,
                    duration: AnimationDuration,
                    delay: AnimationDelay = .none,
                    options: UIView.AnimationOptions = [],
                    completion: (() -> Void)? = nil) {

        func actuallyAnimate() {
            var (x, y): (CGFloat, CGFloat) = (0, 0)

            switch direction {
            case .topToBottom:
                (x, y) = (0, offset)
            case .bottomToTop:
                (x, y) = (0, -offset)
            case .leftToRight:
                (x, y) = (offset, 0)
            case .rightToLeft:
                (x, y) = (-offset, 0)
            }

            self.alpha = 1

            UIView.animate(withDuration: duration.rawValue, delay: delay.rawValue, options: options, animations: {
                self.alpha = 0
                self.transform = CGAffineTransform(translationX: x, y: y)
            }, completion: { _ in
                self.transform = CGAffineTransform.identity
                completion?()
            })
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay.rawValue) {
            actuallyAnimate()
        }
    }

    func shrink(duration: Double = 0.15,
                delay: Double = 0,
                damping: CGFloat = 0.8,
                initialSpringVelocity: CGFloat = 0.3,
                options: UIView.AnimationOptions = UIView.AnimationOptions.allowUserInteraction,
                shrinkValue: CGFloat = 0.98) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: initialSpringVelocity,
                       options: options,
                       animations: { self.transform = CGAffineTransform(scaleX: shrinkValue, y: shrinkValue) },
                       completion: nil)
    }

    func animateIdentity(duration: Double = 0.15,
                         delay: Double = 0,
                         damping: CGFloat = 0.8,
                         initialSpringVelocity: CGFloat = 0.3,
                         options: UIView.AnimationOptions = UIView.AnimationOptions.allowUserInteraction) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: initialSpringVelocity,
                       options: options,
                       animations: { self.transform = CGAffineTransform.identity },
                       completion: nil)
    }

    func addSubviewWrappingParent(child: UIView,
                                  skipBottomContraint: Bool = false) {
        child.translatesAutoresizingMaskIntoConstraints = false

        addSubview(child)

        addConstraint(NSLayoutConstraint(item: child,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .top,
                                         multiplier: 1.0,
                                         constant: 0.0))
        addConstraint(NSLayoutConstraint(item: child,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0))
        if !skipBottomContraint {
            addConstraint(NSLayoutConstraint(item: self,
                                             attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: child,
                                             attribute: .bottom,
                                             multiplier: 1.0,
                                             constant: 0.0))
        }

        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: child,
                                         attribute: .trailing,
                                         multiplier: 1.0,
                                         constant: 0.0))
    }
}
