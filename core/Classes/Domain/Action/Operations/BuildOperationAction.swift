//
//  BuildSwapOperationAction.swift
//  core
//
//  Created by Juan Pablo Civile on 18/10/2019.
//

import Foundation

public class BuildOperationAction {

    public static func swap(_ submarineSwap: SubmarineSwap,
                            amount: BitcoinAmount,
                            fee: BitcoinAmount,
                            description: String,
                            exchangeRateWindow: ExchangeRateWindow,
                            outpoints: [String]?) -> Operation {

        // FIXME: We should check for the swaps validity here too

        return core.Operation(id: nil,
                              requestId: UUID().uuidString,
                              isExternal: true,
                              direction: .OUTGOING,
                              senderProfile: nil,
                              senderIsExternal: false,
                              receiverProfile: nil,
                              receiverIsExternal: true,
                              receiverAddress: submarineSwap._fundingOutput._outputAddress,
                              receiverAddressDerivationPath: nil,
                              amount: amount,
                              fee: fee,
                              confirmations: nil,
                              exchangeRatesWindowId: exchangeRateWindow.id,
                              description: description,
                              status: .CREATED,
                              transaction: nil,
                              creationDate: Date(),
                              submarineSwap: submarineSwap,
                              outpoints: outpoints)
    }

    public static func toAddress(_ address: String,
                                 amount: BitcoinAmount,
                                 fee: BitcoinAmount,
                                 description: String,
                                 exchangeRateWindow: ExchangeRateWindow,
                                 outpoints: [String]?) -> Operation {

        return core.Operation(
            id: nil,
            requestId: UUID().uuidString,
            isExternal: true,
            direction: .OUTGOING,
            senderProfile: nil,
            senderIsExternal: false,
            receiverProfile: nil,
            receiverIsExternal: true,
            receiverAddress: address,
            receiverAddressDerivationPath: nil,
            amount: amount,
            fee: fee,
            confirmations: nil,
            exchangeRatesWindowId: exchangeRateWindow.id,
            description: description,
            status: .CREATED,
            transaction: nil,
            creationDate: Date(),
            submarineSwap: nil,
            outpoints: outpoints
        )
    }

}
