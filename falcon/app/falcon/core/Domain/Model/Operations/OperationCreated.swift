//
//  OperationCreatedJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct OperationCreated {

    let operation: Operation
    let partiallySignedTransaction: PartiallySignedTransaction
    let nextTransactionSize: NextTransactionSize
    let change: MuunAddress?

}
