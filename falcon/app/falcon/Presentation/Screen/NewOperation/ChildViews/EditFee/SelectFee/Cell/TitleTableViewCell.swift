//
//  TitleTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 21/06/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

protocol TitleTableViewCellDelegate: class {
    func didTouchTitle()
}

class TitleTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    private weak var delegate: TitleTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpLabel()
    }

    fileprivate func setUpLabel() {
        titleLabel.style = .description
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .titleLabelTouched))
    }

    func setUp(text: String, delegate: TitleTableViewCellDelegate? = nil) {
        titleLabel.attributedText = text.set(font: titleLabel.font)
            .set(underline: L10n.TitleTableViewCell.s1, color: Asset.Colors.muunBlue.color)
        self.delegate = delegate
    }

    @objc fileprivate func titleLabelTouched() {
        delegate?.didTouchTitle()
    }

}

fileprivate extension Selector {
    static let titleLabelTouched = #selector(TitleTableViewCell.titleLabelTouched)
}
