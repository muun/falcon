//
//  NewOpToAddressData.swift
//  falcon
//
//  Created by Manu Herrera on 14/10/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import core

enum NewOpToAddressData {

    struct Loading: NewOperationStateDelegate {
        let type: PaymentIntent
    }

    struct Amount: NewOperationStateLoaded {
        let feeInfo: FeeInfo

        let type: PaymentRequestType
        let user: User
    }

    struct Description: NewOperationStateAmount {
        let feeInfo: FeeInfo

        let amount: BitcoinAmount
        let type: PaymentRequestType
        let user: User
    }

    struct Confirm: NewOperationStateAmount {
        let feeInfo: FeeInfo

        let request: PaymentRequest
        let feeState: FeeState
        let takeFeeFromAmount: Bool
        let user: User

        var amount: BitcoinAmount {
            return request.amount
        }

        var description: String {
            return request.description
        }

        var type: PaymentRequestType {
            return request.type
        }
    }

}
