//
//  SubmarineSwap.swift
//  falcon
//
//  Created by Manu Herrera on 03/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public class SubmarineSwap: NSObject {
    let _swapUuid: String
    public let _invoice: String
    public let _receiver: SubmarineSwapReceiver
    public let _fundingOutput: SubmarineSwapFundingOutput

    public let _fees: SubmarineSwapFees

    let _expiresAt: Date
    public let _willPreOpenChannel: Bool

    let _payedAt: Date?
    public let _preimageInHex: String?

    init(swapUuid: String,
         invoice: String,
         receiver: SubmarineSwapReceiver,
         fundingOutput: SubmarineSwapFundingOutput,
         fees: SubmarineSwapFees,
         expiresAt: Date,
         willPreOpenChannel: Bool,
         payedAt: Date?,
         preimageInHex: String?) {
        _swapUuid = swapUuid
        _invoice = invoice
        _receiver = receiver
        _fundingOutput = fundingOutput

        _fees = fees

        _expiresAt = expiresAt
        _willPreOpenChannel = willPreOpenChannel

        _payedAt = payedAt
        _preimageInHex = preimageInHex
    }
}

public class SubmarineSwapFees: NSObject {
    public let _lightning: Satoshis
    public let _sweep: Satoshis
    public let _channelOpen: Satoshis
    public let _channelClose: Satoshis

    init(lightning: Satoshis, sweep: Satoshis, channelOpen: Satoshis, channelClose: Satoshis) {
        _lightning = lightning
        _sweep = sweep
        _channelOpen = channelOpen
        _channelClose = channelClose
    }

    public func total() -> Satoshis {
        return _lightning + _sweep + _channelOpen + _channelClose
    }
}

public class SubmarineSwapReceiver: NSObject {
    public let _alias: String?
    public let _networkAddresses: [String]
    public let _publicKey: String?

    init(alias: String?,
         networkAddresses: [String],
         publicKey: String?) {
        self._alias = alias
        self._networkAddresses = networkAddresses
        self._publicKey = publicKey
    }
}

public class SubmarineSwapFundingOutput: NSObject {
    public let _outputAddress: String
    let _outputAmount: Satoshis
    public let _confirmationsNeeded: Int
    let _userLockTime: Int?
    let _serverPaymentHashInHex: String
    let _serverPublicKeyInHex: String
    let _expirationInBlocks: Int?
    let _scriptVersion: Int

    // v1 only
    let _userRefundAddress: MuunAddress?

    // v2 only
    let _userPublicKey: WalletPublicKey?
    let _muunPublicKey: WalletPublicKey?

    init(scriptVersion: Int,
         outputAddress: String,
         outputAmount: Satoshis,
         confirmationsNeeded: Int,
         userLockTime: Int?,
         userRefundAddress: MuunAddress?,
         serverPaymentHashInHex: String,
         serverPublicKeyInHex: String,
         expirationTimeInBlocks: Int?,
         userPublicKey: WalletPublicKey?,
         muunPublicKey: WalletPublicKey?) {

        self._scriptVersion = scriptVersion
        self._outputAddress = outputAddress
        self._outputAmount = outputAmount
        self._confirmationsNeeded = confirmationsNeeded
        self._userLockTime = userLockTime
        self._userRefundAddress = userRefundAddress
        self._serverPaymentHashInHex = serverPaymentHashInHex
        self._serverPublicKeyInHex = serverPublicKeyInHex
        self._expirationInBlocks = expirationTimeInBlocks
        self._userPublicKey = userPublicKey
        self._muunPublicKey = muunPublicKey

    }
}

extension SubmarineSwap: LibwalletSubmarineSwapProtocol {
    public func swapUuid() -> String {
        return _swapUuid
    }

    public func invoice() -> String {
        return _invoice
    }

    public func receiver() -> LibwalletSubmarineSwapReceiverProtocol? {
        return _receiver
    }

    public func fundingOutput() -> LibwalletSubmarineSwapFundingOutputProtocol? {
        return _fundingOutput
    }

    public func preimageInHex() -> String {
        return _preimageInHex ?? ""
    }
}

extension SubmarineSwapReceiver: LibwalletSubmarineSwapReceiverProtocol {

    public func alias() -> String {
        return _alias ?? ""
    }

    public func publicKey() -> String {
        return _publicKey ?? ""
    }
}

extension SubmarineSwapFundingOutput: LibwalletSubmarineSwapFundingOutputProtocol {

    public func expirationInBlocks() -> Int64 {
        return Int64(_expirationInBlocks ?? 0)
    }

    public func muunPublicKey() -> LibwalletHDPublicKey? {
        return _muunPublicKey?.key
    }

    public func scriptVersion() -> Int64 {
        return Int64(_scriptVersion)
    }

    public func userPublicKey() -> LibwalletHDPublicKey? {
        return _userPublicKey?.key
    }

    public func outputAddress() -> String {
        return _outputAddress
    }

    public func outputAmount() -> Int64 {
        return _outputAmount.value
    }

    public func confirmationsNeeded() -> Int {
        return _confirmationsNeeded
    }

    public func userLockTime() -> Int64 {
        return Int64(_userLockTime ?? 0)
    }

    public func userRefundAddress() -> LibwalletMuunAddressProtocol? {
        return _userRefundAddress
    }

    public func serverPaymentHashInHex() -> String {
        return _serverPaymentHashInHex
    }

    public func serverPublicKeyInHex() -> String {
        return _serverPublicKeyInHex
    }
}

public class SubmarineSwapRequest: NSObject {
    let _invoice: String
    let _swapExpirationInBlocks: Int

    init(invoice: String, swapExpirationInBlocks: Int) {
        _invoice = invoice
        _swapExpirationInBlocks = swapExpirationInBlocks
    }
}
