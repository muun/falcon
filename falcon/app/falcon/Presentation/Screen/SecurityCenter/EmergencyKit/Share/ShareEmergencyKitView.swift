//
//  ShareEmergencyKitView.swift
//  falcon
//
//  Created by Manu Herrera on 24/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol ShareEmergencyKitViewDelegate: AnyObject {
    func didTapOnOption(_ option: EKOption)
    func didTapOnManualExport()
}

final class ShareEmergencyKitView: UIView {

    private var titleAndDescriptionView: TitleAndDescriptionView = TitleAndDescriptionView()
    private var optionsStackView: UIStackView = UIStackView()
    private var scrollView: UIScrollView = UIScrollView()
    private var manualExport: LinkButtonView = LinkButtonView()

    private weak var delegate: ShareEmergencyKitViewDelegate?
    private let options: [EKOption]

    init(delegate: ShareEmergencyKitViewDelegate?,
         options: [EKOption],
         flow: EmergencyKitFlow) {
        self.delegate = delegate
        self.options = options
        super.init(frame: .zero)

        setUpView(flow: flow)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView(flow: EmergencyKitFlow) {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        setUpLabels(flow: flow)
        setUpOptionsStackView()
        setUpManualExport()
        makeViewTestable()
    }

    private func setUpLabels(flow: EmergencyKitFlow) {
        switch flow {
        case .export:
            titleAndDescriptionView.titleText = L10n.ShareEmergencyKitView.exportTitle
        case .update:
            titleAndDescriptionView.titleText = L10n.ShareEmergencyKitView.updateTitle
        }

        titleAndDescriptionView.descriptionText = L10n.ShareEmergencyKitView.description
            .attributedForDescription()
        titleAndDescriptionView.animate()
        titleAndDescriptionView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(titleAndDescriptionView)

        NSLayoutConstraint.activate([
            titleAndDescriptionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: .sideMargin),
            titleAndDescriptionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -.sideMargin),
            titleAndDescriptionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleAndDescriptionView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        ])
    }

    private func setUpOptionsStackView() {
        optionsStackView.axis = .vertical
        optionsStackView.translatesAutoresizingMaskIntoConstraints = false
        optionsStackView.spacing = 0
        scrollView.addSubview(optionsStackView)

        NSLayoutConstraint.activate([
            optionsStackView.topAnchor.constraint(equalTo: titleAndDescriptionView.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])

        setUpOptions()
    }

    private func setUpOptions() {
        for option in options {
            let optView = SaveEmergencyKitOptionView(delegate: self, option: option)
            optView.translatesAutoresizingMaskIntoConstraints = false
            optionsStackView.addArrangedSubview(optView)
        }
    }

    private func setUpManualExport() {
        manualExport.translatesAutoresizingMaskIntoConstraints = false
        manualExport.buttonText = L10n.ShareEmergencyKitView.saveManually
        manualExport.isEnabled = true
        manualExport.delegate = self
        scrollView.addSubview(manualExport)

        NSLayoutConstraint.activate([
            manualExport.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            manualExport.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: .spacing),
            scrollView.bottomAnchor.constraint(equalTo: manualExport.bottomAnchor),
        ])
    }

}

extension ShareEmergencyKitView: SaveEmergencyKitOptionViewDelegate {

    func didTapOnOption(_ option: EKOption) {
        delegate?.didTapOnOption(option)
    }

}

extension ShareEmergencyKitView: UITestablePage {

    typealias UIElementType = UIElements.Pages.EmergencyKit.SharePDF

    func makeViewTestable() {
        makeViewTestable(self, using: .root)
    }

}

extension ShareEmergencyKitView: LinkButtonViewDelegate {

    func linkButton(didPress linkButton: LinkButtonView) {
        delegate?.didTapOnManualExport()
    }

}
