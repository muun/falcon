//
//  TurboChannelsView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import UIKit

final class SettingsToggleView: MUView {
    private let subtitle: UILabel
    private let title: String
    private var toggle: UISwitch!
    weak var presenter: SettingsTogglePresenter? {
        didSet {
            presenter?.setUp()
        }
    }
    private let toggleIdentifierForTesting: UIElementType

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

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }

    init(title: String,
         subtitle: UILabel,
         toggleIdentifierForTesting: UIElementType) {
        self.title = title
        self.subtitle = subtitle
        self.toggleIdentifierForTesting = toggleIdentifierForTesting
        super.init(frame: CGRect.zero)

        setUp()
        makeViewTestable()
    }

    override func didMoveToWindow() {
        // If we set this in setUp something seems to reset it
        backgroundColor = Asset.Colors.muunHomeBackgroundColor.color
    }

    override func setUp() {
        let mainStackView = createMainStack()
        addHairline(to: mainStackView)

        let toggleStackView = addToggleStackView(to: mainStackView)
        addTitleLabel(to: toggleStackView)
        addToggleView(to: toggleStackView)

        addHairline(to: mainStackView)
        addSpacer(to: mainStackView)
        addSubtitle(to: mainStackView)
    }

    @objc func didTapToggle() {
        presenter?.onToggleTapped()
    }

    deinit {
        presenter?.tearDown()
    }
}

extension SettingsToggleView: SettingsTogglePresenterDelegate {
    func showAlert(data: SettingsToggleAlertData) {
        let alert = UIAlertController(
            title: data.title,
            message: data.message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: data.cancelButtonTitle, style: .cancel, handler: { _ in
            data.cancelButtonBlock()
        }))

        alert.addAction(UIAlertAction(title: data.destructiveButtonTitle,
                                      style: .destructive,
                                      handler: { _ in
            data.destructiveButtonBlock()
        }))

        present(alert, animated: true, completion: nil)
    }
}

extension SettingsToggleView: UITestablePage {
    typealias UIElementType = UIElements.Pages.LightningNetworkSettingsPage

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
        makeViewTestable(toggle, using: toggleIdentifierForTesting)
    }
}

private extension SettingsToggleView {
    func createMainStack() -> UIStackView {
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

        return verticalStack
    }

    func addToggleStackView(to mainStackView: UIStackView) -> UIStackView {
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

        mainStackView.addArrangedSubview(toggleStackView)
        mainStackView.setCustomSpacing(0, after: toggleStackView)

        NSLayoutConstraint.activate([
            toggleStackView.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor),
            toggleStackView.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor),
            toggleStackView.heightAnchor.constraint(equalToConstant: 44)
        ])

        return toggleStackView
    }

    func addTitleLabel(to toggleStackView: UIStackView) {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        // Don't shrink unless needed to
        label.setContentCompressionResistancePriority(UILayoutPriority(999), for: .horizontal)
        // Strech as much as needed
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)

        toggleStackView.addArrangedSubview(label)
    }

    func addToggleView(to toggleStackView: UIStackView) {
        toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.setContentHuggingPriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .horizontal)
        toggle.setContentCompressionResistancePriority(.required, for: .vertical)
        toggle.addTarget(self, action: #selector(didTapToggle), for: UIControl.Event.valueChanged)
        toggleStackView.addArrangedSubview(toggle)
    }

    func addSubtitle(to mainStackView: UIStackView) {
        mainStackView.addArrangedSubview(subtitle)
        NSLayoutConstraint.activate([
            subtitle.trailingAnchor.constraint(equalTo: mainStackView.trailingAnchor,
                                               constant: -Constant.Dimens.viewControllerPadding),
            subtitle.leadingAnchor.constraint(equalTo: mainStackView.leadingAnchor,
                                                    constant: Constant.Dimens.viewControllerPadding)
        ])
    }

    private func addHairline(to stackView: UIStackView) {
        let hairline = HairlineView()
        hairline.color = Asset.Colors.title.color.withAlphaComponent(0.12)
        stackView.addArrangedSubview(hairline)
        NSLayoutConstraint.activate([
            hairline.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            hairline.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
        ])

        stackView.setCustomSpacing(0, after: hairline)
    }

    func addSpacer(to mainStackView: UIStackView) {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        mainStackView.addArrangedSubview(spacer)
    }
}

struct SettingsToggleAlertData {
    let title: String
    let message: String
    let cancelButtonTitle: String
    let cancelButtonBlock: () -> Void
    let destructiveButtonTitle: String
    let destructiveButtonBlock: () -> Void
}
