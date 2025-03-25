//
//  DatabaseCoordinator.swift
//  falcon
//
//  Created by Juan Pablo Civile on 14/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import GRDB
import Libwallet

// swiftlint:disable type_body_length
public class DatabaseCoordinator {

    public let queue: DatabaseQueue
    let preferences: Preferences
    let secureStorage: SecureStorage

    public init(queue: DatabaseQueue, preferences: Preferences, secureStorage: SecureStorage) throws {
        self.queue = queue
        self.preferences = preferences
        self.secureStorage = secureStorage

        do {
            try migrate()
        } catch {
            throw MuunError(error)
        }
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

        migrator.registerMigration("challenge keys format") { _ in

            let fixKey = { (keyType: SecureStorage.Keys) -> () in
                if try self.secureStorage.has(keyType) {
                    let publicKey = try self.secureStorage.get(keyType)
                    if publicKey.count > 33,
                        let stringyKey = String(data: Data(hex: publicKey), encoding: .utf8) {
                        try self.secureStorage.store(stringyKey, at: keyType)
                    }
                }
            }

            try fixKey(.passwordPublicKey)
            try fixKey(.recoveryCodePublicKey)
        }

        migrator.registerMigration("swaps v2") { db in
            try db.alter(table: "submarineSwapDB", body: { t in
                t.add(column: "scriptVersion", .numeric)
                    .defaults(to: 101)
                    .notNull()

                t.add(column: "userPublicKeyHex", .text)
                t.add(column: "userPublicKeyPath", .text)
                t.add(column: "muunPublicKeyHex", .text)
                t.add(column: "muunPublicKeyPath", .text)

                t.add(column: "expirationInBlocks", .numeric)
                    .defaults(to: 0)
            })
        }

        migrator.registerMigration("add debt to swap model") { db in
            try db.alter(table: "submarineSwapDB", body: { t in
                t.add(column: "outputDebtType", .text)
                    .defaults(to: DebtType.NONE.rawValue)
                    .notNull()

                t.add(column: "outputDebtAmount", .numeric)
                    .defaults(to: 0)
                    .notNull()
            })
        }

        // We need to store it there so the notification extension can access it
        migrator.registerMigration("move base key path to secure storage") { _ in
            if let path = self.preferences.string(forKey: .baseKeyDerivationPath) {
                do {
                    try self.secureStorage.store(path, at: .baseKeyDerivationPath)
                } catch {
                    Logger.log(error: error)
                }
            }
        }

        // Hardwire challenge key versions on secure storage
        migrator.registerMigration("challenge key version migration") { _ in
            do {

                if try self.secureStorage.has(.passwordPublicKey) {
                    try self.secureStorage.store("1", at: .passwordVersionKey)
                }

                if try self.secureStorage.has(.recoveryCodePublicKey) {
                    try self.secureStorage.store("1", at: .recoveryCodeVersionKey)
                }

            } catch {
                Logger.log(error: error)
            }
        }

        migrator.registerMigration("incoming swaps") { db in

            try db.create(table: "incomingSwapDB", body: { table in

                table.column("uuid", .text)
                    .notNull()
                    .primaryKey()

                table.column("paymentHashHex", .text)
                    .notNull()

                table.column("sphinxPacketHex", .text)
            })

            try db.create(table: "incomingSwapHtlcDB", body: { table in

                table.column("uuid", .text)
                    .notNull()
                    .primaryKey()

                table.column("incomingSwapUuid", .text)
                    .notNull()
                    .indexed()
                    .references("incomingSwapDB", column: "uuid", onDelete: .cascade)

                table.column("expirationHeight", .integer)
                    .notNull()

                table.column("paymentAmountInSats", .integer)
                    .notNull()

                table.column("fulfillmentFeeSubsidyInSats", .integer)
                    .notNull()

                table.column("lentInSats", .integer)
                    .notNull()

                table.column("outputAmountInSatoshis", .integer)
                    .notNull()

                table.column("address", .text)
                    .notNull()

                table.column("swapServerPublicKeyHex", .text)
                    .notNull()

                table.column("htlcTxHex", .text)
                    .notNull()

                table.column("fulfillmentTxHex", .text)
            })

            try db.alter(table: "operationDB") { table in
                table.add(column: "incomingSwapUuid", .text)
                    .references("incomingSwapDB", onDelete: .setNull)
            }
        }

        migrator.registerMigration("invoices without amount", migrate: { db in

            try db.create(table: "submarineSwapDBTmp", body: { t in
                t.column("swapUuid", .text).primaryKey()
                t.column("invoice", .text).notNull()

                t.column("sweepFee", .integer)
                t.column("lightningFee", .integer)

                t.column("expiredAt", .date).notNull()

                t.column("payedAt", .date)
                t.column("preimageInHex", .text)

                t.column("alias", .text)
                t.column("serializedNetworkAddresses", .text)
                t.column("publicKey", .text)

                t.column("outputAddress", .text).notNull()
                t.column("outputAmount", .integer)
                t.column("confirmationsNeeded", .integer)
                t.column("userLockTime", .integer).notNull()

                t.column("userRefundAddress", .text).notNull()
                t.column("userRefundAddressVersion", .integer).notNull()
                t.column("userRefundAddressPath", .text).notNull()

                t.column("serverPaymentHashInHex", .text).notNull()
                t.column("serverPublicKeyInHex", .text).notNull()

                t.column("willPreOpenChannel", .boolean)
                    .defaults(to: false)
                    .notNull()
                t.column("channelOpenFee", .integer)
                t.column("channelCloseFee", .integer)

                t.column("scriptVersion", .numeric)
                    .defaults(to: 101)
                    .notNull()

                t.column("userPublicKeyHex", .text)
                t.column("userPublicKeyPath", .text)
                t.column("muunPublicKeyHex", .text)
                t.column("muunPublicKeyPath", .text)

                t.column("expirationInBlocks", .numeric)
                    .defaults(to: 0)

                t.column("outputDebtType", .text)
                t.column("outputDebtAmount", .numeric)
            })

            try db.execute(sql: "INSERT INTO submarineSwapDBTmp SELECT * FROM submarineSwapDB;")
            try db.drop(table: "submarineSwapDB")
            try db.rename(table: "submarineSwapDBTmp", to: "submarineSwapDB")
        })

        migrator.registerMigration("update incoming swaps to allow collects") { db in

            // 1. Move paymentAmountInSats out of the HTLC to the incoming swap
            // 2. Add collectInSats to incoming swap

            try db.alter(table: "incomingSwapDB", body: { t in
                t.add(column: "paymentAmountInSats", .numeric)
                    .defaults(to: 0)
                    .notNull()

                t.add(column: "collectInSats", .numeric)
                    .defaults(to: 0)
                    .notNull()
            })

            try Row.fetchAll(db, sql: "SELECT incomingSwapUuid, paymentAmountInSats FROM incomingSwapHtlcDB")
                .forEach { row in
                    try db.execute(sql: """
                            UPDATE incomingSwapDb
                            SET paymentAmountInSats = :amount
                            WHERE uuid = :uuid
                         """, arguments: [
                            "amount": row["paymentAmountInSats"] as Int,
                            "uuid": row["incomingSwapUuid"] as String
                         ])
                }

            // Remove the paymentAmountInSats column from incomingSwapHtlcDB

            try db.create(table: "incomingSwapHtlcDBTmp", body: { table in

                table.column("uuid", .text)
                    .notNull()
                    .primaryKey()

                table.column("incomingSwapUuid", .text)
                    .notNull()
                    .indexed()
                    .references("incomingSwapDB", column: "uuid", onDelete: .cascade)

                table.column("expirationHeight", .integer)
                    .notNull()

                table.column("fulfillmentFeeSubsidyInSats", .integer)
                    .notNull()

                table.column("lentInSats", .integer)
                    .notNull()

                table.column("outputAmountInSatoshis", .integer)
                    .notNull()

                table.column("address", .text)
                    .notNull()

                table.column("swapServerPublicKeyHex", .text)
                    .notNull()

                table.column("htlcTxHex", .text)
                    .notNull()

                table.column("fulfillmentTxHex", .text)
            })

            try db.execute(sql: """
                        INSERT INTO incomingSwapHtlcDBTmp
                        SELECT
                            uuid,
                            incomingSwapUuid,
                            expirationHeight,
                            fulfillmentFeeSubsidyInSats,
                            lentInSats,
                            outputAmountInSatoshis,
                            address,
                            swapServerPublicKeyHex,
                            htlcTxHex,
                            fulfillmentTxHex
                        FROM incomingSwapHtlcDB
            """)

            try db.drop(table: "incomingSwapHtlcDB")

            try db.rename(table: "incomingSwapHtlcDBTmp", to: "incomingSwapHtlcDB")
        }

        migrator.registerMigration("add rbf column to operations db") { db in
            try db.alter(table: "operationDB", body: { t in
                t.add(column: "isReplaceableByFee", .boolean)
                    .defaults(to: false)
                    .notNull()
            })
        }

        migrator.registerMigration("add preimage to incoming swaps") { db in
            try db.alter(table: "incomingSwapDB", body: { t in
                t.add(column: "preimageHex", .text)
            })
        }

        migrator.registerMigration("add metadata to operation") { db in
            try db.alter(table: "operationDB", body: { t in
                t.add(column: "metadata", .text)
            })
        }

        migrator.registerMigration("create exported ek in user") { [self] _ in
            let user: User? = preferences.object(forKey: .user)
            guard var user = user  else {
                return
            }

            if let exportDate = user.emergencyKitLastExportedDate {
                let code: String

                if let codes = preferences.array(forKey: .emergencyKitVerificationCodes) as? [String],
                   let lastCode = codes.last {
                    code = lastCode
                } else {
                    // Default to an empty code if we can't find it
                    code = ""
                }

                let version = Int(LibwalletEKVersionDescriptors)
                user.emergencyKit = ExportEmergencyKit(
                    lastExportedAt: exportDate,
                    verificationCode: code,
                    verified: true,
                    version: version,
                    method: nil
                )
                user.exportedKitVersions = [version]

                preferences.set(object: user, forKey: .user)
            }
        }

        migrator.registerMigration("fix .hasRecoveryCode") { [self] _ in
            let user: User? = preferences.object(forKey: .user)
            guard let user = user else {
                return
            }

            if user.hasRecoveryCodeChallengeKey {
                preferences.set(value: true, forKey: .hasRecoveryCode)
            }
        }

        // Migration to init utxo status for pre-existing sizeForAmounts. Will be properly
        // initialized after first NTS refresh (e.g first newOperation, incoming operation, or any
        // operationUpdate).
        // NOTE: we're choosing to init status as CONFIRMED as this field won't be used right away and
        // for our intended first use CONFIRMED will be handled gracefully as "ignorable".
        migrator.registerMigration("init NTS utxoStatus") { [self] _ in
            let nts: NextTransactionSize? = preferences.object(forKey: .nextTransactionSize)
            guard let nts = nts else {
                return
            }

            let updatedNts = nts.initUtxoStatus()
            preferences.set(object: updatedNts, forKey: .nextTransactionSize)
        }

        return migrator
    }
    // swiftlint:enable function_body_length

    func wipeAll() throws {
        try queue.erase()
        try migrate()
    }

}
