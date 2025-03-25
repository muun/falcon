//
//  WalletFundingGroup.swift
//  Muun
//
//  Created by Lucas Serruya on 23/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//



class WalletFundingGroup: BaseDebugExecutablesGroup {
    init(addressActions: AddressActions,
         createInvoice: CreateInvoiceAction,
         userPreferencesSelector: UserPreferencesSelector) {
        let fundWallet =  FundWalletOnchainDebugExecutable(addressActions: addressActions)
        let fundWalletOffchain = FundWalletOffchainDebugExecutable(createInvoice: createInvoice,
                                                                   userPreferencesSelector: userPreferencesSelector)
        super.init(category: "Wallet Funding",
                   executables: [fundWallet,
                                 fundWalletOffchain])
    }
}
