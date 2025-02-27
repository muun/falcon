//
//  FundWalletOnchainDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//



class FundWalletOnchainDebugExecutable: DebugExecutable {
    private var addressActions: AddressActions

    init(addressActions: AddressActions) {
        self.addressActions = addressActions
    }

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        // swiftlint:disable force_error_handling
        let address = try? self.addressActions.generateExternalAddresses().segwit
        guard let address = address else {
            fatalError("Error generating address")
        }

        TestLapp.send(to: address, amount: 0.0005)
        completion()
    }

    func getTitleForCell() -> String {
        return "Fund wallet"
    }

}
