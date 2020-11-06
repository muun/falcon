//
//  IncomingSwapDB.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/09/2020.
//

import Foundation
import GRDB

struct IncomingSwapDB: Codable, FetchableRecord, PersistableRecord {

    typealias PrimaryKeyType = String

    let uuid: String
    let paymentHashHex: String
    let sphinxPacketHex: String?

}

extension IncomingSwapDB: DatabaseModelConvertible {

    init(from: IncomingSwap) {
        self.uuid = from.uuid
        self.paymentHashHex = from.paymentHash.toHexString()
        self.sphinxPacketHex = from.sphinxPacket?.toHexString()
    }

    func to(using db: Database) throws -> IncomingSwap {

        let htlcs = try IncomingSwapHtlcDB
            .filter(Column("incomingSwapUuid") == uuid)
            .fetchAll(db)

        precondition(htlcs.count == 1)

        return IncomingSwap(
            uuid: uuid,
            paymentHash: Data(hex: paymentHashHex),
            htlc: try htlcs.first!.to(using: db),
            sphinxPacket: sphinxPacketHex.map(Data.init(hex: ))
        )
    }

}
