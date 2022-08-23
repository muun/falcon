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

protocol AmountLabelDelegate: AnyObject {
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
    private var bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency?
    private var contextBitcoinCurrency: Currency?

    @objc fileprivate func amountTouched() {
        delegate?.didTouchBitcoinLabel()
    }

    /// Become a value readable.
    /// bitcoin unit on formatting is inferred from selectedCurrency on bitcoinAmountWithCurrency.
    /// - Parameters:
    ///   - bitcoinAmountWithCurrency: Value to be parsed
    ///   - type: Desired output type
    /// - Returns: A formatted output (25 USD)
    private func readableAmount(from bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency,
                                in type: AmountLabelType) -> NSAttributedString {
        let selectedCurrency = bitcoinAmountWithCurrency.selectedCurrency
        let contextBitcoinCurrency = getBitcoinCurrencyGiven(selectedCurrency: selectedCurrency)
        self.contextBitcoinCurrency = contextBitcoinCurrency

        let value = getValueToBecomeReadableIn(bitcoinAmount: bitcoinAmountWithCurrency.bitcoinAmount, type: type)
        return getFormattedStringFor(value: value,
                                     contextBitcoinCurrency: contextBitcoinCurrency)
    }

    /// Retrieves bitcoinCurrency.
    /// If user selection is already a bitcoinCurrency this method chooses
    /// user selection in order to keep bitcoin unit selected by user.
    private func getBitcoinCurrencyGiven(selectedCurrency: Currency) -> BitcoinCurrency {
        guard let bitcoinCurrency = selectedCurrency as? BitcoinCurrency else {
            return GetBTCDefaultSelectedUnit.run()
        }
        return bitcoinCurrency
    }

    private func getValueToBecomeReadableIn(bitcoinAmount: BitcoinAmount, type: AmountLabelType) -> MonetaryAmount {
        switch type {
        case .inBTC:
            return bitcoinAmount.inSatoshis.toBTC()
        case .inInput:
            return bitcoinAmount.inInputCurrency
        case .inPrimary:
            return bitcoinAmount.inPrimaryCurrency
        }
    }

    private func getFormattedStringFor(value: MonetaryAmount,
                                       contextBitcoinCurrency: Currency) -> NSAttributedString {
        let currency: Currency

        if value.currency == "BTC" {
            currency = contextBitcoinCurrency
        } else {
            currency = GetCurrencyForCode().runAssumingCrashPosibility(code: value.currency)
        }

        var attributedString = NSMutableAttributedString()
        let amountString = currency.toAmountWithoutCode(amount: value.amount, btcCurrencyFormat: .long)
        attributedString = NSMutableAttributedString(
            string: "\(amountString) \(currency.displayCode)",
            attributes: [NSAttributedString.Key.font: font as Any])
        return attributedString.set(tint: amountString, color: Asset.Colors.title.color)
    }

    /*
     This method switches between the readable values
     I.E.:
     - Input Currency: USD, Main Currency: ARS, Amount 1
     - inInput: 1 USD, inPrimary: 43.05 ARS, inBTC: 0.000002 BTC
     */
    func cycleCurrency(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let bitcoinAmountWithCurrency = bitcoinAmountWithCurrency else {
            return
        }

        let nextAmount = nextValue(for: bitcoinAmountWithCurrency)
        if animated {
            setTextAnimated(nextAmount, completion: completion)
        } else {
            attributedText = nextAmount
        }
    }

    private func nextValue(for bitcoinAmountWithSelectedCurrency: BitcoinAmountWithSelectedCurrency) -> NSAttributedString {
        let currentValue = self.attributedText!.string
        let amountInInput = readableAmount(from: bitcoinAmountWithSelectedCurrency, in: .inInput)
        let amountInPrimary = readableAmount(from: bitcoinAmountWithSelectedCurrency, in: .inPrimary)
        let amountInBTC = readableAmount(from: bitcoinAmountWithSelectedCurrency, in: .inBTC)

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

    /// Set amount passing the different kind of values to be switched on tap inside BitcoinAmount
    /// - Parameters:
    ///   - bitcoinAmountWithCurrency: value to be displayed. Keep in mind by default value will be switched
    ///   in between selectedCurrency, defaultCurrency and BTC on users tap
    ///   - type: default value type to ve displayed (selected, default or BTC currency)
    func setAmount(from bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency, in type: AmountLabelType) {
        self.bitcoinAmountWithCurrency = bitcoinAmountWithCurrency
        self.attributedText = readableAmount(from: bitcoinAmountWithCurrency, in: type)
    }

    // This set texts inside () brackets
    // I.E: (100.53 ARS)
    func setHelperText(for bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency,
                       in type: AmountLabelType) {
        self.bitcoinAmountWithCurrency = bitcoinAmountWithCurrency
        let amountString = readableAmount(from: bitcoinAmountWithCurrency, in: type).string
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
