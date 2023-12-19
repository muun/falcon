//
//  MUFeedbackView.swift
//  Muun
//
//  Created by Lucas Serruya on 17/09/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation
import UIKit

class RequestCloudFeedbackView: UIView {

    private let stack = UIStackView()

    init() {
        super.init(frame: CGRect())
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpView() {
        setupStackView()

        addSpacerToFixStackDistribution()
        addImageView()
        addTitleLabel()
        addSpacerToFixStackDistribution()
    }
}

private extension RequestCloudFeedbackView {
    func setupStackView() {
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(equalTo: widthAnchor),
            stack.heightAnchor.constraint(equalTo: heightAnchor),
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func addSpacerToFixStackDistribution() {
        let spacer = UIView()
        NSLayoutConstraint.activate([
            spacer.heightAnchor.constraint(equalToConstant: 0)
        ])
        stack.addArrangedSubview(spacer)
    }

    func addImageView() {
        let feedbackImage = UIImageView()
        let image = Asset.Assets.success.image

        feedbackImage.image = image
        feedbackImage.translatesAutoresizingMaskIntoConstraints = false

        stack.addArrangedSubview(feedbackImage)
    }

    func addTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.text = L10n.RequestCloudFeedbackView.title
        titleLabel.textColor = Asset.Colors.title.color
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.font = Constant.Fonts.system(size: .h2, weight: .medium)

        stack.addArrangedSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor,
                                                constant: .sideMargin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor,
                                                 constant: -.sideMargin)
        ])
    }
}
