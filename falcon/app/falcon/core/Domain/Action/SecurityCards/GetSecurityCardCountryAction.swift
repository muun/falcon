//
//  GetSecurityCardCountryAction.swift
//  falcon
//
//  Created by Federico Jordán on 29/05/2026.
//  Copyright © 2026 muun. All rights reserved.
//

final class GetSecurityCardCountryAction {

    private let marketplaceSelectedCountryRepository: MarketplaceSelectedCountryRepository

    init(marketplaceSelectedCountryRepository: MarketplaceSelectedCountryRepository) {
        self.marketplaceSelectedCountryRepository = marketplaceSelectedCountryRepository
    }

    /// Returns the country the user selected in the onboarding / marketplace,
    /// defaulting until a selection has been made.
    func run() -> Country {
        marketplaceSelectedCountryRepository.fetch()
    }
}
