//
//  EmailAlreadyUsedView.swift
//  falcon
//
//  Created by Manu Herrera on 24/06/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol EmailAlreadyUsedViewDelegate: class {
    func descriptionTouched()
}

class EmailAlreadyUsedView: UIView {

    private var titleAndDescripionView: TitleAndDescriptionView!
    private weak var delegate: EmailAlreadyUsedViewDelegate?

    init(delegate: EmailAlreadyUsedViewDelegate) {
        self.delegate = delegate

        super.init(frame: .zero)
        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        setUpTitleAndDescriptionView()
    }

    private func setUpTitleAndDescriptionView() {
        titleAndDescripionView = TitleAndDescriptionView()
        titleAndDescripionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleAndDescripionView)
        NSLayoutConstraint.activate([
            titleAndDescripionView.topAnchor.constraint(equalTo: topAnchor),
            titleAndDescripionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleAndDescripionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        titleAndDescripionView.titleText = L10n.EmailAlreadyUsedView.s1
        titleAndDescripionView.descriptionText = L10n.EmailAlreadyUsedView.s3
            .attributedForDescription()
            .set(underline: L10n.EmailAlreadyUsedView.s2, color: Asset.Colors.muunBlue.color)
        titleAndDescripionView.delegate = self
    }

    func animateView() {
        titleAndDescripionView.animate()
    }
}

extension EmailAlreadyUsedView: TitleAndDescriptionViewDelegate {
    func descriptionTouched() {
        delegate?.descriptionTouched()
    }
}
