//
//  TaprootActivatedPopup.swift
//  falcon
//
//  Created by Juan Pablo Civile on 03/11/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import UIKit

protocol TaprootActivatedPopupDelegate: AnyObject {
    func dismiss(taprootActivated: TaprootActivatedPopup)
}

class TaprootActivatedPopup: UIView {

    private weak var delegate: TaprootActivatedPopupDelegate?

    required init?(coder: NSCoder) {
        preconditionFailure()
    }

    init(delegate: TaprootActivatedPopupDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)

        setupView()
    }

    private func setupView() {
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = Asset.Colors.white.color
        card.roundCorners(cornerRadius: 8, clipsToBounds: true)

        addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .sideMargin),
            trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: .sideMargin),

            card.topAnchor.constraint(equalTo: topAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let image = UIImageView(image: Asset.Assets.taprootActivated.image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.setContentHuggingPriority(.required, for: .vertical)
        image.setContentCompressionResistancePriority(.required, for: .horizontal)
        image.setContentCompressionResistancePriority(.required, for: .vertical)
        image.contentMode = .center
        card.addSubview(image)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            card.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            image.topAnchor.constraint(equalTo: card.topAnchor, constant: .closeSpacing)
        ])

        let blockClock = BlockClockView()
        blockClock.translatesAutoresizingMaskIntoConstraints = false
        blockClock.blocks = 0

        card.addSubview(blockClock)
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: blockClock.centerXAnchor),
            blockClock.topAnchor.constraint(equalTo: image.bottomAnchor, constant: -.closeSpacing)
        ])

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = L10n.TaprootActivatedPopup.title
        title.textColor = Asset.Colors.title.color
        title.font = Constant.Fonts.system(size: .h2, weight: .medium)
        title.textAlignment = .center
        card.addSubview(title)

        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: blockClock.bottomAnchor, constant: .bigSpacing),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: .sideMargin),
            card.trailingAnchor.constraint(equalTo: title.trailingAnchor, constant: .sideMargin)
        ])

        let description = UILabel()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.attributedText = L10n.TaprootActivatedPopup.description.attributedForDescription()
        description.textColor = Asset.Colors.muunGrayDark.color
        description.font = Constant.Fonts.description
        description.textAlignment = .center
        description.numberOfLines = 0
        card.addSubview(description)

        NSLayoutConstraint.activate([
            description.topAnchor.constraint(equalTo: title.bottomAnchor, constant: .closeSpacing),
            description.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: .sideMargin),
            card.trailingAnchor.constraint(equalTo: description.trailingAnchor, constant: .sideMargin)
        ])

        let button = SmallButtonView()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.buttonText = L10n.TaprootActivatedPopup.ok
        button.isEnabled = true
        button.delegate = self

        card.addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: description.bottomAnchor, constant: .headerSpacing),
            button.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: .sideMargin),
            card.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: .sideMargin),
            card.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: .bigSpacing),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let parent = superview {
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalTo: parent.widthAnchor)
            ])
        }
    }
}

extension TaprootActivatedPopup: SmallButtonViewDelegate {

    func button(didPress button: SmallButtonView) {
        delegate?.dismiss(taprootActivated: self)
    }
}
