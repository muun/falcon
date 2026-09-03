//
//  BuyDetailsViewModel.swift
//  falcon
//
//  Created by Federico Jordán on 02/06/2026.
//  Copyright © 2026 muun. All rights reserved.
//

import UIKit

struct BuyDetailsViewModel {
    let title: String
    let description: String
    let providerColor: UIColor
    let imageName: String
    let material: SecurityCardMaterial
    let shipsFrom: String
    let deliveryDays: String
    let priceViewModel: SecurityCardFullPriceView.ViewModel
    let ctaTitle: String
}
