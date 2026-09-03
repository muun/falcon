//
//  AmountLabel.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

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

    /// Set amount passing the different kind of values to be switched on tap inside BitcoinAmount
    /// - Parameters:
    ///   - bitcoinAmountWithCurrency: value to be displayed. Keep in mind by default value will be
    /// switched
    ///   in between selectedCurrency, defaultCurrency and BTC on users tap
    ///   - type: default value type to ve displayed (selected, default or BTC currency)
    func setAmount(
        from bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency,
        in type: AmountLabelType
    ) {
        self.bitcoinAmountWithCurrency = bitcoinAmountWithCurrency
        self.attributedText = readableAmount(from: bitcoinAmountWithCurrency, in: type)
    }

    // This set texts inside () brackets
    // I.E: (100.53 ARS)
    func setHelperText(
        for bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency,
        in type: AmountLabelType
    ) {
        self.bitcoinAmountWithCurrency = bitcoinAmountWithCurrency
        let amountString = readableAmount(from: bitcoinAmountWithCurrency, in: type).string
        self.text = "(\(amountString))"
    }
}

fileprivate extension Selector {
    static let amountTouched = #selector(AmountLabel.amountTouched)
}

private extension AmountLabel {
    func setTextAnimated(_ text: NSAttributedString, completion: (() -> Void)? = nil) {
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

    func nextValue(
        for bitcoinAmountWithSelectedCurrency: BitcoinAmountWithSelectedCurrency
    ) -> NSAttributedString {
        let currentValue = self.attributedText!.string
        let input = readableAmount(from: bitcoinAmountWithSelectedCurrency, in: .inInput)
        let primary = readableAmount(from: bitcoinAmountWithSelectedCurrency, in: .inPrimary)
        let btc = readableAmount(from: bitcoinAmountWithSelectedCurrency, in: .inBTC)

        // Cycle input → primary → BTC, but drop the primary value when its rate is unusable so we
        // fall back to BTC instead of showing a misleading "0.00 <ccy>".
        let bitcoinAmount = bitcoinAmountWithSelectedCurrency.bitcoinAmount
        let cycle = canShowPrimary(for: bitcoinAmount) ? [input, primary, btc] : [input, btc]

        // Advance to the next value that reads differently from the current one (wrapping around).
        let start = cycle.firstIndex { $0.string == currentValue } ?? 0
        for offset in 1...cycle.count {
            let candidate = cycle[(start + offset) % cycle.count]
            if candidate.string != currentValue {
                return candidate
            }
        }
        return cycle[start]
    }

    /// A primary currency with an unusable rate converts to 0 (a valid rate always yields a
    /// strictly positive amount), so we drop it from the cycle and fall back to BTC. A genuinely
    /// zero amount (no sats) keeps it, since there's nothing misleading to hide.
    func canShowPrimary(for bitcoinAmount: BitcoinAmount) -> Bool {
        return bitcoinAmount.inSatoshis == Satoshis(value: 0)
            || bitcoinAmount.inPrimaryCurrency.amount != 0
    }

    /// Become a value readable.
    /// bitcoin unit on formatting is inferred from selectedCurrency on bitcoinAmountWithCurrency.
    /// - Parameters:
    ///   - bitcoinAmountWithCurrency: Value to be parsed
    ///   - type: Desired output type
    /// - Returns: A formatted output (25 USD)
    func readableAmount(
        from bitcoinAmountWithCurrency: BitcoinAmountWithSelectedCurrency,
        in type: AmountLabelType
    ) -> NSAttributedString {
        let selectedCurrency = bitcoinAmountWithCurrency.selectedCurrency
        let contextBitcoinCurrency = getBitcoinCurrencyGiven(selectedCurrency: selectedCurrency)
        self.contextBitcoinCurrency = contextBitcoinCurrency

        let value = getValueToBecomeReadableIn(
            bitcoinAmount: bitcoinAmountWithCurrency.bitcoinAmount,
            type: type
        )
        return getFormattedStringFor(
            value: value,
            contextBitcoinCurrency: contextBitcoinCurrency
        )
    }

    /// Retrieves bitcoinCurrency.
    /// If user selection is already a bitcoinCurrency this method chooses
    /// user selection in order to keep bitcoin unit selected by user.
    func getBitcoinCurrencyGiven(selectedCurrency: Currency) -> BitcoinCurrency {
        guard let bitcoinCurrency = selectedCurrency as? BitcoinCurrency else {
            return GetBTCDefaultSelectedUnit.run()
        }
        return bitcoinCurrency
    }

    func getValueToBecomeReadableIn(
        bitcoinAmount: BitcoinAmount,
        type: AmountLabelType
    ) -> MonetaryAmount {
        switch type {
        case .inBTC:
            return bitcoinAmount.inSatoshis.toBTC()
        case .inInput:
            return bitcoinAmount.inInputCurrency
        case .inPrimary:
            return bitcoinAmount.inPrimaryCurrency
        }
    }

    func getFormattedStringFor(
        value: MonetaryAmount,
        contextBitcoinCurrency: Currency
    ) -> NSAttributedString {
        let currency: Currency

        if value.currency == "BTC" {
            currency = contextBitcoinCurrency
        } else {
            currency = GetCurrencyForCode().runAssumingCrashPosibility(code: value.currency)
        }

        var attributedString = NSMutableAttributedString()
        let amountString = currency.toAmountWithoutCode(
            amount: value.amount,
            btcCurrencyFormat: .long
        )
        attributedString = NSMutableAttributedString(
            string: "\(amountString) \(currency.displayCode)",
            attributes: [NSAttributedString.Key.font: font as Any]
        )
        return attributedString.set(tint: amountString, color: Asset.Colors.title.color)
    }
}
