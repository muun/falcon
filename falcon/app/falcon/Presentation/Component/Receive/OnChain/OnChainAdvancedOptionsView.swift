//
//  OnChainAdvancedOptionsView.swift
//  falcon
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit


protocol OnChainAdvancedOptionsViewDelegate: AnyObject {
    func didTapOnAddressTypeControl()
    func didTapAddAmount()
    func didToggleOptions(visible: Bool)
}

class OnChainAdvancedOptionsView: UIView {

    private let stackView = UIStackView()
    private let headerStackView = UIStackView()
    private let toggleLabel = UILabel()
    private let chevronView = UIImageView(image: Asset.Assets.chevronAlt.image)
    private let addressTypeOptionView = SelectAddressTypeOptionView()
    private let amountOptionView = AmountOptionView()

    weak var delegate: OnChainAdvancedOptionsViewDelegate?

    private var showOptions = true {
        didSet {
            updateHeader()
        }
    }

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views Layout and configuration -

    private func setUpView() {
        setUpStackView()
        setUpHeaderStackView()
        setUpAmountOptionView()
        setUpAddressTypeOptionView()

        showOptions = false
    }

    private func setUpStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.sideMargin)
        ])
    }

    private func setUpHeaderStackView() {
        headerStackView.axis = .vertical
        headerStackView.alignment = .center
        headerStackView.isUserInteractionEnabled = true
        headerStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .didTapToggle))
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(headerStackView)

        let labelWithChevronStackView = UIStackView()
        labelWithChevronStackView.axis = .horizontal
        labelWithChevronStackView.alignment = .center
        toggleLabel.text = L10n.OnChainAdvancedOptionsView.header
        toggleLabel.textColor = Asset.Colors.muunBlue.color
        toggleLabel.font = Constant.Fonts.system(size: .desc, weight: .bold)
        toggleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelWithChevronStackView.addArrangedSubview(toggleLabel)

        chevronView.translatesAutoresizingMaskIntoConstraints = false
        labelWithChevronStackView.addArrangedSubview(chevronView)

        NSLayoutConstraint.activate([
            labelWithChevronStackView.heightAnchor.constraint(equalToConstant: 56),
            chevronView.widthAnchor.constraint(equalToConstant: 20),
            chevronView.heightAnchor.constraint(equalTo: chevronView.widthAnchor)
        ])

        headerStackView.addArrangedSubview(labelWithChevronStackView)
    }

    private func setUpAmountOptionView() {
        amountOptionView.delegate = self
        amountOptionView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(amountOptionView)
    }

    private func setUpAddressTypeOptionView() {
        addressTypeOptionView.delegate = self
        addressTypeOptionView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(addressTypeOptionView)
    }

    private func updateHeader() {
        if showOptions {
            toggleLabel.text = L10n.OnChainAdvancedOptionsView.hide
            addressTypeOptionView.isHidden = false
            amountOptionView.isHidden = false
            chevronView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

        } else {
            toggleLabel.text = L10n.OnChainAdvancedOptionsView.header
            addressTypeOptionView.isHidden = true
            amountOptionView.isHidden = true
            chevronView.transform = CGAffineTransform.identity
        }
    }

    // MARK: - View Controller Actions -

    func setAmount(_ bitcoinAmount: BitcoinAmountWithSelectedCurrency?) {
        amountOptionView.setAmount(bitcoinAmount)
    }

    func setAddressType(_ addressType: AddressTypeViewModel) {
        addressTypeOptionView.setValue(addressType)
    }

    // MARK: - UI Handlers -

    @objc func didTapToggle() {
        showOptions.toggle()
        delegate?.didToggleOptions(visible: showOptions)
    }

}

extension OnChainAdvancedOptionsView: AddressTypeOptionViewDelegate {

    func didTapControl() {
        delegate?.didTapOnAddressTypeControl()
    }

}

extension OnChainAdvancedOptionsView: AmountOptionViewDelegate {

    func didTapAddAmount() {
        delegate?.didTapAddAmount()
    }

}

fileprivate extension Selector {

    static let didTapToggle = #selector(OnChainAdvancedOptionsView.didTapToggle)

}
