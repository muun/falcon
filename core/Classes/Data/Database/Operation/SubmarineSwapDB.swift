//
//  SubmarineSwapDB.swift
//  falcon
//
//  Created by Manu Herrera on 03/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import GRDB

struct SubmarineSwapDB: Codable, FetchableRecord, PersistableRecord {

    typealias PrimaryKeyType = String

    let swapUuid: String

    let invoice: String

    let sweepFee: Int64
    let lightningFee: Int64
    let channelOpenFee: Int64
    let channelCloseFee: Int64

    let expiredAt: Date

    let payedAt: Date?
    let preimageInHex: String?

    let alias: String?
    let serializedNetworkAddresses: String?
    let publicKey: String?

    let outputAddress: String
    let outputAmount: Int64
    let confirmationsNeeded: Int
    let userLockTime: Int

    let userRefundAddress: String
    let userRefundAddressVersion: Int
    let userRefundAddressPath: String

    let serverPaymentHashInHex: String
    let serverPublicKeyInHex: String

    let willPreOpenChannel: Bool
}

extension SubmarineSwapDB: DatabaseModelConvertible {

    init(from: SubmarineSwap) {
        self.init(swapUuid: from._swapUuid,
                  invoice: from._invoice,
                  sweepFee: from._fees._sweep.value,
                  lightningFee: from._fees._lightning.value,
                  channelOpenFee: from._fees._channelOpen.value,
                  channelCloseFee: from._fees._channelClose.value,
                  expiredAt: from._expiresAt,
                  payedAt: from._payedAt,
                  preimageInHex: from._preimageInHex,
                  alias: from._receiver._alias,
                  serializedNetworkAddresses: from._receiver._networkAddresses.joined(separator: "-"),
                  publicKey: from._receiver._publicKey,
                  outputAddress: from._fundingOutput._outputAddress,
                  outputAmount: from._fundingOutput._outputAmount.value,
                  confirmationsNeeded: from._fundingOutput._confirmationsNeeded,
                  userLockTime: from._fundingOutput._userLockTime,
                  userRefundAddress: from._fundingOutput._userRefundAddress.address(),
                  userRefundAddressVersion: from._fundingOutput._userRefundAddress.version(),
                  userRefundAddressPath: from._fundingOutput._userRefundAddress.derivationPath(),
                  serverPaymentHashInHex: from._fundingOutput._serverPaymentHashInHex,
                  serverPublicKeyInHex: from._fundingOutput._serverPublicKeyInHex,
                  willPreOpenChannel: from._willPreOpenChannel)
    }

    func to(using db: Database) throws -> SubmarineSwap {
        let networkAddress = serializedNetworkAddresses?.split(separator: "-").map(String.init) ?? []
        let sswapUserRefundAddress = MuunAddress(version: userRefundAddressVersion,
                                                 derivationPath: userRefundAddressPath,
                                                 address: userRefundAddress)
        return SubmarineSwap(swapUuid: swapUuid,
                             invoice: invoice,
                             receiver: SubmarineSwapReceiver(alias: alias,
                                                             networkAddresses: networkAddress,
                                                             publicKey: publicKey),
                             fundingOutput: SubmarineSwapFundingOutput(outputAddress: outputAddress,
                                                                       outputAmount: Satoshis(value: outputAmount),
                                                                       confirmationsNeeded: confirmationsNeeded,
                                                                       userLockTime: userLockTime,
                                                                       userRefundAddress: sswapUserRefundAddress,
                                                                       serverPaymentHashInHex: serverPaymentHashInHex,
                                                                       serverPublicKeyInHex: serverPublicKeyInHex),
                             fees: SubmarineSwapFees(lightning: Satoshis(value: lightningFee),
                                                     sweep: Satoshis(value: sweepFee),
                                                     channelOpen: Satoshis(value: channelOpenFee),
                                                     channelClose: Satoshis(value: channelCloseFee)),
                             expiresAt: expiredAt,
                             willPreOpenChannel: willPreOpenChannel,
                             payedAt: payedAt,
                             preimageInHex: preimageInHex)
    }

}
