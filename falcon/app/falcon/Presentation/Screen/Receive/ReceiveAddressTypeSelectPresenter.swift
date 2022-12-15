//
//  AddressTypeOptionsRetriever.swift
//  falcon
//
//  Created by Juan Pablo Civile on 22/10/2021.
//  Copyright © 2021 muun. All rights reserved.
//

import Foundation
import core
import Libwallet

class AddressTypeOptionsRetriever {

    private let userActivatedFeatureSelector: UserActivatedFeaturesSelector
    private let blockheightRepository: BlockchainHeightRepository

    init(userActivatedFeatureSelector: UserActivatedFeaturesSelector,
         blockheightRepository: BlockchainHeightRepository
    ) {
        self.userActivatedFeatureSelector = userActivatedFeatureSelector
        self.blockheightRepository = blockheightRepository
    }

    private func getStatus(selectedOption: any MUActionSheetOption,
                           enabled: Bool,
                           type: AddressTypeViewModel) -> MUActionSheetCard.Status {
        guard let addressType = selectedOption as? AddressTypeViewModel else {
            let optionName = selectedOption.name
            Logger.fatal("receive actionSheet is working with something that is not an AddressViewModel \(optionName)")
        }

        if addressType == type {
            return .selected
        }

        return enabled ? .enabled : .disabled
    }
}

extension AddressTypeOptionsRetriever {
    func run(selectedOption: any MUActionSheetOption) -> [MUActionSheetOptionViewModel] {
        var types = [
            MUActionSheetOptionViewModel(type: AddressTypeViewModel.legacy,
                              status: getStatus(selectedOption: selectedOption,
                                                enabled: true,
                                                type: .legacy),
                             highlight: nil),
            MUActionSheetOptionViewModel(type: AddressTypeViewModel.segwit,
                              status: getStatus(selectedOption: selectedOption,
                                                enabled: true,
                                                type: .segwit),
                             highlight: nil)
        ]

        let taprootStatus = userActivatedFeatureSelector.get(for: Libwallet.userActivatedFeatureTaproot()!)
        switch taprootStatus {
        case .active:
            types.append(MUActionSheetOptionViewModel(type: AddressTypeViewModel.taproot,
                                           status: getStatus(selectedOption: selectedOption,
                                                             enabled: true,
                                                             type: .taproot),
                                          highlight: nil))
        case .preactivated(let blocksLeft), // TODO: This code is not needed anymore
             .scheduledActivation(let blocksLeft):
            types.append(MUActionSheetOptionViewModel(type: AddressTypeViewModel.taproot,
                                           status: getStatus(selectedOption: selectedOption,
                                                             enabled: false,
                                                             type: .taproot),
                                           highlight: nil,
                                           blocksLeft: blocksLeft))
        case .off, .canActivate, .canPreactivate:
            // Nothing to show
            ()
        }

        return types
    }
}
