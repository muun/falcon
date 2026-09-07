//
//  SecurityCardProviderMockData.swift
//  falcon
//
//  Created by Federico Jordán on 20/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//
// TODO: migrate to libwallet

import UIKit

enum SecurityCardMaterial: String {
    case metal
    case plastic

    var displayName: String {
        rawValue.capitalized
    }
}

struct SecurityCardProviderExtraInfo {
    let description: String
    let material: SecurityCardMaterial
    let shipsFrom: String
    let deliveryDays: String
    let url: URL?
    let thickness: String
    let weight: String
    let heightMm: String
    let widthMm: String
    let secureElement: String?
    let dataWipingText: String?
    let firmwareURL: URL?

    static func mock(for provider: SecurityCardProvider) -> SecurityCardProviderExtraInfo {
        switch provider.name {
        case "Constellations": return .constellations
        case "Numbers": return .numbers
        case "Planets": return .planets
        default: return .fallback
        }
    }

    private enum Constants {
        static let muunGitHub = URL(string: "https://github.com/muun")
        static let muunHome = URL(string: "https://muun.com")
    }

    private enum Symbols {
        static let material = "creditcard.fill"
        static let thickness = "ruler"
        static let weight = "scalemass"
        static let firmware = "chevron.left.forwardslash.chevron.right"
        static let packaging = "shippingbox"
        static let secureElement = "checkmark.shield"
        static let dataWiping = "trash.circle"
        static let soldShippedBy = "shippingbox"
        static let shipsFrom = "mappin"
        static let deliversIn = "clock"
    }

    func specSections(
        providerName: String,
        color: UIColor
    ) -> [SecurityCardSpecsListView.ViewModel] {
        typealias SpecItem = SecurityCardSpecsListView.SpecItemViewModel
        let strings = L10n.SecurityCardFullSpecsViewController.self

        let specifications: [SpecItem?] = [
            SpecItem(
                symbol: Symbols.material,
                label: strings.material,
                value: material.displayName,
                additionalHTMLData: nil
            ),
            SpecItem(
                symbol: Symbols.thickness,
                label: strings.thickness,
                value: strings.mmFormat(thickness),
                additionalHTMLData: nil
            ),
            SpecItem(
                symbol: Symbols.weight,
                label: strings.weight,
                value: strings.weightFormat(weight),
                additionalHTMLData: nil
            )
        ]

        let security: [SpecItem?] = [
            SpecItem(
                symbol: Symbols.firmware,
                label: strings.firmware,
                value: strings.firmwareOpenSource,
                additionalHTMLData: firmwareURL.map {
                    strings.firmwareInfoHTMLFormat($0.absoluteString)
                }
            ),
            SpecItem(
                symbol: Symbols.packaging,
                label: strings.packaging,
                value: strings.packagingTamperResistant,
                additionalHTMLData: nil
            ),
            secureElement.map { SpecItem(
                symbol: Symbols.secureElement,
                label: strings.secureElement,
                value: $0,
                additionalHTMLData: nil
            ) },
            dataWipingText.map { SpecItem(
                symbol: Symbols.dataWiping,
                label: strings.dataWiping,
                value: $0,
                additionalHTMLData: nil
            ) }
        ]

        let delivery: [SpecItem?] = [
            SpecItem(
                symbol: Symbols.soldShippedBy,
                label: strings.soldShippedBy,
                value: providerName,
                additionalHTMLData: nil
            ),
            SpecItem(
                symbol: Symbols.shipsFrom,
                label: strings.shipsFrom,
                value: shipsFrom,
                additionalHTMLData: nil
            ),
            SpecItem(
                symbol: Symbols.deliversIn,
                label: strings.deliversIn,
                value: deliveryDays,
                additionalHTMLData: nil
            )
        ]

        return [
            .init(
                title: strings.specifications,
                rows: specifications.compactMap { $0 },
                providerColor: color
            ),
            .init(
                title: strings.security,
                rows: security.compactMap { $0 },
                providerColor: color
            ),
            .init(
                title: strings.delivery,
                rows: delivery.compactMap { $0 },
                providerColor: color
            )
        ]
    }

    private static let constellations = SecurityCardProviderExtraInfo(
        description: "their cards celebrate the stars with a collector-grade finish",
        material: .metal,
        shipsFrom: "Argentina",
        deliveryDays: "7–14 days",
        url: Constants.muunHome,
        thickness: "0.8",
        weight: "5",
        heightMm: "54",
        widthMm: "85.6",
        secureElement: nil,
        dataWipingText: "After 90 days",
        firmwareURL: Constants.muunGitHub
    )

    private static let numbers = SecurityCardProviderExtraInfo(
        description: "their minimalist design keeps focus on what matters: your keys",
        material: .plastic,
        shipsFrom: "Argentina",
        deliveryDays: "5–10 days",
        url: Constants.muunHome,
        thickness: "0.8",
        weight: "5",
        heightMm: "54",
        widthMm: "85.6",
        secureElement: nil,
        dataWipingText: nil,
        firmwareURL: Constants.muunGitHub
    )

    private static let planets = SecurityCardProviderExtraInfo(
        description: "their cards feature planetary illustrations on durable plastic",
        material: .plastic,
        shipsFrom: "Argentina",
        deliveryDays: "10–21 days",
        url: Constants.muunHome,
        thickness: "1.2",
        weight: "10",
        heightMm: "54",
        widthMm: "85.6",
        secureElement: "EAL 6+",
        dataWipingText: "After 180 days",
        firmwareURL: Constants.muunGitHub
    )

    private static let fallback = SecurityCardProviderExtraInfo(
        description: "a trusted hardware security provider",
        material: .plastic,
        shipsFrom: "Unknown",
        deliveryDays: "7–21 days",
        url: nil,
        thickness: "0.8",
        weight: "5",
        heightMm: "54",
        widthMm: "85.6",
        secureElement: nil,
        dataWipingText: nil,
        firmwareURL: nil
    )
}
