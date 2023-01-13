//
// Created by Juan Pablo Civile on 28/10/2021.
// Copyright (c) 2021 muun. All rights reserved.
//

import Foundation
import UIKit

class BlockClockView: UIView {

    private static let digitImages: [UIImage] = {
        [
            Asset.Assets.clock0.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock1.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock2.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock3.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock4.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock5.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock6.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock7.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock8.image.withRenderingMode(.alwaysTemplate),
            Asset.Assets.clock9.image.withRenderingMode(.alwaysTemplate)
        ]
    }()

    private let digits: [UIImageView]
    public var blocks: UInt = 0 {
        didSet {
            updateDigits()
        }
    }

    init() {
        digits = (0..<6).map { _ in
            UIImageView()
        }

        super.init(frame: .zero)

        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)

        backgroundColor = Asset.Colors.blueLighttest.color

        layer.borderColor = Asset.Colors.muunBlue.color.cgColor
        layer.borderWidth = 1

        roundCorners(cornerRadius: 6, clipsToBounds: true)

        var digitBoxes = [UIView]()
        for digit in digits {
            digit.translatesAutoresizingMaskIntoConstraints = false
            digit.tintColor = Asset.Colors.grayDarkest.color

            let digitBox = UIView()
            digitBox.translatesAutoresizingMaskIntoConstraints = false

            digitBox.backgroundColor = Asset.Colors.white.color

            digitBox.layer.borderColor = Asset.Colors.muunBlue.color.cgColor
            digitBox.layer.borderWidth = 1
            digitBox.roundCorners(cornerRadius: 4, clipsToBounds: true)

            addSubview(digitBox)
            addSubview(digit)
            digitBoxes.append(digitBox)

            NSLayoutConstraint.activate([
                digitBox.centerXAnchor.constraint(equalTo: digit.centerXAnchor),
                digitBox.centerYAnchor.constraint(equalTo: digit.centerYAnchor),
                digitBox.topAnchor.constraint(equalTo: topAnchor, constant: .closeSpacing),
                digitBox.heightAnchor.constraint(equalToConstant: 30),
            ])
        }

        let taproot = UIImageView(image: Asset.Assets.clockTaproot.image)
        taproot.translatesAutoresizingMaskIntoConstraints = false
        addSubview(taproot)

        taproot.tintColor = Asset.Colors.muunBlue.color

        let coinkite = UIImageView(image: Asset.Assets.clockCoinkite.image)
        coinkite.translatesAutoresizingMaskIntoConstraints = false
        addSubview(coinkite)

        coinkite.tintColor = Asset.Colors.muunBlue.color

        NSLayoutConstraint.activate([
            // Leading to trailing for the digits
            digitBoxes[0].leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            digitBoxes[1].leadingAnchor.constraint(equalTo: digitBoxes[0].trailingAnchor, constant: 6),
            digitBoxes[2].leadingAnchor.constraint(equalTo: digitBoxes[1].trailingAnchor, constant: 6),
            digitBoxes[3].leadingAnchor.constraint(equalTo: digitBoxes[2].trailingAnchor, constant: 6),
            digitBoxes[4].leadingAnchor.constraint(equalTo: digitBoxes[3].trailingAnchor, constant: 6),
            digitBoxes[5].leadingAnchor.constraint(equalTo: digitBoxes[4].trailingAnchor, constant: 6),
            trailingAnchor.constraint(equalTo: digitBoxes[5].trailingAnchor, constant: 10),

            // All digit boxes have the same width
            digitBoxes[0].widthAnchor.constraint(equalTo: digitBoxes[1].widthAnchor),
            digitBoxes[0].widthAnchor.constraint(equalTo: digitBoxes[2].widthAnchor),
            digitBoxes[0].widthAnchor.constraint(equalTo: digitBoxes[3].widthAnchor),
            digitBoxes[0].widthAnchor.constraint(equalTo: digitBoxes[4].widthAnchor),
            digitBoxes[0].widthAnchor.constraint(equalTo: digitBoxes[5].widthAnchor),

            // Center the taproot text and pin to the bottom
            taproot.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalTo: taproot.bottomAnchor, constant: 4),

            // Coinkite left to view and bottom to tapprot
            coinkite.bottomAnchor.constraint(equalTo: taproot.bottomAnchor),
            coinkite.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .closeSpacing)
        ])
    }

    required init?(coder: NSCoder) {
        preconditionFailure()
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: 172, height: 56)
    }

    private func updateDigits() {
        var blocks = self.blocks
        for digit in (0..<6).reversed() {
            digits[digit].image = Self.digitImages[Int(blocks % 10)]
            blocks /= 10
        }
    }
}
