//
//  QRCodeWithActions.swift
//  falconUITests
//
//  Created by Federico Bond on 09/02/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import XCTest

final class QRCodeWithActions: UIElementPage<UIElements.CustomViews.QRCodeWithActions> {

    private lazy var addressLabel = label(.address)

    init(_ root: UIElement) {
        super.init(root: root)
    }

    func address() -> String {
        return addressLabel.label
    }

}
