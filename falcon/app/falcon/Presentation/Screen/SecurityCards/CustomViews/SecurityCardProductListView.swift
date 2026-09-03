//
//  SecurityCardProductListView.swift
//  falcon
//
//  Created by Federico Jordán on 13/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol SecurityCardProductListViewDelegate: AnyObject {
    func didTapSeeFullSpecs()
}

final class SecurityCardProductListView: UIView {
    private enum Constants {
        static let seeFullSpecsHeight = MuunTheme.Legacy.s44
        static let iconSize = MuunTheme.Legacy.s18
    }

    private let stackView = UIStackView()
    private let seeFullSpecsButton = UIButton(type: .system)

    private weak var delegate: SecurityCardProductListViewDelegate?

    init(delegate: SecurityCardProductListViewDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        setupStackView()
        setupSeeFullSpecsButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        material: SecurityCardMaterial,
        shipsFrom: String,
        deliveryDays: String,
        providerColor: UIColor
    ) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let rows: [(symbol: String, label: String, valueView: UIView)] = [
            ("creditcard", L10n.BuyDetailsViewController.material, makeMaterialValueView(material)),
            ("shippingbox", L10n.BuyDetailsViewController.shipsFrom, makeValueLabel(shipsFrom)),
            ("clock", L10n.BuyDetailsViewController.deliveryTime, makeValueLabel(deliveryDays))
        ]

        for row in rows {
            stackView.addArrangedSubview(
                makeProductInfoRow(symbol: row.symbol, label: row.label, valueView: row.valueView)
            )
        }

        seeFullSpecsButton.setTitleColor(providerColor, for: .normal)
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setupSeeFullSpecsButton() {
        seeFullSpecsButton.setTitle(L10n.BuyDetailsViewController.seeFullSpecs, for: .normal)
        seeFullSpecsButton.titleLabel?.font = Constant.Fonts.system(size: .opDesc)
        seeFullSpecsButton.contentHorizontalAlignment = .right
        seeFullSpecsButton.addTarget(
            self,
            action: #selector(didTapSeeFullSpecs),
            for: .touchUpInside
        )
        seeFullSpecsButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(seeFullSpecsButton)

        NSLayoutConstraint.activate([
            seeFullSpecsButton.topAnchor.constraint(
                equalTo: stackView.bottomAnchor, constant: MuunTheme.Spacing.sm
            ),
            seeFullSpecsButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            seeFullSpecsButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            seeFullSpecsButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            seeFullSpecsButton.heightAnchor.constraint(
                equalToConstant: Constants.seeFullSpecsHeight
            )
        ])
    }

    private func makeProductInfoRow(symbol: String, label: String, valueView: UIView) -> UIView {
        let icon = UIImageView(image: UIImage(systemName: symbol))
        icon.tintColor = MuunTheme.Color.Text.bodySecondary
        icon.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            icon.heightAnchor.constraint(equalToConstant: Constants.iconSize)
        ])

        let labelView = UILabel()
        labelView.text = label
        labelView.font = Constant.Fonts.system(size: .opDesc)
        labelView.textColor = MuunTheme.Color.Text.bodySecondary

        let leadingStack = UIStackView(arrangedSubviews: [icon, labelView])
        leadingStack.axis = .horizontal
        leadingStack.spacing = MuunTheme.Spacing.xs
        leadingStack.alignment = .center

        return BuyDetailsRowView(leadingView: leadingStack, trailingView: valueView)
    }

    private func makeValueLabel(_ value: String) -> UILabel {
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = Constant.Fonts.system(size: .opDesc)
        valueLabel.textAlignment = .right
        return valueLabel
    }

    private func makeMaterialValueView(_ material: SecurityCardMaterial) -> UIView {
        switch material {
        case .metal:
            let shimmer = ShimmerLabel(
                baseColor: MuunTheme.Color.Text.metal,
                highlightColor: .white
            )
            shimmer.text = material.displayName
            shimmer.font = Constant.Fonts.system(size: .opDesc)
            return shimmer
        case .plastic:
            return makeValueLabel(material.displayName)
        }
    }

    @objc
    private func didTapSeeFullSpecs() {
        delegate?.didTapSeeFullSpecs()
    }
}
