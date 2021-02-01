//
//  TriangleView.swift
//  falcon
//
//  Created by Federico Bond on 16/12/2020.
//  Copyright © 2020 muun. All rights reserved.
//

import UIKit

class TriangleView: UIView {

    var color: UIColor = .black

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()

        context.setFillColor(color.cgColor)
        context.fillPath()
    }
}
