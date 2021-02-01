//
//  LoadingView.swift
//  falcon
//
//  Created by Manu Herrera on 30/10/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

class LoadingView: MUView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    public var titleText: String {
        get { return titleLabel.text ?? "" }
        set { titleLabel.text = newValue }
    }

    override func setUp() {
        backgroundColor = Asset.Colors.background.color
        setUpLabel()
        setUpActivityIndicator()
    }

    fileprivate func setUpLabel() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.description
    }

    fileprivate func setUpActivityIndicator() {
        activityIndicator.color = Asset.Colors.muunBlue.color
        activityIndicator.startAnimating()
    }

    override func addTo(_ view: UIView) {
        self.alpha = 0

        super.addTo(view)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
