//
//  ActionCardView.swift
//  falcon
//
//  Created by Manu Herrera on 20/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ActionCardDelegate: AnyObject {
    func push(nextViewController: UIViewController)
}

@IBDesignable
class ActionCardView: MUView {

    @IBOutlet fileprivate weak var shadowView: UIView!
    @IBOutlet fileprivate weak var cardView: UIView!
    @IBOutlet fileprivate weak var stepView: UIView!
    @IBOutlet fileprivate weak var stepNumberLabel: UILabel!
    @IBOutlet fileprivate weak var stepImageView: UIImageView!
    @IBOutlet fileprivate weak var stepTitleLabel: UILabel!
    @IBOutlet fileprivate weak var stepDescriptionLabel: UILabel!
    @IBOutlet fileprivate weak var cardBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var cardTopConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var skippedView: UIView!
    @IBOutlet fileprivate weak var skippedLabel: UILabel!

    private var nextViewController: UIViewController?
    weak var delegate: ActionCardDelegate?

    private let muunGrayDark = Asset.Colors.muunGrayDark.color

    override func setUp() {
        setUpCardView()
        setUpLabels()
        setUpStepView()
        setInactiveState()

        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .touchInside))
    }

    private func setUpCardView() {
        cardView.backgroundColor = Asset.Colors.cellBackground.color
        cardView.roundCorners(cornerRadius: 8, clipsToBounds: true)
        cardView.layer.borderWidth = 1

        shadowView.roundCorners(cornerRadius: 8, clipsToBounds: false)
    }

    private func setUpLabels() {
        stepTitleLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        stepDescriptionLabel.font = Constant.Fonts.description

        stepNumberLabel.font = Constant.Fonts.monospacedDigitSystemFont(size: .desc, weight: .medium)
        stepNumberLabel.textColor = .white
    }

    private func setUpStepView() {
        stepView.circleView()
    }

    func setUp(actionCard: ActionCardModel) {
        switch actionCard.state {
        case .inactive: setInactiveState()
        case .active: setActiveState()
        case .done: setDoneState()
        case .home: setHomeState()
        case .skipped: setSkippedState()
        }

        stepTitleLabel.attributedText = actionCard.title
        stepDescriptionLabel.attributedText = actionCard.description
        stepNumberLabel.text = actionCard.stemNumber
        nextViewController = actionCard.nextViewController

        if let image = actionCard.stepImage {
            stepImageView.image = image
        }
    }

    private func setInactiveState() {
        isUserInteractionEnabled = false

        cardView.backgroundColor = .clear
        cardView.layer.borderColor = Asset.Colors.muunAlmostWhite.color.cgColor

        stepTitleLabel.textColor = Asset.Colors.muunGrayLight.color
        stepDescriptionLabel.textColor = Asset.Colors.muunGrayLight.color

        stepView.backgroundColor = Asset.Colors.muunGrayLight.color
        stepImageView.isHidden = true
        stepNumberLabel.isHidden = false

        hideSkippedView()

        // Hide shadow
        shadowView.setUpShadow(color: muunGrayDark, opacity: 0, offset: CGSize(width: 0, height: 8), radius: 8)
    }

    private func setActiveState() {
        isUserInteractionEnabled = true

        cardView.backgroundColor = Asset.Colors.cellBackground.color
        cardView.layer.borderColor = Asset.Colors.muunBlue.color.cgColor

        stepTitleLabel.textColor = Asset.Colors.muunBlue.color
        stepDescriptionLabel.textColor = Asset.Colors.muunGrayDark.color

        stepView.backgroundColor = Asset.Colors.muunBlue.color
        stepImageView.isHidden = true
        stepNumberLabel.isHidden = false

        hideSkippedView()

        // Show shadow
        shadowView.setUpShadow(color: muunGrayDark, opacity: 0.08, offset: CGSize(width: 0, height: 8), radius: 8)
    }

    private func setDoneState() {
        isUserInteractionEnabled = (nextViewController != nil)

        cardView.backgroundColor = Asset.Colors.muunGreenPale.color
        // Hide border
        cardView.layer.borderWidth = 0

        stepTitleLabel.textColor = Asset.Colors.muunGrayDark.color
        stepDescriptionLabel.textColor = Asset.Colors.muunGrayDark.color

        stepView.backgroundColor = Asset.Colors.muunGreen.color
        stepImageView.isHidden = false
        stepNumberLabel.isHidden = true

        hideSkippedView()

        // Hide shadow
        shadowView.setUpShadow(color: muunGrayDark, opacity: 0, offset: CGSize(width: 0, height: 8), radius: 8)
    }

    private func setHomeState() {
        isUserInteractionEnabled = true
        cardTopConstraint.constant = 16
        cardBottomConstraint.constant = 0

        cardView.backgroundColor = UIColor.clear
        cardView.layer.borderColor = Asset.Colors.muunBlue.color.withAlphaComponent(0.2).cgColor

        stepTitleLabel.textColor = Asset.Colors.muunGrayDark.color
        stepDescriptionLabel.textColor = Asset.Colors.muunGrayDark.color

        stepView.backgroundColor = .clear
        stepImageView.tintColor = Asset.Colors.muunBlue.color
        stepImageView.isHidden = false
        stepNumberLabel.isHidden = true

        hideSkippedView()

        // Hide shadow
        shadowView.setUpShadow(color: muunGrayDark, opacity: 0, offset: CGSize(width: 0, height: 8), radius: 8)
    }

    private func setSkippedState() {
        isUserInteractionEnabled = true

        cardView.backgroundColor = Asset.Colors.cellBackground.color
        cardView.layer.borderColor = Asset.Colors.muunBlue.color.withAlphaComponent(0.2).cgColor

        stepTitleLabel.textColor = Asset.Colors.muunBlue.color
        stepDescriptionLabel.textColor = Asset.Colors.muunGrayDark.color

        stepView.backgroundColor = Asset.Colors.muunBlue.color.withAlphaComponent(0.2)
        stepImageView.isHidden = true
        stepNumberLabel.isHidden = false

        setSkippedView()

        // Hide shadow
        shadowView.setUpShadow(color: muunGrayDark, opacity: 0, offset: CGSize(width: 0, height: 8), radius: 8)
    }

    private func setSkippedView() {
        skippedView.isHidden = false
        skippedLabel.isHidden = false

        skippedView.roundCorners(cornerRadius: 10, clipsToBounds: true)
        skippedView.backgroundColor = Asset.Colors.muunBluePale.color
        skippedLabel.text = L10n.ActionCardView.s1
        skippedLabel.textColor = Asset.Colors.muunBlue.color
        skippedLabel.font = Constant.Fonts.system(size: .notice, weight: .semibold)
    }

    private func hideSkippedView() {
        skippedView.isHidden = true
        skippedLabel.isHidden = true
    }

    @objc fileprivate func touchInside() {
        guard let nextVc = nextViewController else {
            return
        }
        delegate?.push(nextViewController: nextVc)
    }
}

enum ActionCardState {
    case inactive
    case active
    case done
    case home
    case skipped
}

fileprivate extension Selector {
    static let touchInside = #selector(ActionCardView.touchInside)
}
