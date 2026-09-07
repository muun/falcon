//
//  OrderSummaryViewModel.swift
//  falcon
//
//  Created by Federico Jordán on 30/03/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

struct OrderSummaryViewModel {
    let providerColor: UIColor
    let providerUrl: URL?
    let securityCardImageName: String
    let shippingDetails: ShippingDetailsViewModel
    let breakdown: BreakdownViewModel
    let options: [DeliveryMethodOptionViewModel]

    var hasMultipleDeliverySpeeds: Bool { options.count > 1 }

    struct ShippingDetailsViewModel {
        let name: String
        let email: String
        let address: String
    }

    struct BreakdownViewModel {
        let price: String
        let shippingAndTaxes: String
        let total: String
    }
}

struct DeliveryMethodOptionViewModel {
    let speed: DeliveryOption.Speed
    let surcharge: Decimal
    let currencyCode: String
    let isSelected: Bool
    let providerColor: UIColor

    var costLabel: String {
        guard surcharge != 0 else { return L10n.DeliveryMethodPicker.free }
        let amount = MonetaryAmount(amount: surcharge, currency: currencyCode).toAmountPlusCode()
        return L10n.DeliveryMethodPicker.surcharge(amount)
    }

    var title: String {
        switch speed {
        case .standard: return L10n.DeliveryMethodPicker.standardShipping
        case .express: return L10n.DeliveryMethodPicker.expressShipping
        }
    }

    var eta: String {
        switch speed {
        case .standard: return L10n.DeliveryMethodPicker.standardEta
        case .express: return L10n.DeliveryMethodPicker.expressEta
        }
    }

    var borderColor: UIColor {
        isSelected ? providerColor : MuunTheme.Color.Border.primary
    }

    var backgroundColor: UIColor {
        isSelected ? providerColor.withAlphaComponent(0.05) : MuunTheme.Color.Surface.field
    }

    func withSelected(_ isSelected: Bool) -> DeliveryMethodOptionViewModel {
        DeliveryMethodOptionViewModel(
            speed: speed,
            surcharge: surcharge,
            currencyCode: currencyCode,
            isSelected: isSelected,
            providerColor: providerColor
        )
    }
}
