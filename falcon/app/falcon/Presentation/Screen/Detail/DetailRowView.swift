//
//  DetailRowView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 29/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class DetailRowView: UIStackView {

    typealias TapHandler = () -> Void

    static let titleFont = Constant.Fonts.system(size: .helper)
    static let contentFont = Constant.Fonts.description
    static let titleColor = Asset.Colors.muunGrayDark.color
    static let contentColor = Asset.Colors.title.color

    let tapHandler: TapHandler?
    let longPressHandler: TapHandler?
    let iconTapHandler: TapHandler?

    convenience init(title: String, content: String) {
        self.init(title: NSAttributedString(string: title), content: NSAttributedString(string: content))
    }

    init(title: NSAttributedString,
         content: NSAttributedString? = nil,
         tapIcon: UIImage? = nil,
         onTap: TapHandler? = nil,
         onLongPress: TapHandler? = nil,
         onIconTap: TapHandler? = nil,
         titleColor: UIColor = DetailRowView.titleColor,
         contentColor: UIColor = DetailRowView.contentColor,
         titleFont: UIFont = DetailRowView.titleFont,
         contentFont: UIFont = DetailRowView.contentFont) {

        self.tapHandler = onTap
        self.iconTapHandler = onIconTap
        self.longPressHandler = onLongPress

        super.init(frame: CGRect.zero)

        alignment = .fill
        axis = .horizontal
        distribution = .fill
        spacing = 16

        let verticalStack = UIStackView()
        verticalStack.axis = .vertical
        verticalStack.distribution = .equalSpacing
        verticalStack.spacing = 4
        verticalStack.alignment = .fill
        addArrangedSubview(verticalStack)

        let titleLabel = UILabel()
        titleLabel.font = titleFont
        titleLabel.textColor = titleColor
        titleLabel.attributedText = title
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.numberOfLines = 0
        verticalStack.addArrangedSubview(titleLabel)

        if let content = content {
            let contentLabel = UILabel()
            contentLabel.font = contentFont
            contentLabel.textColor = contentColor
            contentLabel.attributedText = content
            contentLabel.numberOfLines = 0
            contentLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            contentLabel.setContentHuggingPriority(.required, for: .vertical)
            contentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            contentLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

            verticalStack.addArrangedSubview(contentLabel)
        }

        if onTap != nil {
            isUserInteractionEnabled = true
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: .tap))
        }

        if onLongPress != nil {
            isUserInteractionEnabled = true
            addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: .longPress))
        }

        if let tapIcon = tapIcon {
            let iconView = UIImageView(image: tapIcon)
            iconView.setContentCompressionResistancePriority(.required, for: .horizontal)
            iconView.setContentHuggingPriority(.required, for: .horizontal)
            iconView.contentMode = .scaleAspectFit

            addArrangedSubview(iconView)

            if onIconTap != nil {
                iconView.isUserInteractionEnabled = true
                iconView.gestureRecognizers?.removeAll()
                iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .iconTap))
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        preconditionFailure()
    }

    @objc fileprivate func tap() {
        if let tapHandler = tapHandler {
            tapHandler()
        }
    }

    @objc fileprivate func longPress() {
        if let longPressHandler = longPressHandler {
            longPressHandler()
        }
    }

    @objc fileprivate func iconTap() {
        if let iconTapHandler = iconTapHandler {
            iconTapHandler()
        }
    }

}

extension DetailRowView {

    static func amount(_ amount: BitcoinAmount, with title: String) -> DetailRowView {
        return DetailRowView(title: NSAttributedString(string: title),
                             content: amount.attributedString(with: DetailRowView.contentFont))
    }

    static func link(_ text: String, title: String, onTap: @escaping DetailRowView.TapHandler) -> DetailRowView {

        return DetailRowView(title: NSAttributedString(string: title),
                             content: NSAttributedString(string: text),
                             onTap: onTap,
                             contentColor: Asset.Colors.muunBlue.color)
    }

    static func text(_ text: String) -> DetailRowView {
        return DetailRowView(title: NSAttributedString(string: text),
                             titleColor: DetailRowView.contentColor,
                             titleFont: DetailRowView.contentFont)
    }

    static func text(_ text: String, link: String, onTap: @escaping DetailRowView.TapHandler) -> DetailRowView {

        let content = text
            .set(font: DetailRowView.contentFont)
            .set(underline: link, color: Asset.Colors.muunBlue.color)

        return DetailRowView(title: content,
                             onTap: onTap,
                             titleColor: DetailRowView.contentColor)
    }

    static func clipboard(_ content: String,
                          title: String,
                          valueToBeCopied: String? = nil,
                          controller: MUViewController) -> DetailRowView {
        let onTap = { [weak controller] in
            UIPasteboard.general.string = valueToBeCopied ?? content

            if let controller = controller {
                controller.showToast(message: L10n.DetailRowView.s1)
            }
        }

        return DetailRowView(title: NSAttributedString(string: title),
                             content: NSAttributedString(string: content),
                             tapIcon: Asset.Assets.copy.image,
                             onTap: onTap)
    }

    static func copyableAmount(_ amount: BitcoinAmount, title: String, controller: MUViewController) -> DetailRowView {
        let onTap = { [weak controller] in
            UIPasteboard.general.string = amount.inSatoshis.toBTC().toAmountPlusCode()

            if let controller = controller {
                controller.showToast(message: L10n.DetailRowView.s1)
            }
        }

        return DetailRowView(title: NSAttributedString(string: title),
                             content: amount.attributedString(with: DetailRowView.contentFont),
                             tapIcon: Asset.Assets.copy.image,
                             onTap: onTap)
    }
}

extension Selector {
    fileprivate static let tap = #selector(DetailRowView.tap)
    fileprivate static let longPress = #selector(DetailRowView.longPress)
    fileprivate static let iconTap = #selector(DetailRowView.iconTap)
}
