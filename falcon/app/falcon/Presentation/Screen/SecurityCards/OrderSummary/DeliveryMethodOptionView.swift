//
//  DeliveryMethodOptionView.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class DeliveryMethodOptionView: UIControl {

    private(set) var viewModel: DeliveryMethodOptionViewModel
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let costLabel = UILabel()

    init(viewModel: DeliveryMethodOptionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setUp()
        configure(with: viewModel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: DeliveryMethodOptionViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.eta
        costLabel.text = viewModel.costLabel
        layer.borderColor = viewModel.borderColor.cgColor
        backgroundColor = viewModel.backgroundColor
    }

    // MARK: - Setup

    private func setUp() {
        layer.cornerRadius = 8
        layer.borderWidth = 1
        configureLabels()
        layoutContent()
    }

    private func configureLabels() {
        let strong = MuunTheme.Font.Body.mdStrong
        titleLabel.font = strong
        titleLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        costLabel.font = strong
        costLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        descriptionLabel.font = MuunTheme.Font.Body.sm
        descriptionLabel.textColor = MuunTheme.Color.Text.bodySecondary
    }

    private func layoutContent() {
        let headerStack = UIStackView(arrangedSubviews: [titleLabel, costLabel])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center

        let contentStack = UIStackView(arrangedSubviews: [headerStack, descriptionLabel])
        contentStack.axis = .vertical
        contentStack.spacing = MuunTheme.Spacing.xs2
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        // Let touches reach the control instead of being swallowed by the labels.
        contentStack.isUserInteractionEnabled = false

        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor, constant: MuunTheme.Spacing.md),
            contentStack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: MuunTheme.Spacing.md
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -MuunTheme.Spacing.md
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: bottomAnchor,
                constant: -MuunTheme.Spacing.md
            )
        ])
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // CGColor doesn't auto-resolve for dark mode; re-apply from the view model.
        layer.borderColor = viewModel.borderColor.cgColor
    }
}
