//
//  MinFeeRateRepository.swift
//  Created by Federico Bond on 30/03/2021.
//

import Foundation

class MinFeeRateRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func store(satsPerWeightUnit: Double) {
        self.preferences.set(object: satsPerWeightUnit, forKey: .minFeeRate)
    }

    func fetch() -> FeeRate {
        if let satsPerWeightUnit: Double = preferences.object(forKey: .minFeeRate) {
            return FeeRate(satsPerWeightUnit: Decimal(satsPerWeightUnit))
        }
        return Constant.FeeProtocol.minProtocolFeeRate
    }

}
