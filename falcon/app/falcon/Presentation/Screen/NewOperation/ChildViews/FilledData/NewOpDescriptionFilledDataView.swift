//
//  NewOpDescriptionFilledDataView.swift
//  falcon
//
//  Created by Manu Herrera on 22/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

@IBDesignable
class NewOpDescriptionFilledDataView: MUView {

    @IBOutlet fileprivate weak var noteLabel: UILabel!
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    let descriptionText: String

    init(descriptionText: String) {
        self.descriptionText = descriptionText

        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func setUp() {
        setUpLabels()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        noteLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        noteLabel.textColor = Asset.Colors.title.color
        noteLabel.text = L10n.NewOpDescriptionFilledDataView.s1

        descriptionLabel.style = .description
        descriptionLabel.text = descriptionText
    }

}

extension NewOpDescriptionFilledDataView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp

    func makeViewTestable() {
        makeViewTestable(descriptionLabel, using: .descriptionFilledData)
    }
}
