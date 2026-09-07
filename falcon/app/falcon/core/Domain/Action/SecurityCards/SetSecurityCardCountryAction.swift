//
//  SetSecurityCardCountryAction.swift
//  falcon
//
//  Created by Federico Jordán on 17/07/2026.
//  Copyright © 2026 muun. All rights reserved.
//

final class SetSecurityCardCountryAction {

    private let marketplaceSelectedCountryRepository: MarketplaceSelectedCountryRepository

    init(marketplaceSelectedCountryRepository: MarketplaceSelectedCountryRepository) {
        self.marketplaceSelectedCountryRepository = marketplaceSelectedCountryRepository
    }

    /// Records the country as the shared security cards selection so the screens
    /// in the flow (marketplace, shipping) stay in sync.
    func run(_ country: Country) {
        marketplaceSelectedCountryRepository.set(country)
    }
}
