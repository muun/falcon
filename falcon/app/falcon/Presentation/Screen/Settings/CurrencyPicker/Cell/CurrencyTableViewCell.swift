//
//  CurrencyTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 21/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet private weak var currencyNameLabel: UILabel!
    @IBOutlet private weak var tickImageView: UIImageView!
    @IBOutlet private weak var flagImageView: UIImageView!
    @IBOutlet private weak var currencyNameLeftConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpView()
    }

    fileprivate func setUpView() {
        setUpLabel()
        backgroundColor = Asset.Colors.cellBackground.color
    }

    fileprivate func setUpLabel() {
        currencyNameLabel.style = .description
    }

    func setUp(_ currency: Currency, isSelected: Bool) {
        tickImageView.image = nil
        flagImageView.isHidden = true
        currencyNameLeftConstraint.constant = 24

        if isSelected {
            currencyNameLabel.textColor = Asset.Colors.muunBlue.color
            tickImageView.image = Asset.Assets.tick.image
        }

        let displayCode = currency.displayCode
        // Workaround needed to display Satoshi(SAT) as Bitcoin(BTC). This is required because I was not able to change
        // name in BitcoinCurrency for sats because name is being use to identify bitcoin from satoshis in some places.
        let currencyNameForDisplay = (currency == BitcoinCurrency(unit: .SAT) ? BitcoinCurrency(unit: .BTC).name
        : currency.name) + " (\(displayCode))"
        if let flag = currency.flag {
            currencyNameLabel.text = "\(flag) \(currencyNameForDisplay)"
        } else {
            currencyNameLabel.text = "\(currencyNameForDisplay)"
            currencyNameLeftConstraint.constant = 50
            flagImageView.isHidden = false
            if currency.code == "BTC" || currency.code == satSymbol {
                flagImageView.image = Asset.Assets.btcLogo.image
            } else {
                flagImageView.image = Asset.Assets.defaultFlag.image
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        currencyNameLabel.text = ""
        currencyNameLabel.style = .description
        tickImageView.image = nil
        flagImageView.image = nil
        currencyNameLeftConstraint.constant = 24
    }

}
