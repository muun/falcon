//
//  AmountOptionView.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import core

protocol AmountOptionViewDelegate: AnyObject {
    func didTapAddAmount()
}

class AmountOptionView: UIStackView {

    private let label = UILabel()
    private let editButton = UIView()
    private let value = AmountLabel()
    private let addButton = LightButtonView()

    weak var delegate: AmountOptionViewDelegate?

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views Layout and configuration -

    func setUpView() {
        distribution = .equalSpacing
        axis = .horizontal
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: .verticalRowMargin,
                                     left: 8,
                                     bottom: .verticalRowMargin,
                                     right: 8)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56)
        ])

        setUpLabelView()
        setUpEditButton()
        setUpAddButton()
        setUpValueLabel()
    }

    func setUpLabelView() {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = L10n.AmountOptionView.label
        label.font = Constant.Fonts.system(size: .desc)
        addArrangedSubview(label)
    }

    func setUpEditButton() {
        editButton.isUserInteractionEnabled = true
        editButton.contentMode = .center
        editButton.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                               action: .didTapEditButton))
        editButton.isHidden = true

        let editButtonIcon = UIImageView()
        editButtonIcon.image = Asset.Assets.editPencilAlt.image
        editButtonIcon.translatesAutoresizingMaskIntoConstraints = false
        editButton.addSubview(editButtonIcon)

        editButton.preservesSuperviewLayoutMargins = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(editButton)

        NSLayoutConstraint.activate([
            editButton.widthAnchor.constraint(equalToConstant: 40),
            editButton.heightAnchor.constraint(equalTo: heightAnchor),
            editButton.leadingAnchor.constraint(equalTo: label.trailingAnchor),
            editButtonIcon.widthAnchor.constraint(equalToConstant: 20),
            editButtonIcon.heightAnchor.constraint(equalTo: editButtonIcon.widthAnchor),
            editButtonIcon.centerXAnchor.constraint(equalTo: editButton.centerXAnchor),
            editButtonIcon.centerYAnchor.constraint(equalTo: editButton.centerYAnchor)
        ])
    }

    func setUpAddButton() {
        addButton.buttonText = L10n.AmountOptionView.addButton
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.delegate = self
        addArrangedSubview(addButton)

        NSLayoutConstraint.activate([
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    func setUpValueLabel() {
        value.translatesAutoresizingMaskIntoConstraints = false
        value.isHidden = true
        value.textColor = Asset.Colors.muunGrayDark.color
        value.font = Constant.Fonts.system(size: .desc)
        value.textAlignment = .right
        value.shouldCycle = true
        value.delegate = self
        value.setContentHuggingPriority(UILayoutPriority(50.0), for: .horizontal)
        addArrangedSubview(value)
    }

    // MARK: - View Controller Actions -

    func setAmount(_ bitcoinAmount: BitcoinAmountWithSelectedCurrency?) {

        if let bitcoinAmount = bitcoinAmount {
            addButton.isHidden = true
            value.setAmount(from: bitcoinAmount, in: .inInput)
            value.isHidden = false
            editButton.isHidden = false
        } else {
            addButton.isHidden = false
            value.isHidden = true
            editButton.isHidden = true
        }
    }

    // MARK: - View Controller Actions -

    @objc func didTapEditButton() {
        delegate?.didTapAddAmount()
    }

}

extension AmountOptionView: LightButtonViewDelegate {

    func lightButton(didPress button: LightButtonView) {
        delegate?.didTapAddAmount()
    }

}

extension AmountOptionView: AmountLabelDelegate {

    func didTouchBitcoinLabel() {
        value.cycleCurrency()
    }

}

fileprivate extension Selector {

    static let didTapEditButton = #selector(AmountOptionView.didTapEditButton)

}
