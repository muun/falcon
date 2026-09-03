//
//  PayWithMuunViewModel.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

struct PayWithMuunViewModel {
    let providerName: String
    let breakdown: BreakdownViewModel

    struct BreakdownViewModel {
        let amount: String
        let networkFee: String
        let total: String
    }
}
