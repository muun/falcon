//
//  BuyDetailsRowView.swift
//  falcon
//
//  Created by Federico Jordán on 13/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class BuyDetailsRowView: UIView {
    private enum Constants {
        static let rowHeight = MuunTheme.Legacy.s44
    }

    init(leadingView: UIView, trailingView: UIView) {
        super.init(frame: .zero)

        leadingView.translatesAutoresizingMaskIntoConstraints = false
        trailingView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(leadingView)
        addSubview(trailingView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Constants.rowHeight),
            leadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            leadingView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trailingView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trailingView.centerYAnchor.constraint(equalTo: centerYAnchor),
            leadingView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingView.leadingAnchor, constant: -MuunTheme.Spacing.xs
            )
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
