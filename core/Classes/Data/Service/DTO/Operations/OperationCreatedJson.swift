//
//  OperationCreatedJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

struct OperationCreatedJson: Codable {

    let operation: OperationJson
    let partiallySignedTransaction: PartiallySignedTransactionJson
    let nextTransactionSize: NextTransactionSizeJson
    let changeAddress: MuunAddressJson?

}
