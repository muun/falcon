//
//  FundWalletOffchainDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 17/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation


class FundWalletOffchainDebugExecutable: DebugExecutable {
    private var createInvoice: CreateInvoiceAction
    private var userPreferencesSelector: UserPreferencesSelector

    init(createInvoice: CreateInvoiceAction,
         userPreferencesSelector: UserPreferencesSelector) {
        self.createInvoice = createInvoice
        self.userPreferencesSelector = userPreferencesSelector
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        // swiftlint:disable force_error_handling
        guard let invoice = try? createInvoice.run(amount: nil)
            .toBlocking().first() else {
            fatalError()
        }
        // swiftlint:disable force_error_handling
        let preferences = try? userPreferencesSelector.get()
            .toBlocking()
            .single()

        TestLapp.payWithLapp(invoice: invoice,
                             amountInSats: 11000,
                             turboChannelsEnabled: preferences!.receiveStrictMode) {
            completion()
        }
    }

    func getTitleForCell() -> String {
        return "Fund wallet offchain"
    }
}
