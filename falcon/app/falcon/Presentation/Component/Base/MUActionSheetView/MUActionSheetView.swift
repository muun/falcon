//
//  MUActionSheetView.swift
//  falcon
//
//  Created by Federico Bond on 12/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import core

protocol MUActionSheetViewDelegate: AnyObject {
    func didSelect(option: any MUActionSheetOption)
}

protocol MUActionSheetOption: RawRepresentable<String> {
    var name: String { get }
    var description: NSAttributedString { get }
}

/**
 In order to use this view you will have to init it with the delegate in which you will receive the selected item,
 the header title for customization and the options that will be displayed to the user.
 The option will ask you for a hightlight and a blockHeight. Do not worry about this two things unless you need it.
 If you need it feel free to get how this two parameters work and then complete this doc :)
 MUActionSheetOptionViewModel is a model to retrieve your MUActionSheetOption in a way the action sheet is able
 to understand. Do not use it for anything  else.
 */
class MUActionSheetView: MUBottomSheetViewContainer {
    private weak var delegate: MUActionSheetViewDelegate?
    private let headerTitle: String
    private let viewOptions: [MUActionSheetOptionViewModel]

    init(delegate: MUActionSheetViewDelegate,
         headerTitle: String,
         screenNameForLogs: String,
         viewOptions: [MUActionSheetOptionViewModel]) {
        self.delegate = delegate
        self.headerTitle = headerTitle
        self.viewOptions = viewOptions

        super.init(screenNameForLogs: screenNameForLogs)
    }

    required init(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func setUpView() {
        super.setUpView()

        addTitleLabel(to: dialogView)
        addSelectableOptions(to: dialogView)
    }
}

extension MUActionSheetView: MUActionSheetCardDelegate {
    func tapped(actionSheetCard: MUActionSheetCard) {
        delegate?.didSelect(option: actionSheetCard.selectedOptionType)
        dismiss(animated: true)
    }
}

private extension MUActionSheetView {
    func addTitleLabel(to dialogView: UIStackView) {
        let titleLabel = UILabel()
        titleLabel.text = headerTitle
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.textAlignment = .natural
        titleLabel.textColor = Asset.Colors.black.color
        dialogView.addArrangedSubview(titleLabel)
        dialogView.setCustomSpacing(.headerSpacing, after: titleLabel)
    }

    func addSelectableOptions(to dialogView: UIStackView) {
        for viewOption in viewOptions {
            dialogView.addArrangedSubview(MUActionSheetCard(
                selectedOptionType: viewOption.type,
                status: viewOption.status,
                delegate: self,
                highlight: viewOption.highlight
            ))
        }
    }
}
