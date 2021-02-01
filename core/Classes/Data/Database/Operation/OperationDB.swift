//
//  OperationDB.swift
//  falcon
//
//  Created by Manu Herrera on 07/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import GRDB

struct OperationDB: Codable, FetchableRecord, PersistableRecord {

    typealias PrimaryKeyType = Int

    static let senderProfileKey = ForeignKey(["senderProfile"])
    static let receiverProfileKey = ForeignKey(["receiverProfile"])
    static let submarineSwapKey = ForeignKey(["swapUuid"], to: ["swapUuid"])
    static let incomingSwapKey = ForeignKey(["uuid"], to: ["incomingSwapUuid"])

    static let senderProfile = hasOne(PublicProfileDB.self, key: "senderProfileId", using: senderProfileKey)
    static let receiverProfile = hasOne(PublicProfileDB.self, key: "receiverProfileId", using: receiverProfileKey)
    static let submarineSwap = hasOne(SubmarineSwapDB.self, key: "swapUuid", using: submarineSwapKey)
    static let incomingSwap = hasOne(IncomingSwapDB.self, key: "incomingSwapUuid", using: incomingSwapKey)

    let id: Int
    let direction: OperationDirection
    let isExternal: Bool

    let senderProfileId: Int?
    let senderIsExternal: Bool

    let receiverProfileId: Int?
    let receiverIsExternal: Bool
    let receiverAddress: String?
    let receiverAddressDerivationPath: String?

    let amountInSatoshis: Int64
    let amountInPrimaryCurrency: String
    let amountPrimaryCurrency: String
    let amountInInputCurrency: String
    let amountInputCurrency: String

    let feeInSatoshis: Int64
    let feeInPrimaryCurrency: String
    let feePrimaryCurrency: String
    let feeInInputCurrency: String
    let feeInputCurrency: String

    let confirmations: Int?
    let isReplaceableByFee: Bool
    let hashDB: String? // Cant use the key: hash
    let descriptionDB: String? // Cant use the key: description
    let status: OperationStatus
    let creationDate: Date
    let exchangeRateWindowHid: Int

    let swapUuid: String?
    let incomingSwapUuid: String?
}

extension OperationDB: DatabaseModelConvertible {

    init(from: Operation) {
        precondition(from.id != nil, "Operation must have an id to be stored")

        self.init(id: from.id!,
                  direction: from.direction,
                  isExternal: from.isExternal,
                  senderProfileId: from.senderProfile?.userId,
                  senderIsExternal: from.senderIsExternal,
                  receiverProfileId: from.receiverProfile?.userId,
                  receiverIsExternal: from.receiverIsExternal,
                  receiverAddress: from.receiverAddress,
                  receiverAddressDerivationPath: from.receiverAddressDerivationPath,
                  amountInSatoshis: from.amount.inSatoshis.value,
                  amountInPrimaryCurrency: from.amount.inPrimaryCurrency.amount
                    .stringValue(locale: Constant.houstonLocale),
                  amountPrimaryCurrency: from.amount.inPrimaryCurrency.currency,
                  amountInInputCurrency: from.amount.inInputCurrency.amount.stringValue(locale: Constant.houstonLocale),
                  amountInputCurrency: from.amount.inInputCurrency.currency,
                  feeInSatoshis: from.fee.inSatoshis.value,
                  feeInPrimaryCurrency: from.fee.inPrimaryCurrency.amount.stringValue(locale: Constant.houstonLocale),
                  feePrimaryCurrency: from.fee.inPrimaryCurrency.currency,
                  feeInInputCurrency: from.fee.inInputCurrency.amount.stringValue(locale: Constant.houstonLocale),
                  feeInputCurrency: from.fee.inInputCurrency.currency,
                  confirmations: from.confirmations,
                  isReplaceableByFee: from.transaction?.isReplaceableByFee ?? false,
                  hashDB: from.transaction?.hash,
                  descriptionDB: from.description,
                  status: from.status,
                  creationDate: from.creationDate,
                  exchangeRateWindowHid: from.exchangeRatesWindowId,
                  swapUuid: from.submarineSwap?._swapUuid,
                  incomingSwapUuid: from.incomingSwap?.uuid)

    }

    // swiftlint:disable function_body_length
    func to(using db: Database) throws -> Operation {

        let btcAmount = BitcoinAmount(
            inSatoshis: Satoshis(value: amountInSatoshis),
            inInputCurrency: MonetaryAmount(amount: amountInInputCurrency,
                                            currency: amountInputCurrency)!,
            inPrimaryCurrency: MonetaryAmount(amount: amountInPrimaryCurrency,
                                              currency: amountPrimaryCurrency)!
        )
        let feeAmount = BitcoinAmount(
            inSatoshis: Satoshis(value: feeInSatoshis),
            inInputCurrency: MonetaryAmount(amount: feeInInputCurrency,
                                            currency: feeInputCurrency)!,
            inPrimaryCurrency: MonetaryAmount(amount: feeInPrimaryCurrency,
                                              currency: feePrimaryCurrency)!
        )

        var senProfile: PublicProfile?
        if let senderProfileId = senderProfileId {
            senProfile = try PublicProfileDB.fetchOne(db, key: senderProfileId)?.to(using: db)
        }

        var recProfile: PublicProfile?
        if let receiverProfileId = receiverProfileId {
            recProfile = try PublicProfileDB.fetchOne(db, key: receiverProfileId)?.to(using: db)
        }

        let trans = Transaction(
            hash: hashDB,
            confirmations: confirmations ?? 0,
            isReplaceableByFee: isReplaceableByFee
        )

        let submarineSwap: SubmarineSwap?
        if let swapUuid = swapUuid {
            submarineSwap = try SubmarineSwapDB.fetchOne(db, key: swapUuid)?.to(using: db)
        } else {
            submarineSwap = nil
        }

        let incomingSwap = try incomingSwapUuid.flatMap { uuid in
            try IncomingSwapDB.fetchOne(db, key: uuid)?.to(using: db)
        }

        return Operation(
            id: id,
            requestId: "", // This will remain empty Forever
            isExternal: isExternal,
            direction: direction,
            senderProfile: senProfile,
            senderIsExternal: senderIsExternal,
            receiverProfile: recProfile,
            receiverIsExternal: receiverIsExternal,
            receiverAddress: receiverAddress,
            receiverAddressDerivationPath: receiverAddressDerivationPath,
            amount: btcAmount,
            fee: feeAmount,
            confirmations: confirmations,
            exchangeRatesWindowId: exchangeRateWindowHid,
            description: descriptionDB,
            status: status,
            transaction: trans,
            creationDate: creationDate,
            submarineSwap: submarineSwap,
            outpoints: nil, // We don't need retrocompat outpoints,
            incomingSwap: incomingSwap
        )
    }
    // swiftlint:enable function_body_length

}
