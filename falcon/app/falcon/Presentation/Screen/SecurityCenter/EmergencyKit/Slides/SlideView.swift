//
//  EmergencyKitSlide.swift
//  falcon
//
//  Created by Manu Herrera on 16/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class SlideView: MUView {

    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!

    override func setUp() {
        setUpLabels()
    }

    func setUp(image: UIImage?, title: String, description: NSAttributedString) {
        imageView.image = image
        titleLabel.text = title
        descriptionLabel.attributedText = description
    }

    private func setUpLabels() {
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)

        descriptionLabel.style = .description
    }

}
