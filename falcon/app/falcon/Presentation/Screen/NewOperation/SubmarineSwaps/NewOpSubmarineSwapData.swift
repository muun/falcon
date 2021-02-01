//
//  NewOpSubmarineSwapData.swift
//  falcon
//
//  Created by Manu Herrera on 14/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

enum NewOpSubmarineSwapData {

    struct Loading: NewOperationStateDelegate {
        let type: PaymentIntent
    }

    struct Amount: NewOperationStateLoaded {
        let feeInfo: FeeInfo
        let user: User
        let flow: FlowSubmarineSwap

        var type: PaymentRequestType {
            return flow
        }
    }

    struct Description: NewOperationStateAmount {
        let feeInfo: FeeInfo
        let user: User

        let amount: BitcoinAmount
        let flow: FlowSubmarineSwap
        let fee: BitcoinAmount
        let feeState: FeeState

        let params: SwapExecutionParameters

        var type: PaymentRequestType {
            return flow
        }
    }

    struct Confirm: NewOperationStateAmount {
        let feeInfo: FeeInfo
        let user: User

        let request: PaymentRequest
        let fee: BitcoinAmount
        let feeState: FeeState

        let params: SwapExecutionParameters

        var amount: BitcoinAmount {
            return request.amount
        }

        var description: String {
            return request.description
        }

        var type: PaymentRequestType {
            return request.type
        }

        func getFlowData() -> FlowSubmarineSwap {
            if let swapFlow = type as? FlowSubmarineSwap {
                return swapFlow
            }
            fatalError("Not swap flow")
        }
    }
}

extension NewOpSubmarineSwapData.Confirm {

    func onChainFee() -> BitcoinAmount {
        return fee
    }

    func sweepFee() -> BitcoinAmount {
        return toBitcoinAmount(satoshis: params.sweepFee)
    }

    func routingFee() -> BitcoinAmount {
        return toBitcoinAmount(satoshis: params.routingFee)
    }

    func lightningFee() -> BitcoinAmount {
        switch params.debtType {
        case .NONE, .COLLECT:
            return toBitcoinAmount(satoshis: fee.inSatoshis + params.offchainFee)
        case .LEND:
            return toBitcoinAmount(satoshis: params.routingFee)
        }
    }

}
