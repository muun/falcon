//
//  ReceivingNodeDetailsViewController.swift
//  falcon
//
//  Created by Federico Jordán on 22/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

final class ReceivingNodeDetailsViewController: MUBottomSheetViewContainer {

    private var presenter: ReceivingNodeDetailsPresenter<ReceivingNodeDetailsViewController>!

    private let publicKeyValueLabel = UILabel()
    // Set by `onLoad` during `setUpView`, before the explorer button can be tapped.
    private var explorerURL: URL!

    init() {
        super.init(screenNameForLogs: "security_cards_receiving_node_details")
        presenter = ReceivingNodeDetailsPresenter(delegate: self)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func setUpView() {
        super.setUpView()

        dialogView.layoutMargins.left = MuunTheme.Spacing.xl
        dialogView.layoutMargins.right = MuunTheme.Spacing.xl

        let title = makeTitle()
        let publicKeySection = makePublicKeySection()
        let explorerButton = makeExplorerButton()
        dialogView.addArrangedSubview(title)
        dialogView.addArrangedSubview(publicKeySection)
        dialogView.addArrangedSubview(explorerButton)

        dialogView.setCustomSpacing(MuunTheme.Spacing.xl3, after: title)
        dialogView.setCustomSpacing(MuunTheme.Spacing.xl3, after: publicKeySection)

        presenter.load()
    }

    // MARK: - Building blocks

    private func makeTitle() -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = L10n.ReceivingNodeDetailsViewController.title
        titleLabel.font = MuunTheme.Font.Heading.h3
        titleLabel.textColor = MuunTheme.Color.Text.heading
        return titleLabel
    }

    private func makePublicKeySection() -> UIView {
        let label = UILabel()
        label.text = L10n.ReceivingNodeDetailsViewController.publicKey
        label.font = MuunTheme.Font.Body.mdStrong
        label.textColor = MuunTheme.Color.Text.bodyPrimary

        publicKeyValueLabel.font = MuunTheme.Font.Body.md
        publicKeyValueLabel.textColor = MuunTheme.Color.Text.bodySecondary
        publicKeyValueLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [label, publicKeyValueLabel])
        stack.axis = .vertical
        stack.spacing = MuunTheme.Spacing.sm
        return stack
    }

    private func makeExplorerButton() -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(L10n.ReceivingNodeDetailsViewController.openInNodeExplorer, for: .normal)
        button.titleLabel?.font = MuunTheme.Font.Body.mdStrong
        button.setTitleColor(MuunTheme.Color.Text.action, for: .normal)
        button.addTarget(self, action: #selector(didTapExplorer), for: .touchUpInside)
        return button
    }

    // MARK: - Actions

    @objc private func didTapExplorer() {
        UIApplication.shared.open(explorerURL)
    }
}

// MARK: - ReceivingNodeDetailsPresenterDelegate

extension ReceivingNodeDetailsViewController: ReceivingNodeDetailsPresenterDelegate {

    func onLoad(_ viewModel: ReceivingNodeDetailsViewModel) {
        publicKeyValueLabel.text = viewModel.publicKey
        explorerURL = viewModel.explorerURL
    }
}

// MARK: - BasePresenterDelegate

// Required by `BasePresenter`; unused since the sheet has no async work that reports back.
extension ReceivingNodeDetailsViewController: BasePresenterDelegate {
    func showMessage(_ message: String) {}
    func pushTo(_ vc: MUViewController) {}
}
