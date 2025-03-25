//
//  EnterFeeManuallyTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 23/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit


class EnterFeeManuallyTableViewCell: UITableViewCell {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var feeLabel: AmountLabel!
    @IBOutlet fileprivate var feeLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var cardView: UIView!

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
        cardView.layer.borderColor = Asset.Colors.muunBlue.color.cgColor
        cardView.backgroundColor = Asset.Colors.background.color
    }

    fileprivate func setUpLabels() {
        titleLabel.textColor = Asset.Colors.muunBlue.color
        titleLabel.font = Constant.Fonts.system(size: .helper, weight: .semibold)
        feeLabel.textColor = Asset.Colors.muunGrayDark.color
        feeLabel.font = Constant.Fonts.system(size: .helper)
    }

    func setUp(fee: BitcoinAmountWithSelectedCurrency?) {
        if let fee = fee {
            titleLabel.text = L10n.EnterFeeManuallyTableViewCell.s1
            feeLabel.setAmount(from: fee, in: .inBTC)
            feeLabelBottomConstraint.isActive = true
            feeLabel.isHidden = false
        } else {
            titleLabel.text = L10n.EnterFeeManuallyTableViewCell.s2
            feeLabel.isHidden = true
            feeLabelBottomConstraint.isActive = false
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            UIView.animate(withDuration: 0.25) {
                self.cardView.backgroundColor = Asset.Colors.muunBlue.color.withAlphaComponent(0.1)
            }
        } else {
            cardView.backgroundColor = Asset.Colors.background.color
        }
    }

}
