//
//  TurboChannelsView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import UIKit

protocol OnchainSettingsViewDelegate: AnyObject {
    func toggle()
}

final class OnchainSettingsView: UIView {

    var enabled = false {
        didSet {
            toggle.setOn(enabled, animated: false)
        }
    }

    var loading = false {
        didSet {
            isUserInteractionEnabled = !loading
        }
    }

    private var toggle: UISwitch!
    private var toggleLabel: UILabel!
    private var activationView: UIStackView!
    private var activationLabel: UILabel!
    private weak var delegate: OnchainSettingsViewDelegate?

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(delegate: OnchainSettingsViewDelegate?) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)

        setUp()
    }

    override func didMoveToWindow() {
        // If we set this in setUp something seems to reset it
        backgroundColor = Asset.Colors.muunHomeBackgroundColor.color
    }

    func setUp() {

        let verticalStack = UIStackView()
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.axis = .vertical
        verticalStack.alignment = .center
        verticalStack.distribution = .fillProportionally
        verticalStack.layoutMargins = UIEdgeInsets(top: 32, left: 0, bottom: 0, right: 0)
        verticalStack.isLayoutMarginsRelativeArrangement = true
        verticalStack.spacing = 12

        addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            verticalStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            verticalStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            verticalStack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor)
        ])

        let firstHairline = addHairline(to: verticalStack)
        verticalStack.setCustomSpacing(0, after: firstHairline)

        let toggleStackView = UIStackView()
        toggleStackView.translatesAutoresizingMaskIntoConstraints = false
        toggleStackView.axis = .horizontal
        toggleStackView.alignment = .center
        toggleStackView.distribution = .equalSpacing
        toggleStackView.backgroundColor = Asset.Colors.cellBackground.color
        toggleStackView.spacing = Constant.Dimens.viewControllerPadding
        toggleStackView.layoutMargins = UIEdgeInsets(top: 0,
                                                     left: .spacing,
                                                     bottom: 0,
                                                     right: .spacing)
        toggleStackView.isLayoutMarginsRelativeArrangement = true

        verticalStack.addArrangedSubview(toggleStackView)
        verticalStack.setCustomSpacing(0, after: toggleStackView)

        NSLayoutConstraint.activate([
            toggleStackView.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            toggleStackView.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            toggleStackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        toggleLabel = UILabel()
        toggleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleLabel.text = L10n.OnchainSettings.defaultTaproot
        // Don't shrink unless needed to
        toggleLabel.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        // Strech as much as needed
        toggleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        toggleStackView.addArrangedSubview(toggleLabel)

        toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .vertical)
        toggle.addTarget(self, action: #selector(didTapToggle), for: UIControl.Event.valueChanged)
        toggleStackView.addArrangedSubview(toggle)

        addHairline(to: verticalStack)

        activationView = UIStackView()
        activationView.translatesAutoresizingMaskIntoConstraints = false
        activationView.axis = .horizontal
        activationView.distribution = .fill
        activationView.alignment = .center
        activationView.isHidden = true
        activationView.spacing = 6
        verticalStack.addArrangedSubview(activationView)
        NSLayoutConstraint.activate([
            activationView.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor,
                                                     constant: .spacing),
        ])

        let activationClock = UIImageView(image: Asset.Assets.clock.image)
        activationClock.translatesAutoresizingMaskIntoConstraints = false
        activationClock.setContentHuggingPriority(.required, for: .vertical)
        activationClock.setContentHuggingPriority(.required, for: .horizontal)
        activationClock.setContentCompressionResistancePriority(.required, for: .vertical)
        activationView.addArrangedSubview(activationClock)

        activationLabel = UILabel()
        activationLabel.translatesAutoresizingMaskIntoConstraints = false
        activationLabel.font = Constant.Fonts.system(size: .opHelper, weight: .medium)
        activationLabel.textColor = Asset.Colors.black.color
        activationLabel.setContentHuggingPriority(.required, for: .vertical)
        activationLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        activationView.addArrangedSubview(activationLabel)

        let learnMoreLabel = UILabel()
        learnMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        learnMoreLabel.text = L10n.OnchainSettings.learnMore
        learnMoreLabel.font = Constant.Fonts.system(size: .opHelper)
        learnMoreLabel.textColor = Asset.Colors.muunGrayDark.color
        learnMoreLabel.setContentHuggingPriority(.required, for: .vertical)
        learnMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        learnMoreLabel.isUserInteractionEnabled = true
        learnMoreLabel.numberOfLines = 0

        verticalStack.addArrangedSubview(learnMoreLabel)
        NSLayoutConstraint.activate([
            verticalStack.trailingAnchor.constraint(equalTo: learnMoreLabel.trailingAnchor,
                                                    constant: .spacing),
            learnMoreLabel.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor,
                                                    constant: .spacing)
        ])

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        verticalStack.addArrangedSubview(spacer)
    }

    func showActivationTimer(hours: Int) {
        activationLabel.text = L10n.OnchainSettings.timeToActivation(hours)
        activationView.isHidden = false
        toggle.isEnabled = false
        toggleLabel.textColor = Asset.Colors.muunDisabled.color
    }

    @discardableResult
    private func addHairline(to stackView: UIStackView) -> HairlineView {
        let hairline = HairlineView()
        hairline.color = Asset.Colors.title.color.withAlphaComponent(0.12)
        stackView.addArrangedSubview(hairline)
        NSLayoutConstraint.activate([
            hairline.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])

        return hairline
    }

    @objc func didTapToggle() {
        delegate?.toggle()
    }

}
