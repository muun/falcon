//
//  NoticeView.swift
//  falcon
//
//  Created by Manu Herrera on 16/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol NoticeViewDelegate: AnyObject {
    func didTapOnMessage()
}

class NoticeView: UIView {

    struct Style {
        let backgroundColor: UIColor
        let borderColor: UIColor
        let icon: UIImage

        static let notice = Style(
            backgroundColor: Asset.Colors.noticeBackground.color,
            borderColor: Asset.Colors.noticeBorder.color,
            icon: Asset.Assets.notice.image
        )

        static let warning = Style(
            backgroundColor: Asset.Colors.muunWarningRBF.color.withAlphaComponent(0.03),
            borderColor: Asset.Colors.muunWarningRBF.color,
            icon: Asset.Assets.rbfNotice.image
        )
    }

    private let card: UIView! = UIView()
    private let helperImageView: UIImageView! = UIImageView()
    private let messageLabel: UILabel! = UILabel()

    var style: Style = .notice {
        didSet {
            helperImageView.image = style.icon
            card.backgroundColor = style.backgroundColor
            card.layer.borderColor = style.borderColor.cgColor
        }
    }

    var text: NSAttributedString? {
        didSet {
            messageLabel.font = Constant.Fonts.system(size: .opHelper)
            messageLabel.textColor = Asset.Colors.muunGrayDark.color
            messageLabel.attributedText = text
        }
    }

    weak var delegate: NoticeViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    private func setUpView() {
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.borderWidth = 1
        card.roundCorners(cornerRadius: 4, clipsToBounds: true)
        addSubview(card)
        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            card.topAnchor.constraint(equalTo: topAnchor)
        ])

        helperImageView.contentMode = .scaleAspectFit
        helperImageView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(helperImageView)
        NSLayoutConstraint.activate([
            helperImageView.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            helperImageView.heightAnchor.constraint(equalToConstant: 20),
            helperImageView.widthAnchor.constraint(equalToConstant: 20),
            helperImageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12)
        ])

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .left
        card.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: helperImageView.trailingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            messageLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            messageLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            messageLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        messageLabel.isUserInteractionEnabled = true
        messageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .messageTapped))
    }

    @objc fileprivate func messageTapped() {
        delegate?.didTapOnMessage()
    }

}

fileprivate extension Selector {
    static let messageTapped = #selector(NoticeView.messageTapped)
}
