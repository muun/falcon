//
//  TooltipView.swift
//  falcon
//
//  Created by Federico Bond on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class TooltipView: UIView {

    private let containerView: UIView = UIView()
    private let triangleView: TriangleView = TriangleView()
    private let messageLabel: UILabel = UILabel()

    private let message: String

    init(message: String) {
        self.message = message
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setUpView() {
        setUpContainerView()
        setUpTriangleView()
        setUpMessageLabel()
    }

    fileprivate func setUpContainerView() {
        containerView.backgroundColor = Asset.Colors.muunBlueLight.color
        containerView.roundCorners(clipsToBounds: false)

        // Do not show shadow in dark mode
        if !isDarkMode() {
            containerView.setUpShadow(opacity: 0.08, offset: CGSize(width: 0, height: 8), radius: 5)
        }

        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .sideMargin),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.sideMargin)
        ])
    }

    fileprivate func setUpTriangleView() {
        triangleView.color = Asset.Colors.muunBlueLight.color
        triangleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(triangleView)

        NSLayoutConstraint.activate([
            triangleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            triangleView.topAnchor.constraint(equalTo: containerView.bottomAnchor),
            triangleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            triangleView.heightAnchor.constraint(equalToConstant: 12),
            triangleView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }

    fileprivate func setUpMessageLabel() {
        messageLabel.text = message
        messageLabel.font = Constant.Fonts.system(size: .opHelper)
        if isDarkMode() {
            messageLabel.textColor = Asset.Colors.title.color
        } else {
            messageLabel.textColor = Asset.Colors.muunBlue.color
        }
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8)
        ])
    }

    fileprivate func isDarkMode() -> Bool {
        if #available(iOS 12.0, *) {
            return traitCollection.userInterfaceStyle == .dark
        }

        return false
    }

    func show(completion: @escaping () -> Void) {
        isHidden = false
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

        UIView.animate(
            withDuration: 1,
            delay: 2,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: .curveEaseInOut,
            animations: {
                self.alpha = 1
                self.transform = .identity
            },
            completion: { _ in completion() }
        )
    }

}
