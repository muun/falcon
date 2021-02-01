//
//  NewOperationConfiguration.swift
//  falcon
//
//  Created by Manu Herrera on 29/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

struct NewOperationConfiguration {

    static func standard(paymentIntent: PaymentIntent,
                         origin: Constant.NewOpAnalytics.Origin) -> NewOperationConfiguration {
        return NewOperationConfiguration(
            errorButtonText: L10n.NewOperationConfiguration.s1,
            shouldDisplayBackButton: true,
            paymentIntent: paymentIntent,
            origin: origin)
    }

    var errorButtonText: String
    var shouldDisplayBackButton: Bool
    var paymentIntent: PaymentIntent
    var origin: Constant.NewOpAnalytics.Origin
}
