//
//  ReceiveAddressTypeSelectPresenter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 22/10/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import core
import Libwallet

struct AddressTypeOption {
    let type: AddressType
    let enabled: Bool
    let blocksLeft: UInt

    init(type: AddressType, enabled: Bool, blocksLeft: UInt = 0) {
        self.type = type
        self.enabled = enabled
        self.blocksLeft = blocksLeft
    }
}

class ReceiveAddressTypeSelectPresenter<Delegate: BasePresenterDelegate>: BasePresenter<Delegate> {

    private let userActivatedFeatureSelector: UserActivatedFeaturesSelector
    private let blockheightRepository: BlockchainHeightRepository

    init(delegate: Delegate,
         userActivatedFeatureSelector: UserActivatedFeaturesSelector,
         blockheightRepository: BlockchainHeightRepository
    ) {
        self.userActivatedFeatureSelector = userActivatedFeatureSelector
        self.blockheightRepository = blockheightRepository
        super.init(delegate: delegate)
    }

    func addressTypes() -> [AddressTypeOption] {
        var types = [
            AddressTypeOption(type: .legacy, enabled: true),
            AddressTypeOption(type: .segwit, enabled: true)
        ]
        
        let taprootStatus = userActivatedFeatureSelector.get(for: Libwallet.userActivatedFeatureTaproot()!)
        switch taprootStatus {
        case .active:
            types.append(AddressTypeOption(type: .taproot, enabled: true))
        case .preactivated(let blocksLeft),
             .scheduledActivation(let blocksLeft):
            types.append(AddressTypeOption(type: .taproot, enabled: false, blocksLeft: blocksLeft))
        case .off, .canActivate, .canPreactivate:
            // Nothing to show
            ()
        }

        return types
    }
}
