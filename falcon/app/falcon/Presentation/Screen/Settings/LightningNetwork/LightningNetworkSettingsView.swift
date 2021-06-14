//
//  TurboChannelsView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import UIKit

protocol LightningNetworkSettingsViewDelegate: AnyObject {
    func didTapLearnMore()
    func toggle()
}

final class LightningNetworkSettingsView: UIView {

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
    private weak var delegate: LightningNetworkSettingsViewDelegate?

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(delegate: LightningNetworkSettingsViewDelegate?) {
        self.delegate = delegate
        super.init(frame: CGRect.zero)

        setUp()
        makeViewTestable()
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
                                                     left: Constant.Dimens.viewControllerPadding,
                                                     bottom: 0,
                                                     right: Constant.Dimens.viewControllerPadding)
        toggleStackView.isLayoutMarginsRelativeArrangement = true

        verticalStack.addArrangedSubview(toggleStackView)
        verticalStack.setCustomSpacing(0, after: toggleStackView)

        NSLayoutConstraint.activate([
            toggleStackView.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor),
            toggleStackView.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            toggleStackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.LightningNetworkSettings.turboChannels
        // Don't shrink unless needed to
        label.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        // Strech as much as needed
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        toggleStackView.addArrangedSubview(label)

        toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .vertical)
        toggle.addTarget(self, action: #selector(didTapToggle), for: UIControl.Event.valueChanged)
        toggleStackView.addArrangedSubview(toggle)

        addHairline(to: verticalStack)

        let learnMoreLabel = UILabel()
        learnMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        learnMoreLabel.attributedText = L10n.LightningNetworkSettings.learnMore
            .set(font: Constant.Fonts.system(size: .notice))
            .set(underline: L10n.LightningNetworkSettings.learnMoreUnderline, color: Asset.Colors.muunBlue.color)
        learnMoreLabel.setContentHuggingPriority(.required, for: .vertical)
        learnMoreLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        learnMoreLabel.isUserInteractionEnabled = true
        learnMoreLabel.numberOfLines = 0
        learnMoreLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapLearnMore))
        )

        verticalStack.addArrangedSubview(learnMoreLabel)
        NSLayoutConstraint.activate([
            learnMoreLabel.trailingAnchor.constraint(equalTo: verticalStack.trailingAnchor),
            learnMoreLabel.leadingAnchor.constraint(equalTo: verticalStack.leadingAnchor,
                                                    constant: Constant.Dimens.viewControllerPadding)
        ])

        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        verticalStack.addArrangedSubview(spacer)
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

    @objc func didTapLearnMore() {
        delegate?.didTapLearnMore()
    }

}

extension LightningNetworkSettingsView: UITestablePage {

    typealias UIElementType = UIElements.Pages.LightningNetworkSettingsPage

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(toggle, using: .turboChannels)
    }
}
