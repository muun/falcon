//
//  MultiOptionPickerViewDelegate.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit
import core

protocol MultiOptionPickerViewDelegate: AnyObject {
    func didTapControl()
}

class MultiOptionPickerView: UIStackView {

    private let label = UILabel()
    private let controlView = UIStackView()
    private let controlLabel = UILabel()

    weak var delegate: MultiOptionPickerViewDelegate?

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
        layoutMargins = UIEdgeInsets(top: .verticalRowMargin, left: 8, bottom: .verticalRowMargin, right: 8)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56)
        ])

        setUpLabelView()
        setUpControlView()
    }

    private func setUpLabelView() {
        label.text = L10n.AddressTypeOptionView.label
        label.font = Constant.Fonts.system(size: .desc)
        addArrangedSubview(label)
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

    func setValue(_ selectedOption: any MultiPickerOptions) {
        controlLabel.text = selectedOption.name()
    }

    // MARK: - UI Handlers -

    @objc func didTapControl() {
        delegate?.didTapControl()
    }

}

fileprivate extension Selector {

    static let didTapControl = #selector(MultiOptionPickerView.didTapControl)

}
