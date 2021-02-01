//
//  TitleAndDescriptionTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 14/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

class TitleAndDescriptionTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleAndDescriptionView: TitleAndDescriptionView!

    func setUp(title: String, description: String?, delegate: TitleAndDescriptionViewDelegate? = nil) {
        titleAndDescriptionView.titleText = title
        titleAndDescriptionView.descriptionText = description?.attributedForDescription()
        titleAndDescriptionView.delegate = delegate

        titleAndDescriptionView.makeVisible()
    }

}
