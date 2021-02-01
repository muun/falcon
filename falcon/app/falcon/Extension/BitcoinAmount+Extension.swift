//
//  BitcoinAmount+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 10/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit
import core

extension BitcoinAmount {

    func attributedString(with font: UIFont) -> NSAttributedString {
        var finalString = ""
        finalString = self.inSatoshis.toBTC().toAttributedString(with: font).string

        if self.inPrimaryCurrency.currency != "BTC" {
            finalString.append(contentsOf:
                " (\(self.inPrimaryCurrency.toAttributedString(with: font).string))"
            )
        }

        return NSAttributedString(string: finalString)
    }

}
