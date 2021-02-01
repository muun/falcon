//
//  PopUp.swift
//  falcon
//
//  Created by Manu Herrera on 29/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

@objc
protocol DisplayablePopUp {
    var navigationController: UINavigationController! { get }
    var view: UIView! { get }
    var alreadyDismissedPopUp: Bool { get set }

    @objc func dismissPopUp()
}

extension DisplayablePopUp {

    func show(popUp: UIView, duration: Double? = 2, isDismissableOnTap: Bool = true) {
        view.endEditing(true)

        let newNavigation = buildNewNavigation(popUp, isDismissableOnTap: isDismissableOnTap)

        navigationController.present(newNavigation, animated: true) {
            if let duration = duration {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    if !self.alreadyDismissedPopUp {
                        self.dismissPopUp()
                    }
                }
            }
        }
    }

    private func buildNewNavigation(_ popUp: UIView, isDismissableOnTap: Bool) -> UINavigationController {
        let newVC = UIViewController()

        let containerView = UIView()
        containerView.backgroundColor = Asset.Colors.muunOverlay.color
        containerView.translatesAutoresizingMaskIntoConstraints = false
        newVC.view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: newVC.view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: newVC.view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: newVC.view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: newVC.view.bottomAnchor)
        ])

        popUp.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(popUp)
        NSLayoutConstraint.activate([
            popUp.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            popUp.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])

        if isDismissableOnTap {
            addDismissAction(view: popUp)
            addDismissAction(view: containerView)
        }

        let newNavigation = UINavigationController(rootViewController: newVC)
        newNavigation.setNavigationBarHidden(true, animated: true)
        newNavigation.modalPresentationStyle = .overFullScreen
        newNavigation.modalTransitionStyle = .crossDissolve

        return newNavigation
    }

    private func addDismissAction(view: UIView) {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .dismissPopUp))
    }

}

fileprivate extension Selector {
    static let dismissPopUp = #selector(DisplayablePopUp.dismissPopUp)
}
