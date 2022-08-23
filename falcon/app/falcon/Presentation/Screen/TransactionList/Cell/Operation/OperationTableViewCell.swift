//
//  OperationTableViewCell.swift
//  falcon
//
//  Created by Manu Herrera on 05/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

class OperationTableViewCell: UITableViewCell {

    @IBOutlet private weak var operationTitleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var currencyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        setUpView()
        makeViewTestable()
    }

    fileprivate func setUpView() {
        backgroundColor = Asset.Colors.cellBackground.color

        setUpLabels()
    }

    fileprivate func setUpLabels() {
        operationTitleLabel.textColor = Asset.Colors.title.color
        operationTitleLabel.font = Constant.Fonts.system(size: .opTitle)

        descriptionLabel.textColor = Asset.Colors.muunGrayDark.color
        descriptionLabel.font = Constant.Fonts.system(size: .opDesc)

        amountLabel.textColor = Asset.Colors.muunGreen.color
        amountLabel.font = Constant.Fonts.system(size: .opTitle, weight: .semibold)

        currencyLabel.textColor = Asset.Colors.muunGreen.color
        currencyLabel.font = Constant.Fonts.system(size: .opHelper, weight: .semibold)

        dateLabel.textColor = Asset.Colors.muunGrayDark.color
        dateLabel.font = Constant.Fonts.system(size: .opHelper)
    }

    func setUp(_ operation: core.Operation) {
        setUpLabels()

        let formatter = OperationFormatter(operation: operation)

        operationTitleLabel.text = formatter.title
        setDescriptionText(formatter: formatter)
        setAmountText(operation: operation)
        dateLabel.text = formatter.shortCreationDate
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // using space instead of empty strings so it preserves height
        amountLabel.text = " "
        operationTitleLabel.text = " "
        dateLabel.text = " "
        descriptionLabel.text = " "
    }

    private func setDescriptionText(formatter: OperationFormatter) {
        let boldText = formatter.shortStatus
        let separator = boldText.isEmpty ? "" : ": "
        var description = L10n.OperationTableViewCell.s1
        if let customDesc = formatter.description, !customDesc.isEmpty {
            description = customDesc
        } else if formatter.operation.incomingSwap != nil {
            description = L10n.OperationTableViewCell.s2
        }

        let finalDescriptionText = "\(boldText)\(separator)\(description)"

        descriptionLabel.attributedText = finalDescriptionText
            .set(font: descriptionLabel.font)
            .set(bold: boldText, color: formatter.color)
        descriptionLabel.lineBreakMode = .byTruncatingTail
    }

    private func setAmountText(operation: core.Operation) {
        let amount = operation.amount.inInputCurrency
        let amountString = amount.toAmountWithoutCode(btcCurrencyFormat: .short)
        amountLabel.text = amountString
        currencyLabel.text = CurrencyHelper.string(for: operation.amount.inInputCurrency.currency)

        switch operation.direction {
        case .OUTGOING:
            amountLabel.text = "-\(amountString)"

            amountLabel.textColor = Asset.Colors.operationOutgoing.color
            currencyLabel.textColor = Asset.Colors.operationOutgoing.color
        case .INCOMING:
            amountLabel.textColor = Asset.Colors.muunGreen.color
            currencyLabel.textColor = Asset.Colors.muunGreen.color
        case .CYCLICAL:
            // Cyclical payments use the same color as Outgoings but with no minus sign (-)
            amountLabel.textColor = Asset.Colors.operationOutgoing.color
            currencyLabel.textColor = Asset.Colors.operationOutgoing.color
        }
    }

}

extension OperationTableViewCell: UITestablePage {

    typealias UIElementType = UIElements.Cells.OperationCellPage

    func makeViewTestable() {
        self.makeViewTestable(self, using: .root)
    }

}
