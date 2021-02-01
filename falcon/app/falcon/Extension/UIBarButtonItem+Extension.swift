//
//  UIBarButtonItem+Extension.swift
//  falcon
//
//  Created by Juan Pablo Civile on 25/09/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import UIKit

extension UIBarButtonItem {

    static func stepCounter(step: Int, end: Int) -> UIBarButtonItem {

        let string = L10n.UIBarButtonItem.s1(String(describing: step), String(describing: end))

        let barButtonItem = UIBarButtonItem(title: string, style: .plain, target: self, action: nil)

        barButtonItem.setTitleTextAttributes(
            [.foregroundColor: Asset.Colors.muunDisabled.color,
             .font: Constant.Fonts.system(size: .desc, weight: .light)],
            for: .disabled
        )

        barButtonItem.isEnabled = false

        return barButtonItem
    }
}
