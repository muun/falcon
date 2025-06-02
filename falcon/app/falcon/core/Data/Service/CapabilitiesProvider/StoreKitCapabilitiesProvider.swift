//
//  StoreKitCapabilitiesProvider.swift
//
//  Created 16/04/2025.
//

import Foundation
import StoreKit

public class StoreKitCapabilitiesProvider {

    private var storeCountry: String = SignalConstants.empty

    public func start() {
        Task {
            let country = await self.getStorefrontCountryCode()
            self.storeCountry = country
        }
    }

    private func getStorefrontCountryCode() async -> String {
        if let storefront = await Storefront.current {
            return storefront.countryCode
        }
        return SignalConstants.unknown
    }

    public func getStoreCountry() -> String {
        return storeCountry
    }
}
