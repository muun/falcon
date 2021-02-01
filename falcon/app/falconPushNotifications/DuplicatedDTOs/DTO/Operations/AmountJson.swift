//
//  Amount.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

// This is public for the operation extension
public struct BitcoinAmountJson: Codable {
    let inSatoshis: Int64
    public let inInputCurrency: MonetaryAmountJson
    let inPrimaryCurrency: MonetaryAmountJson
}

// This is public for the operation extension
public struct MonetaryAmountJson: Codable {
    public let amount: String
    public let currency: String

    init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currency = try container.decode(String.self, forKey: .currency)
        if let value = try? container.decode(String.self, forKey: .amount) {
            amount = value
        } else {
            amount = String(try container.decode(Double.self, forKey: .amount))
        }
    }
}
