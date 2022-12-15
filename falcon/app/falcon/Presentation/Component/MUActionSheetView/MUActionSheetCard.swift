//
//  selectedOptionTypeView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 22/10/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import UIKit
import core

struct MUActionSheetOptionViewModel {
    let type: any MUActionSheetOption
    let status: MUActionSheetCard.Status
    let highlight: String?
    let blocksLeft: UInt

    init(type: any MUActionSheetOption, status: MUActionSheetCard.Status, highlight: String?, blocksLeft: UInt = 0) {
        self.type = type
        self.blocksLeft = blocksLeft
        self.status = status
        self.highlight = highlight
    }
}

protocol MUActionSheetCardDelegate: AnyObject {
    func tapped(actionSheetCard: MUActionSheetCard)
}

class MUActionSheetCard: UIStackView {

    enum Status {
        case selected,
             enabled,
             disabled
    }

    let selectedOptionType: any MUActionSheetOption
    private weak var delegate: MUActionSheetCardDelegate?
    let status: Status

    init(selectedOptionType: any MUActionSheetOption,
         status: Status,
         delegate: MUActionSheetCardDelegate?,
         highlight: String?
    ) {
        self.selectedOptionType = selectedOptionType
        self.delegate = delegate
        self.status = status
        super.init(frame: CGRect.zero)
        setupView(highlight: highlight)
    }

    required init(coder: NSCoder) {
        preconditionFailure()
    }

    private func setupView(highlight: String?) {
        let borderColor: ColorAsset
        let titleColor: ColorAsset
        let backgroundColor: ColorAsset?

        switch status {
        case .selected:
            borderColor = Asset.Colors.muunBlue
            titleColor = Asset.Colors.title
            backgroundColor = Asset.Colors.muunBluePale
        case .enabled:
            borderColor = Asset.Colors.cardViewBorder
            titleColor = Asset.Colors.title
            backgroundColor = nil
        case .disabled:
            borderColor = Asset.Colors.cardViewBorder
            titleColor = Asset.Colors.muunDisabled
            backgroundColor = nil
        }

        translatesAutoresizingMaskIntoConstraints = false

        roundCorners(cornerRadius: 4, clipsToBounds: true)
        layer.borderWidth = 1
        layer.borderColor = borderColor.color.cgColor
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor.color
        }

        axis = .vertical
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .standardMargins
        alignment = .leading
        spacing = .closeSpacing
        distribution = .fillProportionally

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = selectedOptionType.name
        titleLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        titleLabel.textColor = titleColor.color
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        addArrangedSubview(titleLabel)

        let descriptionFont = Constant.Fonts.system(size: .helper)
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = descriptionFont
        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        if let highlight = highlight {
            descriptionLabel.attributedText = "\(highlight) \(selectedOptionType.description)"
                .set(font: descriptionFont)
                .set(bold: highlight, weight: .medium)
        } else {
            descriptionLabel.attributedText = selectedOptionType.description
        }

        descriptionLabel.numberOfLines = 0
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addArrangedSubview(descriptionLabel)

        // Always make it tappable so it intercepts touch events and the whole dialog isn't dismissed when tapping
        // a disabled card
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(sender:))))
    }

    @objc private func tapped(sender: UIView) {
        if status != .disabled {
            delegate?.tapped(actionSheetCard: self)
        }
    }
}
