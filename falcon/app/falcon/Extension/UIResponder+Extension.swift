//
//  UIResponder+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 08/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
