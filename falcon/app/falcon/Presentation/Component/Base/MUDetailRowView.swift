//
//  MUDetailRowView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 29/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

class MUDetailRowView: UIStackView {

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
         titleColor: UIColor = MUDetailRowView.titleColor,
         contentColor: UIColor = MUDetailRowView.contentColor,
         titleFont: UIFont = MUDetailRowView.titleFont,
         contentFont: UIFont = MUDetailRowView.contentFont) {

        self.tapHandler = onTap
        self.iconTapHandler = onIconTap
        self.longPressHandler = onLongPress

        super.init(frame: CGRect.zero)

        alignment = .fill
        axis = .horizontal
        distribution = .fill
        spacing = 0

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

            if onIconTap != nil {
                iconView.isUserInteractionEnabled = true
                iconView.gestureRecognizers?.removeAll()
                iconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .iconTap))
                let touchExpandedFrame = createTouchExpandedFrameForIcon()
                addArrangedSubview(touchExpandedFrame)
            }

            addArrangedSubview(iconView)
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
    
    private func createTouchExpandedFrameForIcon() -> UIView {
        let extendedTappableFrame = UIView()
        extendedTappableFrame.addGestureRecognizer(UITapGestureRecognizer(target: self, action: .iconTap))
        extendedTappableFrame.backgroundColor = .clear
        extendedTappableFrame.translatesAutoresizingMaskIntoConstraints = false
        extendedTappableFrame.isUserInteractionEnabled = true
        NSLayoutConstraint.activate([
            extendedTappableFrame.widthAnchor.constraint(equalToConstant: 16)
        ])
        return extendedTappableFrame
    }

}

extension MUDetailRowView {

    static func amount(_ amount: BitcoinAmount, with title: String) -> MUDetailRowView {
        return MUDetailRowView(title: NSAttributedString(string: title),
                             content: amount.attributedString(with: MUDetailRowView.contentFont))
    }

    static func link(_ text: String, title: String, onTap: @escaping MUDetailRowView.TapHandler) -> MUDetailRowView {

        return MUDetailRowView(title: NSAttributedString(string: title),
                             content: NSAttributedString(string: text),
                             onTap: onTap,
                             contentColor: Asset.Colors.muunBlue.color)
    }

    static func text(_ text: String) -> MUDetailRowView {
        return MUDetailRowView(title: NSAttributedString(string: text),
                             titleColor: MUDetailRowView.contentColor,
                             titleFont: MUDetailRowView.contentFont)
    }

    static func text(_ text: String, link: String, onTap: @escaping MUDetailRowView.TapHandler) -> MUDetailRowView {

        let content = text
            .set(font: MUDetailRowView.contentFont)
            .set(underline: link, color: Asset.Colors.muunBlue.color)

        return MUDetailRowView(title: content,
                             onTap: onTap,
                             titleColor: MUDetailRowView.contentColor)
    }

    static func clipboard(_ content: String,
                          title: String,
                          valueToBeCopied: String? = nil,
                          controller: DisplayableToast) -> MUDetailRowView {
        return clipboard(content.toAttributedString(),
                         title: title.toAttributedString(),
                         valueToBeCopied: valueToBeCopied,
                         controller: controller,
                         takeTapOnlyOnButton: false)
    }

    static func clipboard(_ content: NSAttributedString? = nil,
                          title: NSAttributedString,
                          valueToBeCopied: String? = nil,
                          controller: DisplayableToast,
                          takeTapOnlyOnButton: Bool) -> MUDetailRowView {
        let onTap = { [weak controller] in
            if let valueToBeCopied = valueToBeCopied {
                UIPasteboard.general.string = valueToBeCopied
            } else if let content = content?.string {
                UIPasteboard.general.string = content
            } else {
                UIPasteboard.general.string = title.string
            }

            if let controller = controller {
                controller.showToast(message: L10n.MUDetailRowView.s1)
            }
        }

        let onTapAllView: (() -> Void)? = takeTapOnlyOnButton ? nil : onTap
        return MUDetailRowView(title: title,
                               content: content,
                               tapIcon: Asset.Assets.copy.image,
                               onTap: onTapAllView,
                               onIconTap: onTap)
    }

    static func copyableAmount(_ amount: BitcoinAmount,
                               title: String,
                               controller: MUViewController) -> MUDetailRowView {
        let onTap = { [weak controller] in
            UIPasteboard.general.string = amount.inSatoshis.toBTC().toAmountPlusCode()

            if let controller = controller {
                controller.showToast(message: L10n.MUDetailRowView.s1)
            }
        }

        return MUDetailRowView(title: NSAttributedString(string: title),
                             content: amount.attributedString(with: MUDetailRowView.contentFont),
                             tapIcon: Asset.Assets.copy.image,
                             onTap: onTap)
    }
}

extension Selector {
    fileprivate static let tap = #selector(MUDetailRowView.tap)
    fileprivate static let longPress = #selector(MUDetailRowView.longPress)
    fileprivate static let iconTap = #selector(MUDetailRowView.iconTap)
}
