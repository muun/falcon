//
//  MarketplaceSelectedCountryRepository.swift
//  falcon
//
//  Created by Federico Jordán on 26/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import Foundation

/// In-memory store for the country selected in the security cards flow
/// (marketplace, shipping). It lives for the app session and is not persisted.
/// Registered as a singleton so a write from one screen is visible to the others.
final class MarketplaceSelectedCountryRepository {

    private var selectedCountry: Country = .default

    func set(_ country: Country) {
        selectedCountry = country
    }

    func fetch() -> Country {
        selectedCountry
    }
}
