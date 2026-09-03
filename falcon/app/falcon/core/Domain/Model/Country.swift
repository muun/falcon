//
//  Country.swift
//  falcon
//
//  Created by Federico Jordán on 06/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

struct Country: Equatable {
    let code: String
    let name: String
    let flag: String
}

extension Country {

    /// Fallback used when no country has been selected yet in onboarding / marketplace.
    static let `default` = Country(code: "AR", name: "Argentina", flag: "🇦🇷")

    static let all: [Country] = [
        Country(code: "AR", name: "Argentina", flag: "🇦🇷"),
        Country(code: "AU", name: "Australia", flag: "🇦🇺"),
        Country(code: "AT", name: "Austria", flag: "🇦🇹"),
        Country(code: "BE", name: "Belgium", flag: "🇧🇪"),
        Country(code: "BR", name: "Brazil", flag: "🇧🇷"),
        Country(code: "CA", name: "Canada", flag: "🇨🇦"),
        Country(code: "CL", name: "Chile", flag: "🇨🇱"),
        Country(code: "CO", name: "Colombia", flag: "🇨🇴"),
        Country(code: "CZ", name: "Czech Republic", flag: "🇨🇿"),
        Country(code: "FR", name: "France", flag: "🇫🇷"),
        Country(code: "DE", name: "Germany", flag: "🇩🇪"),
        Country(code: "HU", name: "Hungary", flag: "🇭🇺"),
        Country(code: "IT", name: "Italy", flag: "🇮🇹"),
        Country(code: "JP", name: "Japan", flag: "🇯🇵"),
        Country(code: "MX", name: "Mexico", flag: "🇲🇽"),
        Country(code: "NL", name: "Netherlands", flag: "🇳🇱"),
        Country(code: "NZ", name: "New Zealand", flag: "🇳🇿"),
        Country(code: "PL", name: "Poland", flag: "🇵🇱"),
        Country(code: "PT", name: "Portugal", flag: "🇵🇹"),
        Country(code: "RO", name: "Romania", flag: "🇷🇴"),
        Country(code: "SG", name: "Singapore", flag: "🇸🇬"),
        Country(code: "SK", name: "Slovakia", flag: "🇸🇰"),
        Country(code: "SI", name: "Slovenia", flag: "🇸🇮"),
        Country(code: "ES", name: "Spain", flag: "🇪🇸"),
        Country(code: "CH", name: "Switzerland", flag: "🇨🇭"),
        Country(code: "GB", name: "United Kingdom", flag: "🇬🇧"),
        Country(code: "US", name: "United States", flag: "🇺🇸"),
        Country(code: "KR", name: "South Korea", flag: "🇰🇷")
    ]

}
