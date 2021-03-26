//
//  ToastView.swift
//  falcon
//
//  Created by Manu Herrera on 24/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class ToastView: MUView {

    @IBOutlet private weak var toastCardView: UIView!
    @IBOutlet private weak var toastLabel: UILabel!

    private var toastHeight: CGFloat {
        return toastCardView.frame.height + 16
    }
    private let toastGradient = CAGradientLayer()

    override func setUp() {
        setUpToastCard()
        setUpLabel()
        setUpGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        toastGradient.frame = self.toastCardView.bounds
    }

    fileprivate func setUpLabel() {
        toastLabel.textColor = Asset.Colors.background.color
        toastLabel.font = Constant.Fonts.description
    }

    fileprivate func setUpGradient() {
        toastGradient.frame = self.toastCardView.bounds
        toastGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        toastGradient.endPoint = CGPoint(x: 1.0, y: 0.5)

        toastGradient.colors = [Asset.Colors.toastLeft.color.cgColor, Asset.Colors.toastRight.color.cgColor]

        toastCardView.layer.addSublayer(toastGradient)
    }

    fileprivate func setUpToastCard() {
        toastCardView.backgroundColor = .clear
        toastCardView.layer.cornerRadius = 4
        toastCardView.clipsToBounds = true
    }

    func presentIn(_ view: UIView, text: NSAttributedString, duration: Double) {
        toastLabel.attributedText = text

        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)

        self.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true

        self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 48).isActive = true
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        self.alpha = 0

        self.animate(direction: .bottomToTop, offset: toastHeight, duration: .short) {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.animateOut()
            }
        }
    }

    func animateOut() {
        if self.alpha == 0 {
            return
        }

        self.animateOut(direction: .topToBottom, duration: .short)
    }

}
