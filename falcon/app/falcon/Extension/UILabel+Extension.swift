//
//  UILabel+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 05/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

enum LabelStyle {
    case title
    case description
    case error
    case warning
}

extension UILabel {

    var style: LabelStyle {
        get { return .description }
        set(newStyle) {
            switch newStyle {

            case .title:
                self.textColor = Asset.Colors.title.color
                self.font = Constant.Fonts.system(size: .h2, weight: .medium)

            case .description:
                self.textColor = Asset.Colors.muunGrayDark.color
                self.font = Constant.Fonts.description

            case .error:
                self.textColor = Asset.Colors.muunRed.color
                self.font = Constant.Fonts.system(size: .helper, weight: .medium)
            case .warning:
                self.textColor = Asset.Colors.muunWarning.color
                self.font = Constant.Fonts.system(size: .helper, weight: .medium)
            }
        }
    }

    var isTruncated: Bool {
        guard let labelText = text else {
            return false
        }

        let labelTextSize = (labelText as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil).size

        return labelTextSize.height > bounds.size.height
    }

}
