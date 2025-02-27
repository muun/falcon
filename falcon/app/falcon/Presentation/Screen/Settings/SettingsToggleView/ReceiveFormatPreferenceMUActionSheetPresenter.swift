//
//  ReceiveFormatActionSheetPresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 22/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation

import Libwallet

class ReceiveFormatOptionsRetriever {
    static func run(selectedOption: any MUActionSheetOption) -> [MUActionSheetOptionViewModel] {
        let types = [
            MUActionSheetOptionViewModel(type: ReceiveFormatPreferenceViewModel.ONCHAIN,
                              status: getStatus(selectedOption: selectedOption,
                                                enabled: true,
                                                type: .ONCHAIN),
                             highlight: nil),
            MUActionSheetOptionViewModel(type: ReceiveFormatPreferenceViewModel.LIGHTNING,
                              status: getStatus(selectedOption: selectedOption,
                                                enabled: true,
                                                type: .LIGHTNING),
                             highlight: nil),
            MUActionSheetOptionViewModel(type: ReceiveFormatPreferenceViewModel.UNIFIED,
                              status: getStatus(selectedOption: selectedOption,
                                                enabled: true,
                                                type: .UNIFIED),
                             highlight: nil)
        ]

        return types
    }

    private static func getStatus(selectedOption: any MUActionSheetOption,
                                  enabled: Bool,
                                  type: ReceiveFormatPreferenceViewModel) -> MUActionSheetCard.Status {
        guard let receiveFormatVM = selectedOption as? ReceiveFormatPreferenceViewModel else {
            let optionName = selectedOption.name
            Logger.fatal("receive format is working with something that is not an ReceiveFormatVM \(optionName)")
        }

        if receiveFormatVM == type {
            return .selected
        }

        return enabled ? .enabled : .disabled
    }
}
