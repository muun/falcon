//
//  AddressTypeOptionView.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit


protocol AddressTypeOptionViewDelegate: AnyObject {
    func didTapControl()
}

class SelectAddressTypeOptionView: UIStackView {

    private let label = UILabel()
    private let controlView = UIStackView()
    private let controlButton = UIButton()

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
        controlButton.addTarget(self, action: .didTapControl, for: .touchUpInside)
        controlButton.semanticContentAttribute = .forceRightToLeft
        controlButton.setImage(Asset.Assets.chevronAlt.image, for: .normal)
        controlButton.titleLabel?.font = Constant.Fonts.system(size: .desc)
        controlButton.setTitleColor(Asset.Colors.muunGrayDark.color, for: .normal)
        controlButton.setTitleColor(UIColor.black, for: .selected)
        controlView.axis = .horizontal
        controlView.distribution = .equalCentering
        controlView.alignment = .center
        controlView.isUserInteractionEnabled = true

        controlView.addArrangedSubview(controlButton)

        controlView.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(controlView)
    }

    // MARK: - View Controller Actions -

    func setValue(_ addressType: AddressTypeViewModel) {
        controlButton.setTitle(addressType.name, for: .normal)
    }

    // MARK: - UI Handlers -

    @objc func didTapControl() {
        delegate?.didTapControl()
    }

}

fileprivate extension Selector {
    static let didTapControl = #selector(SelectAddressTypeOptionView.didTapControl)
}
