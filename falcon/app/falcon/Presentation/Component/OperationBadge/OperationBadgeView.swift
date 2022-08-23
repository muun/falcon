//
//  OperationBadgeView.swift
//  falcon
//
//  Created by Manu Herrera on 15/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit
import core

final class OperationBadgeView: UIView {

    private var contentView: UIView! = UIView()
    private var amountLabel: UILabel! = UILabel()

    init() {
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpContentView()
        setUpLabel()
    }

    private func setUpContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.roundCorners(cornerRadius: 4)
        addSubview(contentView)

        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

    private func setUpLabel() {
        amountLabel.numberOfLines = 1
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.font = Constant.Fonts.system(size: .opHelper, weight: .medium)
        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        contentView.addSubview(amountLabel)

        NSLayoutConstraint.activate([
            amountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            amountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            amountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            amountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            amountLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            amountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    private func setStyle(_ direction: OperationDirection) {
        if direction == .OUTGOING || direction == .CYCLICAL {
            contentView.backgroundColor = Asset.Colors.muunBlueLight.color
            amountLabel.textColor = Asset.Colors.muunBlue.color
        } else {
            contentView.backgroundColor = Asset.Colors.muunGreenOpsBadgeBackground.color
            amountLabel.textColor = Asset.Colors.muunGreenOpsBadgeText.color
        }
    }

    // MARK: - Actions -

    func setText(_ bitcoinAmount: MonetaryAmount, direction: OperationDirection) {
        let message: String
        let formattedCurrency = bitcoinAmount.toAmountPlusCode(btcCurrencyFormat: .short)
        if direction == .OUTGOING || direction == .CYCLICAL {
            message = "- \(formattedCurrency)"
        } else {
            message = "+ \(formattedCurrency)"
        }
        amountLabel.text = message
        setStyle(direction)
    }

    func animate(opDirection: OperationDirection) {
        let animationDirection: AnimationDirection = (opDirection == .OUTGOING || opDirection == .CYCLICAL)
            ? .bottomToTop
            : .topToBottom

        animate(direction: animationDirection, offset: 48, duration: .opsBadge) {
            // The delay is because it stays frozen in the homescreen for a while
            self.animateOut(direction: animationDirection, offset: 48, duration: .long, delay: .opsBadge) {
                self.removeFromSuperview()
            }
        }
    }

}
