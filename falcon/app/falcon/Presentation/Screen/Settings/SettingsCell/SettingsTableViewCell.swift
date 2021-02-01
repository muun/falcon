//
//  SettingsTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 21/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var topSeparatorHeight: NSLayoutConstraint!
    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet private weak var rightImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpView()
    }

    private func setUpView() {
        backgroundColor = Asset.Colors.cellBackground.color
        setUpSeparators()
        setUpLabel()
    }

    private func setUpSeparators() {
        topSeparator.backgroundColor = Asset.Colors.title.color.withAlphaComponent(0.12)
        bottomSeparator.backgroundColor = Asset.Colors.title.color.withAlphaComponent(0.12)
    }

    private func setUpLabel() {
        mainLabel.text = ""
        mainLabel.font = Constant.Fonts.description
        mainLabel.textColor = Asset.Colors.title.color
    }

    func setUp(_ text: String, color: UIColor) {
        mainLabel.text = text
        mainLabel.textColor = color
    }

    func showChevron() {
        rightImageView.isHidden = false
    }

    func hideTopSeparator() {
        topSeparator.isHidden = true
    }

}
