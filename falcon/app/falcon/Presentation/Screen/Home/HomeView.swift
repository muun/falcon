//
//  HomeView.swift
//  falcon
//
//  Created by Manu Herrera on 27/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit


protocol HomeViewDelegate: AnyObject {
    func sendButtonTap()
    func receiveButtonTap()
    func chevronTap()
    func companionTap()
    func balanceTap()
    func didShowTransactionListTooltip()
}

final class HomeView: UIView {

    private var contentView: UIView! = UIView()
    private var contentVerticalStack: UIStackView! = UIStackView()
    private var tooltipView = TooltipView(message: L10n.Home.transactionListTooltip)
    private var balanceView: BalanceView!
    private var actionCardView = ActionCardView()
    private var blockClock = BlockClockView()
    private var blockClockContainer = UIView()
    private var currentCompanionView: UIView?
    private var chevronView: ChevronView!

    private weak var delegate: HomeViewDelegate?

    // We should set the max width to 480px so it doesn't break on larger screens (like iPads in the future)
    private let maxStackViewWidth: CGFloat = 480

    init(delegate: HomeViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpContentView()
        setUpChevronView()
        setUpBlockClock()
        actionCardView.delegate = self

        makeViewTestable()
    }

    private func setUpBlockClock() {
        blockClock.translatesAutoresizingMaskIntoConstraints = false
        blockClockContainer.translatesAutoresizingMaskIntoConstraints = false
        blockClockContainer.addSubview(blockClock)
        NSLayoutConstraint.activate([
            blockClock.centerXAnchor.constraint(equalTo: blockClockContainer.centerXAnchor),
            blockClock.centerYAnchor.constraint(equalTo: blockClockContainer.centerYAnchor),
            blockClock.heightAnchor.constraint(equalTo: blockClockContainer.heightAnchor),

            blockClockContainer.leadingAnchor.constraint(lessThanOrEqualTo: blockClock.leadingAnchor),
            blockClock.trailingAnchor.constraint(lessThanOrEqualTo: blockClockContainer.trailingAnchor)
        ])

        blockClock.isUserInteractionEnabled = true
        blockClock.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(blockClockTapped)
        ))
    }

    private func setUpChevronView() {
        chevronView = ChevronView(delegate: self)
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(chevronView)
        NSLayoutConstraint.activate([
            chevronView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            chevronView.leadingAnchor.constraint(equalTo: leadingAnchor),
            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    private func setUpContentView() {
        contentView.backgroundColor = .clear

        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        setUpStackView()
    }

    private func setUpStackView() {
        contentVerticalStack = UIStackView()
        contentVerticalStack.axis = .vertical
        contentVerticalStack.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.spacing = 16
        contentVerticalStack.alignment = .fill

        contentView.addSubview(contentVerticalStack)

        let leadingConstraint = contentVerticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                                              constant: .sideMargin)
        leadingConstraint.priority = UILayoutPriority(999)
        let trailingConstraint = contentVerticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                                               constant: -.sideMargin)
        trailingConstraint.priority = UILayoutPriority(999)

        NSLayoutConstraint.activate([
            contentVerticalStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentVerticalStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentVerticalStack.widthAnchor.constraint(lessThanOrEqualToConstant: maxStackViewWidth),
            leadingConstraint,
            trailingConstraint
        ])

        addBalanceComponent()
    }

    private func addBalanceComponent() {
        balanceView = BalanceView(delegate: self)
        balanceView.translatesAutoresizingMaskIntoConstraints = false
        contentVerticalStack.addArrangedSubview(balanceView)
    }

    // MARK: - View Controller actions -

    func show(actionCard: ActionCardModel) {
        ensureCompanionVisible(actionCardView)
        contentVerticalStack.setCustomSpacing(.headerSpacing, after: balanceView)
        actionCardView.setUp(actionCard: actionCard)
    }

    func show(blocksLeft: UInt) {
        ensureCompanionVisible(blockClockContainer)
        contentVerticalStack.setCustomSpacing(.bigSpacing, after: balanceView)
        blockClock.blocks = blocksLeft
    }

    private func ensureCompanionVisible(_ view: UIView) {
        if let currentCompanionView = currentCompanionView,
           currentCompanionView != view {

            currentCompanionView.removeFromSuperview()
        }

        currentCompanionView = view
        if !contentVerticalStack.contains(view) {
            contentVerticalStack.addArrangedSubview(view)
        }
    }

    func hideCompanion() {
        currentCompanionView?.removeFromSuperview()
    }

    func updateBalanceAndChevron(state: OperationsState) {
        chevronView.updateOperationsState(state)
        balanceView.updateOperationsState(state)
    }

    func setUp(btcBalance: MonetaryAmount, primaryBalance: MonetaryAmount, isBalanceHidden: Bool) {
        balanceView.setUp(btcBalance: btcBalance, primaryBalance: primaryBalance, isBalanceHidden: isBalanceHidden)
    }

    func setBalanceHidden(_ isHidden: Bool) {
        balanceView.setUpBalance(isHidden, animated: true)
    }

    func hideTooltip() {
        tooltipView.isHidden = true
    }

    func displayTooltip() {
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tooltipView)

        NSLayoutConstraint.activate([
            tooltipView.bottomAnchor.constraint(equalTo: chevronView.topAnchor),
            tooltipView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tooltipView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        tooltipView.show {
            self.delegate?.didShowTransactionListTooltip()
        }
    }

    func displayOpsBadge(bitcoinAmount: MonetaryAmount, direction: OperationDirection) {
        let opsBadgeView = OperationBadgeView()
        opsBadgeView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(opsBadgeView)
        NSLayoutConstraint.activate([
            opsBadgeView.bottomAnchor.constraint(equalTo: balanceView.topAnchor, constant: -.sideMargin),
            opsBadgeView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            opsBadgeView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor),
            opsBadgeView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        opsBadgeView.setText(bitcoinAmount, direction: direction)
        opsBadgeView.animate(opDirection: direction)
    }

    // MARK: - UI events -

    @objc func blockClockTapped() {
        delegate?.companionTap()
    }
}

extension HomeView: ActionCardDelegate {

    func push(nextViewController: UIViewController) {
        delegate?.companionTap()
    }
}

extension HomeView: BalanceViewDelegate {

    func balanceTap() {
        delegate?.balanceTap()
    }

    func receiveTap() {
        delegate?.receiveButtonTap()
    }

    func sendTap() {
        delegate?.sendButtonTap()
    }

}

extension HomeView: ChevronViewDelegate {
    func chevronTap() {
        delegate?.chevronTap()
    }
}

extension HomeView: UITestablePage {

    typealias UIElementType = UIElements.Pages.HomePage

    func makeViewTestable() {
        makeViewTestable(chevronView, using: .chevron)
    }

}
