//
//  AmountLabel.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

enum AmountLabelType {
    case inBTC
    case inInput
    case inPrimary
}

protocol AmountLabelDelegate: class {
    func didTouchBitcoinLabel()
}

class AmountLabel: UILabel {

    public weak var delegate: AmountLabelDelegate?
    public var shouldCycle = false {
        didSet {
            if shouldCycle {
                addGestureRecognizer(UITapGestureRecognizer(target: self, action: .amountTouched))
                isUserInteractionEnabled = true
            }
        }
    }
    private var bitcoinAmount: BitcoinAmount?

    @objc fileprivate func amountTouched() {
        delegate?.didTouchBitcoinLabel()
    }

    private func readableAmount(from bitcoinAmount: BitcoinAmount, in type: AmountLabelType) -> NSAttributedString {
        switch type {
        case .inBTC:
            return bitcoinAmount.inSatoshis.toBTC().toAttributedString(with: font)
        case .inInput:
            return bitcoinAmount.inInputCurrency.toAttributedString(with: font)
        case .inPrimary:
            return bitcoinAmount.inPrimaryCurrency.toAttributedString(with: font)
        }
    }

    /*
     This method switches between the readable values
     I.E.:
     - Input Currency: USD, Main Currency: ARS, Amount 1
     - inInput: 1 USD, inPrimary: 43.05 ARS, inBTC: 0.000002 BTC
     */
    func cycleCurrency(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let bitcoinAmount = bitcoinAmount else {
            return
        }

        let nextAmount = nextValue(for: bitcoinAmount)
        if animated {
            setTextAnimated(nextAmount, completion: completion)
        } else {
            attributedText = nextAmount
        }
    }

    private func nextValue(for bitcoinAmount: BitcoinAmount) -> NSAttributedString {
        let currentValue = self.attributedText!.string
        let amountInInput = readableAmount(from: bitcoinAmount, in: .inInput)
        let amountInPrimary = readableAmount(from: bitcoinAmount, in: .inPrimary)
        let amountInBTC = readableAmount(from: bitcoinAmount, in: .inBTC)

        if currentValue == amountInInput.string {
            if currentValue == amountInPrimary.string {
                return amountInBTC
            }
            return amountInPrimary
        } else if currentValue == amountInPrimary.string {
            if currentValue == amountInBTC.string {
                return amountInInput
            }
            return amountInBTC
        } else if currentValue == amountInBTC.string {
            if currentValue == amountInInput.string {
                return amountInPrimary
            }
            return amountInInput
        }
        return amountInBTC
    }

    func setAmount(from bitcoinAmount: BitcoinAmount, in type: AmountLabelType) {
        self.bitcoinAmount = bitcoinAmount
        self.attributedText = readableAmount(from: bitcoinAmount, in: type)
    }

    // This set texts inside () brackets
    // I.E: (100.53 ARS)
    func setHelperText(for bitcoinAmount: BitcoinAmount,
                       in type: AmountLabelType) {
        self.bitcoinAmount = bitcoinAmount
        let amountString = readableAmount(from: bitcoinAmount, in: type).string
        self.text = "(\(amountString))"
    }

    private func setTextAnimated(_ text: NSAttributedString, completion: (() -> Void)? = nil) {
        if attributedText == text {
            return
        }
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0.2
        }, completion: { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.attributedText = text
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, animations: {
                    self.alpha = 1
                }, completion: { _ in
                    completion?()
                })
            })
        })
    }

}

fileprivate extension Selector {
    static let amountTouched = #selector(AmountLabel.amountTouched)
}
