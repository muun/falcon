//
//  ShareEmergencyKitView.swift
//  falcon
//
//  Created by Manu Herrera on 24/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ShareEmergencyKitViewDelegate: class {
    func didTapOnOption(_ option: EKOption)
    func didTapOnCloudStorageInfo()
}

final class ShareEmergencyKitView: UIView {

    private var titleAndDescriptionView: TitleAndDescriptionView! = TitleAndDescriptionView()
    private var optionsStackView: UIStackView! = UIStackView()

    private weak var delegate: ShareEmergencyKitViewDelegate?
    private let options: [EKOption]

    init(delegate: ShareEmergencyKitViewDelegate?, options: [EKOption]) {
        self.delegate = delegate
        self.options = options
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpLabels()
        setUpOptionsStackView()
        makeViewTestable()
    }

    private func setUpLabels() {
        titleAndDescriptionView.titleText = L10n.ShareEmergencyKitView.title
        titleAndDescriptionView.descriptionText = L10n.ShareEmergencyKitView.description
            .attributedForDescription()
            .set(underline: L10n.ShareEmergencyKitView.descriptionCTA, color: Asset.Colors.muunBlue.color)
        titleAndDescriptionView.delegate = self
        titleAndDescriptionView.animate()
        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleAndDescriptionView)

        NSLayoutConstraint.activate([
            titleAndDescriptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            titleAndDescriptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin),
            titleAndDescriptionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleAndDescriptionView.topAnchor.constraint(equalTo: topAnchor)
        ])
    }

    private func setUpOptionsStackView() {
        optionsStackView.axis = .vertical
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.spacing = 0
        addSubview(optionsStackView)

        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: titleAndDescriptionView.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        setUpOptions()
    }

    private func setUpOptions() {
        for option in options {
            let optView = SaveEmergencyKitOptionView(delegate: self, option: option)
            optView.translatesAutoresizingMaskIntoConstraints = false
            optionsStackView.addArrangedSubview(optView)

            if option.option == .manually {
                makeViewTestable(optView, using: .saveManually)
            }
        }
    }

}

extension ShareEmergencyKitView: SaveEmergencyKitOptionViewDelegate {

    func didTapOnOption(_ option: EKOption) {
        delegate?.didTapOnOption(option)
    }

}

extension ShareEmergencyKitView: TitleAndDescriptionViewDelegate {

    func descriptionTouched() {
        delegate?.didTapOnCloudStorageInfo()
    }

}

extension ShareEmergencyKitView: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.SharePDF

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
    }

}
