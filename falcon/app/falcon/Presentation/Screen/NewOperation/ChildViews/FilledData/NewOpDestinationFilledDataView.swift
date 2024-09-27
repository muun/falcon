//
//  NewOpDestinationFilledDataView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

protocol NewOpDestinationViewDelegate: AnyObject {
    func showMoreInfo(info: MoreInfo)
}

@IBDesignable
class NewOpDestinationFilledDataView: MUView {

    @IBOutlet fileprivate weak var toLabel: UILabel!
    @IBOutlet fileprivate weak var detailLabel: UILabel!
    @IBOutlet fileprivate weak var moreInfoButton: UIButton!
    @IBOutlet fileprivate weak var separator: UIView!
    @IBOutlet fileprivate weak var topSeparator: UIView!

    fileprivate weak var delegate: NewOpDestinationViewDelegate?
    private let type: PaymentRequestType
    private let confirm: Bool
    private let moreInfo: MoreInfo

    init(type: PaymentRequestType,
         delegate: NewOpDestinationViewDelegate?,
         confirm: Bool,
         moreInfo: MoreInfo) {
        self.type = type
        self.delegate = delegate
        self.confirm = confirm
        self.moreInfo = moreInfo

        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    override func setUp() {
        setUpLabels()
        setUpButton()
        setUpSeparators()
        heightAnchor.constraint(equalToConstant: 56).isActive = true

        makeViewTestable()
    }

    fileprivate func setUpLabels() {
        toLabel.text = L10n.NewOpDestinationFilledDataView.s1
        if confirm {
            toLabel.textColor = Asset.Colors.title.color
            toLabel.font = Constant.Fonts.system(size: .desc, weight: .semibold)
        } else {
            toLabel.style = .description
        }

        detailLabel.style = .description
        detailLabel.text = type.destination()
    }

    fileprivate func setUpButton() {
        moreInfoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .buttonTapped))
        detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .buttonTapped))
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: .buttonTapped))
    }

    fileprivate func setUpSeparators() {
        separator.backgroundColor = Asset.Colors.separator.color
        topSeparator.backgroundColor = Asset.Colors.separator.color
    }

    @objc func buttonTapped() {
        delegate?.showMoreInfo(info: moreInfo)
    }
}

fileprivate extension Selector {

    static let buttonTapped = #selector(NewOpDestinationFilledDataView.buttonTapped)

}

extension NewOpDestinationFilledDataView: UITestablePage {
    typealias UIElementType = UIElements.Pages.NewOp

    func makeViewTestable() {
        makeViewTestable(detailLabel, using: .destinationFilledData)
    }
}
