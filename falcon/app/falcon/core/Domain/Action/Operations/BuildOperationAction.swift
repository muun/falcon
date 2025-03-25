//
//  BuildSwapOperationAction.swift
//
//  Created by Juan Pablo Civile on 18/10/2019.
//

import Foundation
import Libwallet

public class BuildOperationAction {

    public static func swap(_ submarineSwap: SubmarineSwap,
                            amount: BitcoinAmount,
                            fee: BitcoinAmount,
                            description: String,
                            exchangeRateWindow: NewopExchangeRateWindow,
                            outpoints: [String]?) -> Operation {

        // FIXME: We should check for the swaps validity here too

        return Operation(id: nil,
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
                              exchangeRatesWindowId: exchangeRateWindow.windowId,
                              description: description,
                              status: .CREATED,
                              transaction: nil,
                              creationDate: Date(),
                              submarineSwap: submarineSwap,
                              outpoints: outpoints,
                              incomingSwap: nil,
                              metadata: OperationMetadataJson(description: description))
    }

    public static func toAddress(_ address: String,
                                 amount: BitcoinAmount,
                                 fee: BitcoinAmount,
                                 description: String,
                                 exchangeRateWindow: NewopExchangeRateWindow,
                                 outpoints: [String]?) -> Operation {

        return Operation(
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
            exchangeRatesWindowId: exchangeRateWindow.windowId  ,
            description: description,
            status: .CREATED,
            transaction: nil,
            creationDate: Date(),
            submarineSwap: nil,
            outpoints: outpoints,
            incomingSwap: nil,
            metadata: OperationMetadataJson(description: description)
        )
    }

}
