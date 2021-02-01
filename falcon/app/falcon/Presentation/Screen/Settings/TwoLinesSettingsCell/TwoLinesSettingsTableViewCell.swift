//
//  TwoLinesSettingsTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 21/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class TwoLinesSettingsTableViewCell: UITableViewCell {

    @IBOutlet private weak var topSeparator: UIView!
    @IBOutlet private weak var topSeparatorHeight: NSLayoutConstraint!
    @IBOutlet private weak var mainLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var bottomSeparator: UIView!
    @IBOutlet private weak var bottomSeparatorHeight: NSLayoutConstraint!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var bottomImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpView()
    }

    private func setUpView() {
        backgroundColor = Asset.Colors.cellBackground.color
        setUpActivityIndicator()
        setUpSeparators()
        setUpLabels()
    }

    private func setUpActivityIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        activityIndicator.color = Asset.Colors.muunBlue.color
    }

    private func setUpSeparators() {
        topSeparator.backgroundColor = Asset.Colors.title.color.withAlphaComponent(0.12)
        bottomSeparator.backgroundColor = Asset.Colors.title.color.withAlphaComponent(0.12)
    }

    private func setUpLabels() {
        mainLabel.text = ""
        mainLabel.font = Constant.Fonts.description
        mainLabel.textColor = Asset.Colors.title.color

        secondLabel.text = ""
        secondLabel.font = Constant.Fonts.description
        secondLabel.textColor = Asset.Colors.muunGrayDark.color
    }

    func setUp(mainLabel: String, secondLabel: String, image: UIImage? = nil) {
        self.mainLabel.text = mainLabel
        self.secondLabel.text = secondLabel
        bottomImageView.isHidden = (image == nil)
        bottomImageView.image = image
    }

    func setLoading(_ isLoading: Bool) {
        activityIndicator.isHidden = !isLoading
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    func hideTopSeparator() {
        topSeparator.isHidden = true
    }

    func showChevron() {
        rightImageView.isHidden = false
    }

}
