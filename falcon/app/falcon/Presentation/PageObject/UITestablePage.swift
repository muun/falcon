//
//  UITestablePage.swift
//  falcon
//
//  Created by Manu Herrera on 08/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

protocol UITestablePage {
    associatedtype UIElementType: UIElement

    func makeViewTestable(_ view: UIAccessibilityIdentification, using element: UIElementType)
}

extension UITestablePage {

    func makeViewTestable(_ view: UIAccessibilityIdentification, using element: UIElementType) {
        #if DEBUG
            view.accessibilityIdentifier = element.accessibilityIdentifier
        #endif
    }

}
