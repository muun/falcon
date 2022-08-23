//
//  BalanceView.swift
//  falcon
//
//  Created by Manu Herrera on 27/11/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

protocol BalanceViewDelegate: AnyObject {
    func balanceTap()
    func receiveTap()
    func sendTap()
}

final class BalanceView: UIView {

    private var clockImageView: UIImageView! = UIImageView()
    private var balanceTappableContainerView: UIView! = UIView()
    private var bitcoinAmountContainerView: UIView! = UIView()
    private var bitcoinBalanceLabel: UILabel! = UILabel()
    private var bitcoinCurrencyLabel: UILabel! = UILabel()
    private var primaryBalanceLabel: UILabel! = UILabel()
    private var buttonsContainerView: UIView! = UIView()
    private var receiveButton: SmallButtonView! = SmallButtonView()
    private var sendButton: SmallButtonView! = SmallButtonView()

    private weak var delegate: BalanceViewDelegate?

    private var btcBalance: MonetaryAmount?
    private var primaryBalance: MonetaryAmount?

    init(delegate: BalanceViewDelegate?) {
        self.delegate = delegate
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpBalances()
        setUpButtons()

        makeViewTestable()
    }

    private func setUpBalances() {
        balanceTappableContainerView.isUserInteractionEnabled = true
        balanceTappableContainerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .balanceTap))
        balanceTappableContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(balanceTappableContainerView)
        NSLayoutConstraint.activate([
            balanceTappableContainerView.topAnchor.constraint(equalTo: topAnchor),
            balanceTappableContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            balanceTappableContainerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        bitcoinAmountContainerView.translatesAutoresizingMaskIntoConstraints = false
        balanceTappableContainerView.addSubview(bitcoinAmountContainerView)
        NSLayoutConstraint.activate([
            bitcoinAmountContainerView.topAnchor.constraint(equalTo: balanceTappableContainerView.topAnchor),
            bitcoinAmountContainerView.centerXAnchor.constraint(equalTo: balanceTappableContainerView.centerXAnchor),
            bitcoinAmountContainerView.leadingAnchor.constraint(
                greaterThanOrEqualTo: balanceTappableContainerView.leadingAnchor
            ),
            bitcoinAmountContainerView.trailingAnchor.constraint(
                lessThanOrEqualTo: balanceTappableContainerView.trailingAnchor
            )
        ])

        setUpBalanceLabels()
    }

    fileprivate func setUpBalanceLabels() {
        bitcoinBalanceLabel.numberOfLines = 1
        bitcoinBalanceLabel.font = Constant.Fonts.system(size: .bitcoinAmountHome, weight: .bold)
        bitcoinBalanceLabel.textColor = Asset.Colors.title.color
        bitcoinBalanceLabel.textAlignment = .center
        bitcoinBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        bitcoinAmountContainerView.addSubview(bitcoinBalanceLabel)

        bitcoinCurrencyLabel.numberOfLines = 1
        bitcoinCurrencyLabel.font = Constant.Fonts.system(size: .h1, weight: .bold)
        bitcoinCurrencyLabel.textColor = Asset.Colors.title.color
        bitcoinCurrencyLabel.textAlignment = .center
        bitcoinCurrencyLabel.translatesAutoresizingMaskIntoConstraints = false
        bitcoinAmountContainerView.addSubview(bitcoinCurrencyLabel)

        NSLayoutConstraint.activate([
            bitcoinBalanceLabel.leadingAnchor.constraint(equalTo: bitcoinAmountContainerView.leadingAnchor),
            bitcoinBalanceLabel.bottomAnchor.constraint(equalTo: bitcoinAmountContainerView.bottomAnchor),
            bitcoinBalanceLabel.topAnchor.constraint(equalTo: bitcoinAmountContainerView.topAnchor),

            bitcoinCurrencyLabel.leadingAnchor.constraint(equalTo: bitcoinBalanceLabel.trailingAnchor, constant: 6),
            bitcoinCurrencyLabel.trailingAnchor.constraint(equalTo: bitcoinAmountContainerView.trailingAnchor),
            bitcoinCurrencyLabel.firstBaselineAnchor.constraint(equalTo: bitcoinBalanceLabel.firstBaselineAnchor)
        ])

        bitcoinBalanceLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        bitcoinBalanceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        bitcoinCurrencyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        bitcoinCurrencyLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        setUpClockImage()
        setUpPrimaryCurrencyLabel()
    }

    fileprivate func setUpClockImage() {
        clockImageView.isHidden = true
        clockImageView.image = Asset.Assets.pendingClock.image
        clockImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(clockImageView)

        NSLayoutConstraint.activate([
            clockImageView.trailingAnchor.constraint(equalTo: bitcoinAmountContainerView.leadingAnchor, constant: -8),
            clockImageView.centerYAnchor.constraint(equalTo: bitcoinAmountContainerView.centerYAnchor),
            clockImageView.heightAnchor.constraint(equalToConstant: 20),
            clockImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
    }

    fileprivate func setUpPrimaryCurrencyLabel() {
        primaryBalanceLabel.numberOfLines = 1
        primaryBalanceLabel.style = .description
        primaryBalanceLabel.textAlignment = .center
        primaryBalanceLabel.translatesAutoresizingMaskIntoConstraints = false
        balanceTappableContainerView.addSubview(primaryBalanceLabel)

        NSLayoutConstraint.activate([
            primaryBalanceLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            primaryBalanceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            primaryBalanceLabel.topAnchor.constraint(equalTo: bitcoinAmountContainerView.bottomAnchor, constant: 4),
            primaryBalanceLabel.bottomAnchor.constraint(equalTo: balanceTappableContainerView.bottomAnchor)
        ])
    }

    private func setUpButtons() {
        buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(buttonsContainerView)

        NSLayoutConstraint.activate([
            buttonsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            buttonsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            buttonsContainerView.topAnchor.constraint(equalTo: primaryBalanceLabel.bottomAnchor, constant: 48),
            buttonsContainerView.heightAnchor.constraint(equalToConstant: 40),
            buttonsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        receiveButton.isEnabled = true
        receiveButton.buttonText = L10n.Home.receiveCTA
        receiveButton.delegate = self
        receiveButton.backgroundColor = .clear

        sendButton.isEnabled = true
        sendButton.buttonText = L10n.Home.sendCTA
        sendButton.delegate = self
        sendButton.backgroundColor = .clear

        receiveButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.addSubview(receiveButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsContainerView.addSubview(sendButton)

        NSLayoutConstraint.activate([
            sendButton.widthAnchor.constraint(equalTo: receiveButton.widthAnchor),

            receiveButton.leadingAnchor.constraint(equalTo: buttonsContainerView.leadingAnchor),
            receiveButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            receiveButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor),

            sendButton.leadingAnchor.constraint(equalTo: receiveButton.trailingAnchor, constant: .sideMargin),
            sendButton.trailingAnchor.constraint(equalTo: buttonsContainerView.trailingAnchor),
            sendButton.topAnchor.constraint(equalTo: buttonsContainerView.topAnchor),
            sendButton.bottomAnchor.constraint(equalTo: buttonsContainerView.bottomAnchor)
        ])
    }

    @objc func balanceTap() {
        delegate?.balanceTap()
    }

    private func populateBalanceLabels(animated: Bool = false) {
        guard let btcBalance = self.btcBalance, let primaryBalance = self.primaryBalance else {
            return
        }

        if animated {
            hideLabelsForAnimationInitialState()
        }
        let currencyByCode = GetCurrencyForCode().runDefaultingFiat(code: btcBalance.currency)
        bitcoinBalanceLabel.text = currencyByCode.toAmountWithoutCode(amount: btcBalance.amount,
                                                                      btcCurrencyFormat: .long)
        bitcoinCurrencyLabel.text = currencyByCode.displayCode
        if primaryBalance.currency == btcBalance.currency {
            primaryBalanceLabel.isHidden = true
        } else {
            primaryBalanceLabel.isHidden = false
            primaryBalanceLabel.text = primaryBalance.toAmountPlusCode()
        }

        if animated {
            showLabelsForAnimationFinalState()
        }
    }

    private func setLabelsInHiddenState(animated: Bool = false) {
        if animated {
            hideLabelsForAnimationInitialState()
        }

        bitcoinBalanceLabel.text = L10n.BalanceView.hiddenBalance
        bitcoinCurrencyLabel.text = "" // Necessary to make the *** centered
        primaryBalanceLabel.text = L10n.BalanceView.tapToRevealBalance
        primaryBalanceLabel.isHidden = false

        if animated {
            showLabelsForAnimationFinalState()
        }
    }

    private func hideLabelsForAnimationInitialState() {
        bitcoinBalanceLabel.alpha = 0
        bitcoinCurrencyLabel.alpha = 0
        primaryBalanceLabel.alpha = 0
    }

    private func showLabelsForAnimationFinalState() {
        bitcoinBalanceLabel.alpha = 1
        bitcoinCurrencyLabel.alpha = 1
        primaryBalanceLabel.alpha = 1
    }

    // MARK: - Actions -

    func setUp(btcBalance: MonetaryAmount, primaryBalance: MonetaryAmount, isBalanceHidden: Bool) {
        self.btcBalance = btcBalance
        self.primaryBalance = primaryBalance

        setUpBalance(isBalanceHidden, animated: false)
    }

    func setUpBalance(_ isHidden: Bool, animated: Bool) {
        bitcoinCurrencyLabel.isHidden = isHidden

        if animated {
            UIView.animate(withDuration: 0.35) {
                self.decideBalanceVisibility(isHidden: isHidden, animated: true)
            }
        } else {
            decideBalanceVisibility(isHidden: isHidden, animated: false)
        }

    }

    fileprivate func decideBalanceVisibility(isHidden: Bool, animated: Bool) {
        if isHidden {
            self.setLabelsInHiddenState(animated: animated)
        } else {
            self.populateBalanceLabels(animated: animated)
        }
    }

    func updateOperationsState(_ state: core.OperationsState) {
        switch state {
        case .confirmed:
            clockImageView.isHidden = true
        case .pending:
            clockImageView.isHidden = false
            clockImageView.tintColor = Asset.Colors.muunWarning.color
        case .cancelable:
            clockImageView.isHidden = false
            clockImageView.tintColor = Asset.Colors.muunWarningRBF.color
        }
    }

}

extension BalanceView: SmallButtonViewDelegate {

    func button(didPress button: SmallButtonView) {
        if button == receiveButton {
            delegate?.receiveTap()
        } else if button == sendButton {
            delegate?.sendTap()
        }
    }

}

extension BalanceView: UITestablePage {

    typealias UIElementType = UIElements.Pages.HomePage

    func makeViewTestable() {
        makeViewTestable(sendButton, using: .send)
        makeViewTestable(receiveButton, using: .receive)
        makeViewTestable(bitcoinBalanceLabel, using: .balance)
    }

}

fileprivate extension Selector {
    static let balanceTap = #selector(BalanceView.balanceTap)
}
