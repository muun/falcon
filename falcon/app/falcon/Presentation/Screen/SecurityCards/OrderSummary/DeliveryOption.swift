//
//  DeliveryOption.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

struct DeliveryOption {
    enum Speed {
        case standard
        case express
    }

    let speed: Speed
    /// Surcharge over the card price, in the provider's currency. 0 means free.
    let surcharge: Decimal
}
