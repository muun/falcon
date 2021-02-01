//
//  NoticeView.swift
//  falcon
//
//  Created by Manu Herrera on 16/10/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

protocol NoticeViewDelegate: class {
    func didTapOnMessage()
}

enum NoticeType {
    case oneConf, rbf

    func getBackgroundColor() -> UIColor {
        switch self {
        case .oneConf:
            return Asset.Colors.noticeBackground.color
        case .rbf:
            return Asset.Colors.muunWarningRBF.color.withAlphaComponent(0.03)
        }
    }

    func getBorderColor() -> UIColor {
        switch self {
        case .oneConf:
            return Asset.Colors.noticeBorder.color
        case .rbf:
            return Asset.Colors.muunWarningRBF.color
        }
    }

    func getIcon() -> UIImage {
        switch self {
        case .oneConf:
            return Asset.Assets.notice.image
        case .rbf:
            return Asset.Assets.rbfNotice.image
        }
    }

    func getMessage() -> NSAttributedString {
        switch self {
        case .oneConf:
            return L10n.NewOperationView.s2
                .set(font: Constant.Fonts.system(size: .opHelper),
                     lineSpacing: Constant.FontAttributes.lineSpacing,
                     kerning: Constant.FontAttributes.kerning,
                     alignment: .left)
                .set(underline: L10n.NewOperationView.s3, color: Asset.Colors.muunBlue.color)
        case .rbf:
            return L10n.DetailViewController.rbfNotice
                .set(font: Constant.Fonts.system(size: .opHelper),
                     lineSpacing: Constant.FontAttributes.lineSpacing,
                     kerning: Constant.FontAttributes.kerning,
                     alignment: .left)
                .set(underline: L10n.DetailViewController.rbfCta, color: Asset.Colors.muunBlue.color)
        }
    }
}

class NoticeView: UIView {

    private let card: UIView! = UIView()
    private let helperImageView: UIImageView! = UIImageView()
    private let messageLabel: UILabel! = UILabel()

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

    public func setUp(_ type: NoticeType) {
        helperImageView.image = type.getIcon()
        card.backgroundColor = type.getBackgroundColor()
        card.layer.borderColor = type.getBorderColor().cgColor

        messageLabel.font = Constant.Fonts.system(size: .opHelper)
        messageLabel.textColor = Asset.Colors.muunGrayDark.color
        messageLabel.attributedText = type.getMessage()
    }

    @objc fileprivate func messageTapped() {
        delegate?.didTapOnMessage()
    }

}

fileprivate extension Selector {
    static let messageTapped = #selector(NoticeView.messageTapped)
}
