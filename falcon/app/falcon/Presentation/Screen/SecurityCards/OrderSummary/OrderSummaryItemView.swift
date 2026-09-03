//
//  OrderSummaryItemView.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

/// A label/value row used in the details and breakdown tables. The value fills the
/// remaining width and wraps (e.g. a long address), right-aligned.
final class OrderSummaryItemView: UIView {

    private let labelView = UILabel()
    private let valueView = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(label: String, value: String, bold: Bool = false) {
        labelView.text = label
        valueView.text = value

        let font = bold ? MuunTheme.Font.Body.mdStrong : MuunTheme.Font.Body.md
        labelView.font = font
        valueView.font = font
        labelView.textColor = bold
            ? MuunTheme.Color.Text.bodyPrimary
            : MuunTheme.Color.Text.bodySecondary
    }

    private func setUp() {
        labelView.setContentHuggingPriority(.required, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.required, for: .horizontal)

        valueView.textColor = MuunTheme.Color.Text.bodyPrimary
        valueView.textAlignment = .right
        valueView.numberOfLines = 0
        valueView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [labelView, valueView])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.md
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: MuunTheme.Spacing.md),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: MuunTheme.Spacing.md),
            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -MuunTheme.Spacing.md
            ),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -MuunTheme.Spacing.md)
        ])
    }
}
