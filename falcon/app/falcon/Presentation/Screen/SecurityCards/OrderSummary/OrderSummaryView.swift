//
//  OrderSummaryView.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

protocol OrderSummaryViewDelegate: AnyObject {
    func didChangeDeliverySpeed(_ speed: DeliveryOption.Speed)
    func didTapCurrencyToggle()
}

/// Scrollable content of the order summary screen. The screen chrome (halo and pinned
/// CTA) lives in `OrderSummaryViewController`. Built once from the view model; only the
/// mutable parts (delivery picker selection and breakdown values) are updated in place.
final class OrderSummaryView: UIView {

    private enum Constants {
        static let cardImageWidth: CGFloat = 120
        static let cardImageHeight: CGFloat = 76
        static let tableCornerRadius: CGFloat = 8
    }

    weak var delegate: OrderSummaryViewDelegate?

    private let contentStack = UIStackView()

    // Only the mutable subviews are retained; everything static is built and forgotten.
    private var deliveryPicker: DeliveryMethodPickerView?
    private var headerTitleLabel: UILabel?
    private let priceRow = OrderSummaryItemView()
    private let shippingAndTaxesRow = OrderSummaryItemView()
    private let totalRow = OrderSummaryItemView()

    init() {
        super.init(frame: .zero)
        setUpContentStack()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Configuration

    func configure(with viewModel: OrderSummaryViewModel) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(makeHeader(imageName: viewModel.securityCardImageName))

        if viewModel.hasMultipleDeliverySpeeds {
            let picker = makeDeliveryPicker(options: viewModel.options)
            let summaryTitle = makeSummaryTitle()
            contentStack.addArrangedSubview(picker)
            contentStack.addArrangedSubview(summaryTitle)
            // A wider gap drops "Summary" lower; it then sits tight to its table.
            contentStack.setCustomSpacing(MuunTheme.Spacing.xl3, after: picker)
            contentStack.setCustomSpacing(MuunTheme.Spacing.xs, after: summaryTitle)
        }

        contentStack.addArrangedSubview(makeShippingTable(viewModel.shippingDetails))
        contentStack.addArrangedSubview(makeBreakdownTable())
        configureBreakdown(viewModel.breakdown)
    }

    func updateSelection(_ speed: DeliveryOption.Speed) {
        deliveryPicker?.updateSelection(speed)
    }

    /// The header title's frame in `target`'s coordinates, for the nav bar
    /// title swap on scroll.
    func headerTitleFrame(in target: UIView) -> CGRect? {
        headerTitleLabel.map { $0.convert($0.bounds, to: target) }
    }

    func configureBreakdown(_ breakdown: OrderSummaryViewModel.BreakdownViewModel) {
        priceRow.configure(label: L10n.OrderSummaryViewController.cardPrice, value: breakdown.price)
        shippingAndTaxesRow.configure(
            label: L10n.OrderSummaryViewController.shippingAndTaxes,
            value: breakdown.shippingAndTaxes
        )
        totalRow.configure(
            label: L10n.OrderSummaryViewController.total,
            value: breakdown.total,
            bold: true
        )
    }

    // MARK: - Building blocks

    private func setUpContentStack() {
        contentStack.axis = .vertical
        contentStack.spacing = MuunTheme.Spacing.lg
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// Title + subtitle on the left, card on the right (prototype's ScreenHeader).
    private func makeHeader(imageName: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = MuunTheme.Font.Heading.h1
        titleLabel.textColor = MuunTheme.Color.Text.heading
        titleLabel.numberOfLines = 0
        titleLabel.text = L10n.OrderSummaryViewController.title
        headerTitleLabel = titleLabel

        let subtitleLabel = UILabel()
        subtitleLabel.font = MuunTheme.Font.Body.md
        subtitleLabel.textColor = MuunTheme.Color.Text.bodySecondary
        subtitleLabel.numberOfLines = 0
        subtitleLabel.text = L10n.OrderSummaryViewController.subtitle

        let textColumn = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textColumn.axis = .vertical
        textColumn.spacing = MuunTheme.Spacing.xs2
        textColumn.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let cardImageView = UIImageView(image: UIImage(named: imageName))
        cardImageView.contentMode = .scaleAspectFit
        cardImageView.setContentHuggingPriority(.required, for: .horizontal)
        cardImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            cardImageView.widthAnchor.constraint(equalToConstant: Constants.cardImageWidth),
            cardImageView.heightAnchor.constraint(equalToConstant: Constants.cardImageHeight)
        ])

        let headerStack = UIStackView(arrangedSubviews: [textColumn, cardImageView])
        headerStack.axis = .horizontal
        headerStack.alignment = .top
        headerStack.spacing = MuunTheme.Spacing.lg
        return headerStack
    }

    private func makeDeliveryPicker(options: [DeliveryMethodOptionViewModel]) -> UIView {
        let picker = DeliveryMethodPickerView(options: options, delegate: self)
        deliveryPicker = picker
        return picker
    }

    private func makeSummaryTitle() -> UIView {
        let label = UILabel()
        label.text = L10n.OrderSummaryViewController.summaryTitle
        label.font = MuunTheme.Font.Heading.h3
        label.textColor = MuunTheme.Color.Text.heading
        return label
    }

    private func makeShippingTable(_ details: OrderSummaryViewModel
        .ShippingDetailsViewModel) -> UIView {
        let rows: [(String, String)] = [
            (L10n.OrderSummaryViewController.detailName, details.name),
            (L10n.OrderSummaryViewController.detailEmail, details.email),
            (L10n.OrderSummaryViewController.detailAddress, details.address)
        ]
        let stack = makeTableStack()
        for (label, value) in rows {
            let row = OrderSummaryItemView()
            row.configure(label: label, value: value)
            stack.addArrangedSubview(row)
        }
        return stack
    }

    private func makeBreakdownTable() -> UIView {
        let stack = makeTableStack()
        [priceRow, shippingAndTaxesRow, totalRow].forEach { stack.addArrangedSubview($0) }
        stack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapCurrency))
        )
        return stack
    }

    private func makeTableStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.layer.cornerRadius = Constants.tableCornerRadius
        stack.layer.borderWidth = 1
        stack.layer.borderColor = MuunTheme.Color.Border.primary.cgColor
        stack.clipsToBounds = true
        stack.backgroundColor = MuunTheme.Color.Surface.field
        return stack
    }

    // MARK: - Actions

    @objc private func didTapCurrency() {
        delegate?.didTapCurrencyToggle()
    }
}

// MARK: - DeliveryMethodPickerViewDelegate

extension OrderSummaryView: DeliveryMethodPickerViewDelegate {
    func didSelectDeliverySpeed(_ speed: DeliveryOption.Speed) {
        delegate?.didChangeDeliverySpeed(speed)
    }
}
