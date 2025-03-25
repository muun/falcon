//
//  LightningAdvancedOptionsView.swift
//  falcon
//
//  Created by Federico Bond on 10/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit


protocol LightningAdvancedOptionsViewDelegate: AnyObject {
    func didTapAddAmount()
    func didToggleOptions(visible: Bool)
}

class LightningAdvancedOptionsView: UIView {

    private let stackView = UIStackView()
    private let headerStackView = UIStackView()
    private let toggleLabel = UILabel()
    private let chevronView = UIImageView(image: Asset.Assets.chevronAlt.image)
    private let amountOptionView = AmountOptionView()
    private let expirationTimeOptionView = ExpirationTimeOptionView()

    weak var delegate: LightningAdvancedOptionsViewDelegate?

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
        setUpExpirationTimeOptionView()

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
        toggleLabel.text = L10n.LightningAdvancedOptionsView.header
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

    private func setUpExpirationTimeOptionView() {
        expirationTimeOptionView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(expirationTimeOptionView)
    }

    private func updateHeader() {
        if showOptions {
            toggleLabel.text = L10n.LightningAdvancedOptionsView.hide
            amountOptionView.isHidden = false
            expirationTimeOptionView.isHidden = false
            chevronView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        } else {
            toggleLabel.text = L10n.LightningAdvancedOptionsView.header
            amountOptionView.isHidden = true
            expirationTimeOptionView.isHidden = true
            chevronView.transform = CGAffineTransform.identity
        }
    }

    // MARK: - View Controller Actions -

    func setAmount(_ bitcoinAmount: BitcoinAmountWithSelectedCurrency?) {
        amountOptionView.setAmount(bitcoinAmount)
    }

    func setExpirationTime(_ expirationTime: String?) {
        expirationTimeOptionView.setValue(expirationTime)
    }

    // MARK: - UI Handlers -

    @objc func didTapToggle() {
        showOptions.toggle()
        delegate?.didToggleOptions(visible: showOptions)
    }

}

extension LightningAdvancedOptionsView: AmountOptionViewDelegate {

    func didTapAddAmount() {
        delegate?.didTapAddAmount()
    }

}

fileprivate extension Selector {

    static let didTapToggle = #selector(LightningAdvancedOptionsView.didTapToggle)

}
