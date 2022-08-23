//
//  TargetedFeeTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 21/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class TargetedFeeTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var cardView: UIView!
    @IBOutlet fileprivate weak var timeLabel: UILabel!
    @IBOutlet fileprivate weak var targetLabel: UILabel!
    @IBOutlet fileprivate weak var bitcoinValueLabel: AmountLabel!
    @IBOutlet fileprivate weak var inputValueLabel: AmountLabel!

    private var isValid = true

    override func awakeFromNib() {
        super.awakeFromNib()

        setUp()
    }

    fileprivate func setUp() {
        setUpCardView()
        setUpLabels()
    }

    fileprivate func setUpCardView() {
        cardView.layer.cornerRadius = 4
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = Asset.Colors.cardViewBorder.color.cgColor
        cardView.backgroundColor = Asset.Colors.background.color
    }

    fileprivate func setUpLabels() {
        timeLabel.textColor = Asset.Colors.title.color
        timeLabel.font = Constant.Fonts.description
        targetLabel.textColor = Asset.Colors.muunGrayDark.color
        targetLabel.font = Constant.Fonts.system(size: .helper)
        bitcoinValueLabel.textColor = Asset.Colors.title.color
        bitcoinValueLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        inputValueLabel.textColor = Asset.Colors.muunGrayDark.color
        inputValueLabel.font = Constant.Fonts.system(size: .helper)
    }

    func setUp(fee: FeeState, confirmationTime: String, currencyToShow: Currency) {
        var feeAmount: BitcoinAmount
        let feeRate: FeeRate

        switch fee {
        case .feeNeedsChange(let amount, let rate):
            feeAmount = amount
            feeRate = rate
            isValid = false

        case .finalFee(let amount, let rate):
            feeAmount = amount
            feeRate = rate
            isValid = true

        case .noPossibleFee:
            Logger.fatal("Invalid fee state")
        }

        let text = L10n.TargetedFeeTableViewCell.s1(confirmationTime)
        timeLabel.attributedText = text
            .set(font: timeLabel.font)
            .set(bold: confirmationTime, color: Asset.Colors.title.color)

        targetLabel.text = "\(feeRate.stringValue()) sat/vbyte"

        bitcoinValueLabel.setAmount(from: BitcoinAmountWithSelectedCurrency(bitcoinAmount: feeAmount,
                                                                            selectedCurrency: currencyToShow),
                                    in: .inBTC)
        if feeAmount.inInputCurrency.currency != "BTC" {
            inputValueLabel.setHelperText(for: BitcoinAmountWithSelectedCurrency(bitcoinAmount: feeAmount,
                                                                                 selectedCurrency: currencyToShow),
                                          in: .inInput)
        } else {
            inputValueLabel.isHidden = true
        }

        if !isValid {
            isUserInteractionEnabled = false
            inputValueLabel.textColor = Asset.Colors.muunDisabled.color
            bitcoinValueLabel.textColor = Asset.Colors.muunDisabled.color
            targetLabel.textColor = Asset.Colors.muunDisabled.color
            timeLabel.textColor = Asset.Colors.muunDisabled.color
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            if !isValid {
                return
            }
            UIView.animate(withDuration: 0.25) {
                self.cardView.backgroundColor = Asset.Colors.muunBlue.color.withAlphaComponent(0.1)
                self.cardView.layer.borderColor = Asset.Colors.muunBlue.color.cgColor
            }
        } else {
            cardView.layer.borderColor = Asset.Colors.cardViewBorder.color.cgColor
            cardView.backgroundColor = Asset.Colors.background.color
        }
    }

    override func prepareForReuse() {
        timeLabel.text = nil
        targetLabel.text = nil
        bitcoinValueLabel.text = nil
        inputValueLabel.text = nil
        inputValueLabel.isHidden = false
    }

}
