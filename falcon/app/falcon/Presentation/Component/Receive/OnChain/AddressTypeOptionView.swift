//
//  AddressTypeOptionView.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

protocol AddressTypeOptionViewDelegate: class {
    func didTapHelp()
    func didTapControl()
}

class AddressTypeOptionView: UIStackView {

    private let label = UILabel()
    private let controlView = UIStackView()
    private let controlLabel = UILabel()

    weak var delegate: AddressTypeOptionViewDelegate?

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views Layout and configuration -

    private func setUpView() {
        distribution = .equalSpacing
        axis = .horizontal
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: .verticalRowMargin, left: .sideMargin, bottom: .verticalRowMargin, right: .sideMargin)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56)
        ])

        setUpLabelView()
        setUpControlView()
    }

    private func setUpLabelView() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10

        label.text = L10n.AddressTypeOptionView.label
        label.font = Constant.Fonts.system(size: .desc)
        stackView.addArrangedSubview(label)

        let helpImage = UIImageView()
        helpImage.image = Asset.Assets.help.image
        helpImage.isUserInteractionEnabled = true
        helpImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapHelp))
        stackView.addArrangedSubview(helpImage)

        addArrangedSubview(stackView)
    }

    private func setUpControlView() {
        controlView.axis = .horizontal
        controlView.distribution = .equalCentering
        controlView.alignment = .center
        controlView.isUserInteractionEnabled = true
        controlView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapControl))

        controlLabel.font = Constant.Fonts.system(size: .desc)
        controlLabel.textColor = Asset.Colors.muunGrayDark.color
        controlLabel.translatesAutoresizingMaskIntoConstraints = false
        controlView.addArrangedSubview(controlLabel)

        let chevron = UIImageView()
        chevron.image = Asset.Assets.chevronAlt.image
        chevron.translatesAutoresizingMaskIntoConstraints = false
        controlView.addArrangedSubview(chevron)

        controlView.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(controlView)
    }

    // MARK: - View Controller Actions -

    func setValue(_ addressType: AddressType) {
        controlLabel.text = addressType.description
    }

    // MARK: - UI Handlers -

    @objc func didTapHelp() {
        delegate?.didTapHelp()
    }

    @objc func didTapControl() {
        delegate?.didTapControl()
    }

}

fileprivate extension Selector {

    static let didTapHelp = #selector(AddressTypeOptionView.didTapHelp)
    static let didTapControl = #selector(AddressTypeOptionView.didTapControl)

}
