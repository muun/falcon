//
//  NewOpAmountFilledDataView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

struct Notice {
    let notice: String
    let bold: String?
    let boldColor: UIColor?
}

struct NewOpFilledAmount {

    enum AmountType {
        case amount
        case onchainFee
        case lightningFee
        case total
    }

    let type: AmountType
    let amount: BitcoinAmount

    let notice: Notice?
    let moreInfo: MoreInfo?

    init(type: AmountType, amount: BitcoinAmount, notice: Notice? = nil, moreInfo: MoreInfo? = nil) {
        self.type = type
        self.amount = amount
        self.notice = notice
        self.moreInfo = moreInfo
    }
}

protocol NewOpFilledAmountDelegate: class {
    func didPressAmount()
    func didPressMoreInfo(info: MoreInfo)
}

protocol NewOpFilledAmountTransitions: class {
    func requestFeeEditor()
}

@IBDesignable
class NewOpAmountFilledDataView: MUView {

    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var amountLabel: AmountLabel!
    @IBOutlet fileprivate weak var separator: UIView!
    @IBOutlet fileprivate weak var noticeLabel: UILabel!
    @IBOutlet fileprivate weak var editFeeButton: UIButton!
    @IBOutlet fileprivate weak var showMoreInfoButton: UIButton!

    private weak var delegate: NewOpFilledAmountDelegate?
    private weak var transitionsDelegate: NewOpFilledAmountTransitions?

    let filledData: NewOpFilledAmount

    init(filledData: NewOpFilledAmount,
         delegate: NewOpFilledAmountDelegate?,
         transitionsDelegate: NewOpFilledAmountTransitions? = nil) {
        self.filledData = filledData
        self.delegate = delegate
        self.transitionsDelegate = transitionsDelegate

        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func setUp() {
        setUpLabels()
        setUpButtons()
        setUpSeparator()

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        let (title, bold) = getTitle()

        titleLabel.text = title
        if bold {
            titleLabel.textColor = Asset.Colors.title.color
            titleLabel.font = Constant.Fonts.system(size: .desc, weight: .bold)
        } else {
            titleLabel.textColor = Asset.Colors.muunGrayDark.color
            titleLabel.font = Constant.Fonts.description
        }

        amountLabel.font = Constant.Fonts.monospacedDigitSystemFont(size: .desc)
        amountLabel.textColor = Asset.Colors.muunGrayDark.color
        amountLabel.shouldCycle = true
        amountLabel.delegate = self
        amountLabel.setAmount(from: filledData.amount, in: .inInput)

        noticeLabel.textColor = Asset.Colors.muunGrayDark.color
        noticeLabel.font = Constant.Fonts.system(size: .notice)

        if let notice = filledData.notice {
            noticeLabel.isHidden = false
            noticeLabel.text = notice.notice
            var attrString = notice.notice.set(font: noticeLabel.font)
            if let bold = notice.bold, let color = notice.boldColor {
                attrString = attrString.set(bold: bold, color: color)
            }
            noticeLabel.attributedText = attrString
        } else {
            noticeLabel.isHidden = true
            noticeLabel.removeFromSuperview()
        }
    }

    func cycleCurrency() {
        amountLabel.cycleCurrency()
    }

    private func setUpButtons() {
        editFeeButton.isHidden = .onchainFee != filledData.type

        if filledData.moreInfo != nil {
            showMoreInfoButton.isHidden = false
        }
    }

    private func getTitle() -> (title: String, bold: Bool) {
        var bold = false
        let title: String
        switch filledData.type {
        case .amount:
            title = L10n.NewOpAmountFilledDataView.s1
        case .onchainFee, .lightningFee:
            title = L10n.NewOpAmountFilledDataView.s2
        case .total:
            title = L10n.NewOpAmountFilledDataView.s3
            bold = true
        }
        return (title, bold)
    }

    private func setUpSeparator() {
        separator.isHidden = true
        separator.backgroundColor = Asset.Colors.separator.color
    }

    func showSeparator() {
        separator.isHidden = false
    }

    func hideSeparator() {
        separator.isHidden = true
    }

    func setAmountColor(_ color: UIColor) {
        amountLabel.textColor = color
    }

    @IBAction fileprivate func showMoreInfoTouched(_ sender: Any) {
        guard let info = filledData.moreInfo else {
            return
        }
        delegate?.didPressMoreInfo(info: info)
    }

    @IBAction fileprivate func editFeeTouched(_ sender: Any) {
        transitionsDelegate?.requestFeeEditor()
    }
}

extension NewOpAmountFilledDataView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp

    func makeViewTestable() {
        switch filledData.type {
        case .amount:
            makeViewTestable(self.amountLabel, using: .amountFilledData)
        case .onchainFee:
            makeViewTestable(self.amountLabel, using: .feeFilledData)
        case .lightningFee:
            makeViewTestable(self.amountLabel, using: .feeFilledData)
        default:
            ()
        }
        makeViewTestable(self.editFeeButton, using: .feeView)
    }
}

extension NewOpAmountFilledDataView: AmountLabelDelegate {
    func didTouchBitcoinLabel() {
        delegate?.didPressAmount()
    }
}
