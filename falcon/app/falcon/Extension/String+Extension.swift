//
//  String+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 14/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

extension String {

    public var stringBytes: [UInt8] {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }

    func attributedForDescription(alignment: NSTextAlignment = .natural,
                                  paragraphLineBreakMode: NSLineBreakMode? = nil) -> NSMutableAttributedString {
        return self.set(font: Constant.Fonts.description,
                        lineSpacing: Constant.FontAttributes.lineSpacing,
                        kerning: Constant.FontAttributes.kerning,
                        alignment: alignment,
                        paragraphLineBreakMode: paragraphLineBreakMode)
    }

    func toAttributedString() -> NSMutableAttributedString {
        NSMutableAttributedString(string: self)
    }

    func set(font: UIFont,
             lineSpacing: CGFloat = 0,
             kerning: CGFloat? = nil,
             alignment: NSTextAlignment? = nil,
             paragraphLineBreakMode: NSLineBreakMode? = nil)
        -> NSMutableAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.setParagraphStyle(NSParagraphStyle.default)
        paragraphLineBreakMode.map { paragraphStyle.lineBreakMode = $0 }
        paragraphStyle.lineSpacing = lineSpacing
        if let alignment = alignment {
            paragraphStyle.alignment = alignment
        }

        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle
        ]

        if let kerning = kerning {
            attributes[.kern] = kerning
        }
        return NSMutableAttributedString(string: self, attributes: attributes)
    }

    func truncate(maxLength: Int) -> String {
        return String(self.prefix(maxLength))
    }

}

extension NSMutableAttributedString {

    func set(bold text: String,
             color: UIColor = Asset.Colors.black.color,
             weight: UIFont.Weight = .bold) -> NSMutableAttributedString {
        let boldFontAttribute: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: getFont().pointSize, weight: .bold),
            .foregroundColor: color
        ]
        let range = (self.string as NSString).range(of: text)
        addAttributes(boldFontAttribute, range: range)
        return self
    }

    func set(tint text: String, color: UIColor) -> NSMutableAttributedString {
        let tintAttribute: [NSAttributedString.Key: Any] = [
            .foregroundColor: color
        ]
        let range = (self.string as NSString).range(of: text)
        addAttributes(tintAttribute, range: range)
        return self
    }

    func set(underline text: String, color: UIColor) -> NSMutableAttributedString {
        let underlineAttribute: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: color
        ]
        let range = (self.string as NSString).range(of: text)
        addAttributes(underlineAttribute, range: range)
        return self
    }

    private func getFont() -> UIFont {
        if length > 0 {
            let attrs = attributes(at: 0, effectiveRange: nil)
            if let font = attrs[.font] as? UIFont {
                return font
            }
        }
        return Constant.Fonts.description
    }

}
