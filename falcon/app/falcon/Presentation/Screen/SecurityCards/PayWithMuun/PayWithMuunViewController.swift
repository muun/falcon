//
//  PayWithMuunViewController.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class PayWithMuunViewController: MUBottomSheetViewContainer {

    private enum Constants {
        static let closeButtonSize: CGFloat = 26
        static let dividerHeight: CGFloat = 1
        static let sendButtonHeight: CGFloat = 50
    }

    private var presenter: PayWithMuunPresenter<PayWithMuunViewController>!

    private let amountValueLabel = UILabel()
    private let networkFeeValueLabel = UILabel()
    private let totalValueLabel = UILabel()
    private let providerNameLabel = UILabel()

    init(provider: SecurityCardProvider, orderTotal: Decimal) {
        super.init(screenNameForLogs: "security_cards_pay_with_muun")
        presenter = PayWithMuunPresenter(
            delegate: self,
            provider: provider,
            orderTotal: orderTotal
        )
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setUpView() {
        super.setUpView()

        dialogView.layoutMargins.left = MuunTheme.Spacing.xl
        dialogView.layoutMargins.right = MuunTheme.Spacing.xl

        let header = makeHeader()
        let recipientRow = makeRecipientRow()
        let breakdown = makeBreakdown()
        dialogView.addArrangedSubview(header)
        dialogView.addArrangedSubview(recipientRow)
        dialogView.addArrangedSubview(breakdown)
        dialogView.addArrangedSubview(makeSendButton())

        dialogView.setCustomSpacing(MuunTheme.Spacing.xl3, after: header)
        dialogView.setCustomSpacing(MuunTheme.Spacing.xl, after: recipientRow)
        dialogView.setCustomSpacing(MuunTheme.Spacing.xl3, after: breakdown)

        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.setUp()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.tearDown()
    }

    // MARK: - Building blocks

    private func makeHeader() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = L10n.PayWithMuunViewController.title
        titleLabel.font = MuunTheme.Font.Heading.h3
        titleLabel.textColor = MuunTheme.Color.Text.heading
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let closeButton = UIButton(type: .system)
        closeButton.setImage(Asset.Assets.navClose.image, for: .normal)
        closeButton.tintColor = MuunTheme.Color.Text.bodyPrimary
        closeButton.setContentHuggingPriority(.required, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        closeButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: Constants.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: Constants.closeButtonSize)
        ])

        let stack = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }

    private func makeRecipientRow() -> UIView {
        let label = UILabel()
        label.text = L10n.PayWithMuunViewController.to
        label.font = MuunTheme.Font.Body.mdStrong
        label.textColor = MuunTheme.Color.Text.bodyPrimary
        label.setContentHuggingPriority(.required, for: .horizontal)

        providerNameLabel.font = MuunTheme.Font.Body.md
        providerNameLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        providerNameLabel.textAlignment = .right
        providerNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let eyeImageView = UIImageView(image: Asset.Assets.passwordShow.image)
        eyeImageView.tintColor = MuunTheme.Color.Text.bodySecondary
        eyeImageView.contentMode = .scaleAspectFit
        eyeImageView.setContentHuggingPriority(.required, for: .horizontal)

        let recipient = UIStackView(arrangedSubviews: [providerNameLabel, eyeImageView])
        recipient.axis = .horizontal
        recipient.alignment = .center
        recipient.spacing = MuunTheme.Spacing.xs
        recipient.isUserInteractionEnabled = true
        recipient.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapRecipient))
        )

        let stack = UIStackView(arrangedSubviews: [label, recipient])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.md
        return stack
    }

    private func makeBreakdown() -> UIView {
        let stack = UIStackView(arrangedSubviews: [
            makeDivider(),
            makeBreakdownRow(
                label: L10n.PayWithMuunViewController.amount,
                valueLabel: amountValueLabel
            ),
            makeBreakdownRow(
                label: L10n.PayWithMuunViewController.networkFee,
                valueLabel: networkFeeValueLabel
            ),
            makeBreakdownRow(
                label: L10n.PayWithMuunViewController.total,
                valueLabel: totalValueLabel,
                bold: true
            ),
            makeDivider()
        ])
        stack.axis = .vertical
        stack.spacing = MuunTheme.Spacing.xl
        stack.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapCurrency))
        )
        return stack
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = MuunTheme.Color.Border.primary
        divider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight).isActive = true
        return divider
    }

    private func makeBreakdownRow(
        label: String,
        valueLabel: UILabel,
        bold: Bool = false
    ) -> UIView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = bold ? MuunTheme.Font.Body.mdStrong : MuunTheme.Font.Body.md
        labelView.textColor = bold
            ? MuunTheme.Color.Text.bodyPrimary
            : MuunTheme.Color.Text.bodySecondary
        labelView.setContentHuggingPriority(.required, for: .horizontal)

        valueLabel.font = bold ? MuunTheme.Font.Body.mdStrong : MuunTheme.Font.Body.md
        valueLabel.textColor = MuunTheme.Color.Text.bodyPrimary
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [labelView, valueLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = MuunTheme.Spacing.md
        return stack
    }

    private func makeSendButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(L10n.PayWithMuunViewController.send, for: .normal)
        button.titleLabel?.font = MuunTheme.Font.Body.mdStrong
        button.setTitleColor(MuunTheme.Component.Button.textPrimary, for: .normal)
        button.backgroundColor = MuunTheme.Component.Button.primary
        button.layer.cornerRadius = MuunTheme.Component.Button.cornerRadius
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: Constants.sendButtonHeight).isActive = true
        return button
    }

    // MARK: - Actions

    @objc private func didTapCurrency() {
        presenter.didTapCurrencyToggle()
    }

    @objc private func didTapRecipient() {
        present(ReceivingNodeDetailsViewController(), animated: true)
    }

    @objc private func didTapSend() {
        // TODO: trigger the real payment and present the success screen (follow-up PR).
    }
}

// MARK: - PayWithMuunPresenterDelegate

extension PayWithMuunViewController: PayWithMuunPresenterDelegate {

    func onLoad(_ viewModel: PayWithMuunViewModel) {
        providerNameLabel.text = viewModel.providerName
        onChange(breakdown: viewModel.breakdown)
    }

    func onChange(breakdown: PayWithMuunViewModel.BreakdownViewModel) {
        amountValueLabel.text = breakdown.amount
        networkFeeValueLabel.text = breakdown.networkFee
        totalValueLabel.text = breakdown.total
    }
}

// MARK: - BasePresenterDelegate

// Required by `BasePresenter`; unused since the sheet has no async work that reports back.
extension PayWithMuunViewController: BasePresenterDelegate {
    func showMessage(_ message: String) {}
    func pushTo(_ vc: MUViewController) {}
}
