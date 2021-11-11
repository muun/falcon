//
//  TitleAndDescriptionView.swift
//  falcon
//
//  Created by Manu Herrera on 04/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

enum TitleAndDescriptionStyle {
    case bigTitle
    case standard

    func titleFont() -> UIFont {
        switch self {
        case .bigTitle:
            return Constant.Fonts.system(size: .h2, weight: .medium)
        case .standard:
            return Constant.Fonts.system(size: .desc, weight: .semibold)
        }
    }
}

protocol TitleAndDescriptionViewDelegate: AnyObject {
    func descriptionTouched()
}

@IBDesignable
class TitleAndDescriptionView: MUView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var labelsDistanceConstraint: NSLayoutConstraint!

    weak var delegate: TitleAndDescriptionViewDelegate?
    public var style: TitleAndDescriptionStyle = .bigTitle {
        willSet {
            titleLabel.font = newValue.titleFont()
        }
    }

    public var titleText: String {
        get { return titleLabel.text ?? "" }
        set {
            titleLabel.attributedText = newValue.set(font: titleLabel.font)
        }
    }

    public var descriptionText: NSAttributedString? {
        get { return descriptionLabel.attributedText ?? nil }
        set {
            if newValue == nil {
                descriptionLabel.attributedText = nil
                labelsDistanceConstraint.constant = 0
                descriptionLabel.isHidden = true
            } else {
                descriptionLabel.attributedText = newValue
                labelsDistanceConstraint.constant = 8
                descriptionLabel.isHidden = false
            }
        }
    }

    override func setUp() {
        setUpLabels()
    }

    fileprivate func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = style.titleFont()
        titleLabel.alpha = 0

        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        descriptionLabel.font = Constant.Fonts.description
        descriptionLabel.alpha = 0

        descriptionLabel.isUserInteractionEnabled = true
        descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .descriptionTextTouched))
    }

    func animate(completion: (() -> Void)? = nil) {
        titleLabel.animate(direction: .topToBottom, duration: .short) {
            if self.descriptionText != nil {
                self.animateDescription(completion: completion)
            } else {
                completion?()
            }
        }
    }

    func animateDescription(completion: (() -> Void)? = nil) {
        descriptionLabel.animate(direction: .topToBottom, duration: .short) {
            completion?()
        }
    }

    @objc func descriptionTouched() {
        delegate?.descriptionTouched()
    }

    func makeVisible() {
        titleLabel.alpha = 1
        descriptionLabel.alpha = 1
    }

    func fixCompressionResistance() {
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)

        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
    }
}

fileprivate extension Selector {

    static let descriptionTextTouched = #selector(TitleAndDescriptionView.descriptionTouched)

}
