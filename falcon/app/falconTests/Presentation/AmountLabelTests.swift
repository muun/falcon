//
//  AmountLabelTests.swift
//  falconTests
//
//  Created by Manu Herrera on 26/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import XCTest

@testable import Muun

class AmountLabelTests: MuunTestCase {

    let amountLabel: AmountLabel = AmountLabel()
    lazy var sats = Satoshis(value: 10_000)
    lazy var btc = BitcoinAmount(inSatoshis: sats, inInputCurrency: sats.toBTC(), inPrimaryCurrency: sats.toBTC())
    lazy var btcValue = BitcoinAmountWithSelectedCurrency(bitcoinAmount: btc, selectedCurrency: BitcoinCurrency(unit: .BTC))
    lazy var SatToUsd = BitcoinAmount(inSatoshis: sats, inInputCurrency: MonetaryAmount(amount: 0.00010000, currency: "BTC"),
                                      inPrimaryCurrency: usdAmount)
    lazy var satValue = BitcoinAmountWithSelectedCurrency(bitcoinAmount: SatToUsd, selectedCurrency: BitcoinCurrency(unit: .SAT))

    lazy var usdValue = BitcoinAmountWithSelectedCurrency(bitcoinAmount: usd, selectedCurrency: CurrencyHelper.allCurrencies["USD"]!)
    lazy var usdAmount = MonetaryAmount(amount: 100, currency: "USD")
    lazy var usd = BitcoinAmount(inSatoshis: sats, inInputCurrency: usdAmount, inPrimaryCurrency: sats.toBTC())
    lazy var arsValue = BitcoinAmountWithSelectedCurrency(bitcoinAmount: ars, selectedCurrency: CurrencyHelper.allCurrencies["ARS"]!)
    lazy var arsAmount = MonetaryAmount(amount: 4500, currency: "ARS")
    lazy var ars = BitcoinAmount(inSatoshis: sats, inInputCurrency: arsAmount, inPrimaryCurrency: usdAmount)

    func testAllBitcoin() {
        amountLabel.setAmount(from: btcValue, in: .inBTC)
        XCTAssertEqual(amountLabel.attributedText?.string, "0.00010000 BTC")
        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "0.00010000 BTC")
    }

    func testBTCToUSD() {
        amountLabel.setAmount(from: usdValue, in: .inInput)
        XCTAssertEqual(amountLabel.attributedText?.string, "100.00 USD")

        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "0.00010000 BTC")
        
        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "100.00 USD")
    }

    func testARSToUSDToBTC() {
        amountLabel.setAmount(from: arsValue, in: .inInput)
        XCTAssertEqual(amountLabel.attributedText?.string, "4,500.00 ARS")

        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "100.00 USD")

        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "0.00010000 BTC")

        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "4,500.00 ARS")
    }
    
    func testSATToUSDToSatFollowingSelectedCurrency() {
        amountLabel.setAmount(from: satValue, in: .inInput)
        XCTAssertEqual(amountLabel.attributedText?.string, "10,000 SAT")

        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "100.00 USD")

        amountLabel.cycleCurrency(animated: false)
        XCTAssertEqual(amountLabel.attributedText?.string, "10,000 SAT")
    }
}
