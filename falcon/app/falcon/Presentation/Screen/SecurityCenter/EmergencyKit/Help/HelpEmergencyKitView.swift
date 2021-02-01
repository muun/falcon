//
//  HelpEmergencyKitView.swift
//  falcon
//
//  Created by Manu Herrera on 25/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

final class HelpEmergencyKitView: UIView {

    private var titleAndDescripionView: TitleAndDescriptionView!
    private var imageView: UIImageView!

    init() {
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpTitleAndDescriptionView()
        setUpImageView()
    }

    private func setUpTitleAndDescriptionView() {
        titleAndDescripionView = TitleAndDescriptionView()
        titleAndDescripionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleAndDescripionView)
        NSLayoutConstraint.activate([
            titleAndDescripionView.topAnchor.constraint(equalTo: topAnchor),
            titleAndDescripionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            titleAndDescripionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.sideMargin)
        ])

        titleAndDescripionView.titleText = L10n.HelpEmergencyKitView.s1
        titleAndDescripionView.descriptionText = L10n.HelpEmergencyKitView.s5
            .attributedForDescription()
            .set(bold: L10n.HelpEmergencyKitView.s2, color: Asset.Colors.title.color)
        titleAndDescripionView.animate()
    }

    private func setUpImageView() {
        imageView = UIImageView()
        imageView.image = Asset.Assets.ekActivationCode.image
        imageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: titleAndDescripionView.bottomAnchor, constant: 24),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

}
