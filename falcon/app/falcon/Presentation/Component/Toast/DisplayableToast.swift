//
//  DisplayableToast.swift
//  falcon
//
//  Created by Manu Herrera on 24/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

@objc
protocol DisplayableToast: class {
    var toast: ToastView? { get set }
    var view: UIView! { get }

    @objc func dismissToast()
}

extension DisplayableToast {

    func showToast(message: String, duration: Double? = nil) {
        showToast(message: NSAttributedString(string: message), duration: duration)
    }

    func showToast(message: NSAttributedString, duration: Double? = nil) {
        view.endEditing(true)

        toast?.removeFromSuperview()
        toast = ToastView()

        if let toast = toast {
            toast.isUserInteractionEnabled = true
            toast.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .dismissToast))

            let slideDown = UISwipeGestureRecognizer(target: self, action: .dismissToast)
            slideDown.direction = .down
            toast.addGestureRecognizer(slideDown)

            toast.presentIn(view, text: message, duration: duration ?? AnimationDelay.toast.rawValue)
        }
    }

}

fileprivate extension Selector {
    static let dismissToast = #selector(DisplayableToast.dismissToast)
}
