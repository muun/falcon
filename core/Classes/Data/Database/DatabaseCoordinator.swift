//
//  DatabaseCoordinator.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import GRDB

public class DatabaseCoordinator {

    public let queue: DatabaseQueue
    let preferences: Preferences

    public init(url: URL, preferences: Preferences) throws {
        self.queue = try DatabaseQueue(path: url.path)
        self.preferences = preferences

        try migrate()
    }

    private func migrate() throws {
        try buildSchema().migrate(queue)
    }

    // swiftlint:disable function_body_length
    private func buildSchema() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // This is commented due a possible bug in the GRDB implementation
        // TODO: Follow up this and check it is in fact a bug in the implementation or a falcon bug
//        #if DEBUG
//            migrator.eraseDatabaseOnSchemaChange = true
//        #endif

        migrator.registerMigration("operations") { db in
            try db.create(table: "publicProfileDB", body: { t in
                t.column("id", .integer).primaryKey()
                t.column("firstName", .text).notNull()
                t.column("lastName", .text).notNull()
                t.column("profilePictureUrl", .text)
            })

            try db.create(table: "operationDB", body: { t in
                t.column("id", .integer).primaryKey()
                t.column("direction", .text).notNull()
                t.column("isExternal", .boolean).notNull()

                t.column("senderProfileId", .integer)
                    .references("publicProfileDB", onDelete: .setNull)
                t.column("senderIsExternal", .boolean).notNull()

                t.column("receiverProfileId", .integer)
                    .references("publicProfileDB", onDelete: .setNull)
                t.column("receiverIsExternal", .boolean).notNull()
                t.column("receiverAddress", .text)
                t.column("receiverAddressDerivationPath", .text)

                t.column("amountInSatoshis", .integer).notNull()
                t.column("amountInPrimaryCurrency", .text).notNull()
                t.column("amountPrimaryCurrency", .text).notNull()
                t.column("amountInInputCurrency", .text).notNull()
                t.column("amountInputCurrency", .text).notNull()

                t.column("feeInSatoshis", .integer).notNull()
                t.column("feeInPrimaryCurrency", .text).notNull()
                t.column("feePrimaryCurrency", .text).notNull()
                t.column("feeInInputCurrency", .text).notNull()
                t.column("feeInputCurrency", .text).notNull()

                t.column("confirmations", .integer)
                t.column("hashDB", .text)
                t.column("descriptionDB", .text)
                t.column("status", .text).notNull()
                t.column("creationDate", .date).notNull()
                t.column("exchangeRateWindowHid", .integer).notNull()

            })
        }

        migrator.registerMigration("swaps") { db in

            try db.create(table: "submarineSwapDB", body: { t in
                t.column("swapUuid", .text).primaryKey()
                t.column("invoice", .text).notNull()

                t.column("sweepFee", .integer).notNull()
                t.column("lightningFee", .integer).notNull()

                t.column("expiredAt", .date).notNull()

                t.column("payedAt", .date)
                t.column("preimageInHex", .text)

                t.column("alias", .text)
                t.column("serializedNetworkAddresses", .text)
                t.column("publicKey", .text)

                t.column("outputAddress", .text).notNull()
                t.column("outputAmount", .integer).notNull()
                t.column("confirmationsNeeded", .integer).notNull()
                t.column("userLockTime", .integer).notNull()

                t.column("userRefundAddress", .text).notNull()
                t.column("userRefundAddressVersion", .integer).notNull()
                t.column("userRefundAddressPath", .text).notNull()

                t.column("serverPaymentHashInHex", .text).notNull()
                t.column("serverPublicKeyInHex", .text).notNull()
            })

            try db.alter(table: "operationDB", body: { t in
                t.add(column: "swapUuid", .text)
                    .references("submarineSwapDB", onDelete: .setNull)

            })
        }

        migrator.registerMigration("targetedFees") { _ in
            self.preferences.remove(key: .feeWindow)
        }

        migrator.registerMigration("top_ups") { db in
            try db.alter(table: "submarineSwapDB", body: { t in
                t.add(column: "willPreOpenChannel", .boolean)
                    .defaults(to: false)
                    .notNull()
                t.add(column: "channelOpenFee", .integer)
                    .defaults(to: 0)
                    .notNull()
                t.add(column: "channelCloseFee", .integer)
                    .defaults(to: 0)
                    .notNull()
            })
        }

        return migrator
    }
    // swiftlint:enable function_body_length

    func wipeAll() throws {
        try queue.erase()
        try migrate()
    }

}
