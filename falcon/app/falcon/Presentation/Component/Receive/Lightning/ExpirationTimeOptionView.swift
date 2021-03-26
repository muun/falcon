//
//  ExpirationTimeOptionView.swift
//  falcon
//
//  Created by Federico Bond on 11/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import UIKit

class ExpirationTimeOptionView: UIStackView {

    private let label = UILabel()
    private let value = UILabel()
    private let spinner = UIActivityIndicatorView()

    init() {
        super.init(frame: .zero)
        setUpView()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Views Layout and configuration -

    private func setUpView() {
        distribution = .fill
        axis = .horizontal
        alignment = .center
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(top: .verticalRowMargin, left: .sideMargin, bottom: .verticalRowMargin, right: .sideMargin)

        setUpLabel()
        setUpValue()
        setUpSpinner()
    }

    private func setUpLabel() {
        label.text = L10n.ExpirationTimeOptionView.label
        label.font = Constant.Fonts.system(size: .desc)
        addArrangedSubview(label)
    }

    private func setUpValue() {
        value.textAlignment = .right
        value.font = Constant.Fonts.system(size: .desc)
        value.textColor = Asset.Colors.muunGrayDark.color
        addArrangedSubview(value)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func setUpSpinner() {
        spinner.startAnimating()
        spinner.isHidden = true

        addArrangedSubview(spinner)
    }

    // MARK: - View Controller Actions -

    func setValue(_ expirationTime: String?) {
        if let expirationTime = expirationTime {
            spinner.isHidden = true
            value.isHidden = false
            value.text = expirationTime
        } else {
            spinner.isHidden = false
            value.isHidden = true
            value.text = nil
        }
    }
}
