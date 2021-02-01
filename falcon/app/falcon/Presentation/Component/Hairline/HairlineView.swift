//
//  HairlineView.swift
//  falcon
//
//  Created by Juan Pablo Civile on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import Foundation
import UIKit

class HairlineView: UIView {

    var color: UIColor = Asset.Colors.cardViewBorder.color {
        didSet {
            self.layer.borderColor = color.cgColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    init() {
        super.init(frame: CGRect.zero)

        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    override func didMoveToSuperview() {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = (1.0 / UIScreen.main.scale) / 2
        self.backgroundColor = UIColor.clear
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: (1.0 / UIScreen.main.scale))
    }
}
