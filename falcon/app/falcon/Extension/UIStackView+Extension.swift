//
//  UIStackView+Extension.swift
//  Muun
//
//  Created by Lucas Serruya on 03/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import UIKit

extension UIStackView {
    func addArrangedSubviewWrappingLeadingAndTrailing(_ child: UIView) {
        precondition(self.axis == .vertical,
                     "Wrapping leading and trailing of a not vertical stack child will break the view")
        addArrangedSubview(child)
        addConstraint(NSLayoutConstraint(item: child,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: self,
                                         attribute: .leading,
                                         multiplier: 1.0,
                                         constant: 0.0))

        addConstraint(NSLayoutConstraint(item: self,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: child,
                                         attribute: .trailing,
                                         multiplier: 1.0,
                                         constant: 0.0))
    }
}
