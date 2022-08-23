//
//  MonetaryAmount.swift
//  falcon
//
//  Created by Manu Herrera on 03/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

public struct MonetaryAmount {
    public let amount: Decimal
    public let currency: String

    public init(amount: Decimal, currency: String) {
        self.amount = amount
        self.currency = currency
    }

    public init?(amount: String, currency: String) {
        guard let amount = Decimal(string: amount, locale: Locale.init(identifier: "en_US")) else {
            return nil
        }

        self.init(amount: amount, currency: currency)
    }

}
