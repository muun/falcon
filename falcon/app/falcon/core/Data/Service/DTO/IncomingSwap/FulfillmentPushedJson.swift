//
//  FulfillmentPushedJson.swift
//  Muun
//
//  Created by Daniel Mankowski on 15/11/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import Foundation

// Response from pushFulfillmentTransaction API call
struct FulfillmentPushedJson: Codable {
    let nextTransactionSize: NextTransactionSizeJson
    let feeBumpFunctions: FeeBumpFunctionsJson
}
