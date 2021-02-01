//
//  ButtonView.swift
//  falcon
//
//  Created by Manu Herrera on 14/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

protocol ButtonViewDelegate: class {
    func button(didPress button: ButtonView)
}

@IBDesignable
class ButtonView: MUView {

    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var solidBackgroundView: UIView!
    @IBOutlet private weak var gradientView: UIView!

    private let buttonGradient = CAGradientLayer()
    private let gradient = CAGradientLayer()

    weak var delegate: ButtonViewDelegate?

    var normalButtonText: String = ""

    public var style: ButtonViewStyle = .primary

    public var isEnabled: Bool {
        get { return button.isUserInteractionEnabled }
        set { setEnabled(newValue) }
    }

    public var isLoading: Bool {
        get { return !activityIndicator.isHidden }
        set { setLoading(loading: newValue) }
    }

    public var buttonText: String {
        get { return button.titleLabel!.text ?? "" }
        set {
            button.setTitle(newValue, for: .normal)
            normalButtonText = newValue
        }
    }

    override func setUp() {
        setUpButton()
        activityIndicator.isHidden = true

        makeViewTestable()
    }

    func setUpBackground() {
        let backgroundColor = (style == .primary) ? Asset.Colors.background.color : UIColor.clear
        solidBackgroundView.backgroundColor = backgroundColor

        if style == .primary {
            setUpTopGradient()
        }
    }

    private func setUpTopGradient() {
        let backgroundColor = Asset.Colors.background.color
        let clear = backgroundColor.withAlphaComponent(0)

        gradientView.backgroundColor = clear

        gradient.frame = gradientView.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)

        // We add a middle point to make the gradient go solid quicker
        gradient.locations = [0, 0.53, 1]
        gradient.colors = [clear.cgColor, backgroundColor.cgColor, backgroundColor.cgColor]

        gradientView.layer.addSublayer(gradient)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        buttonGradient.frame = self.bounds
        gradient.frame = gradientView.bounds
    }

    private func setUpButton() {
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)

        buttonGradient.frame = self.bounds
        buttonGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        buttonGradient.endPoint = CGPoint(x: 1.0, y: 0.5)

        let colors = style.buttonColors()
        buttonGradient.colors = [colors.left.cgColor, colors.right.cgColor]

        button.layer.addSublayer(buttonGradient)
    }

    fileprivate func setEnabled(_ isEnabled: Bool) {

        let colors = style.buttonColors()

        UIView.animate(
            withDuration: 0.25,
            animations: {
                self.buttonGradient.colors = [colors.left.cgColor, colors.right.cgColor]
                self.button.setTitleColor(self.style.textColor(), for: .normal)

                if isEnabled {
                    self.button.alpha = 1.0
                } else {
                    self.button.alpha = 0.2
                }
        },
            completion: { _ in
                self.button.isUserInteractionEnabled = isEnabled
        })

        setUpBackground()
    }

    fileprivate func setLoading(loading: Bool) {
        let title = loading
            ? ""
            : normalButtonText

        button.setTitle(title, for: .normal)

        activityIndicator.isHidden = !loading

        if loading {
            activityIndicator.startAnimating()
            button.isUserInteractionEnabled = false

        } else {
            activityIndicator.stopAnimating()
            button.isUserInteractionEnabled = true
        }
    }

    @IBAction fileprivate func buttonTouched(_ sender: ButtonView) {
        delegate?.button(didPress: self)
    }

}

extension ButtonView: UITestablePage {
    typealias UIElementType = UIElements.CustomViews.ButtonViewPage

    func makeViewTestable() {
        self.makeViewTestable(self.button, using: .mainButton)
    }
}

enum ButtonViewStyle {
    case primary
    case secondary

    func buttonColors() -> (left: UIColor, right: UIColor) {
        switch self {
        case .primary:
            return (Asset.Colors.muunButtonLeft.color, Asset.Colors.muunButtonRight.color)
        case .secondary:
            return (.white, .white)
        }
    }

    func textColor() -> UIColor {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return Asset.Colors.muunBlue.color
        }
    }
}
