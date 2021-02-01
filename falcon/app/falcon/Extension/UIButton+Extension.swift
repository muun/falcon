//
//  UIButton+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 25/04/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

extension UIButton {

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.shrink()
        super.touchesBegan(touches, with: event)
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animateIdentity()
        super.touchesEnded(touches, with: event)
    }

}
