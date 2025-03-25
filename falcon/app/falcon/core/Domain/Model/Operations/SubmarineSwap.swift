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

    public let _fees: SubmarineSwapFees?

    let _expiresAt: Date
    public let _willPreOpenChannel: Bool

    public let _bestRouteFees: [BestRouteFees]?
    public let _fundingOutputPolicies: FundingOutputPolicies?

    let _payedAt: Date?
    public let _preimageInHex: String?

    init(swapUuid: String,
         invoice: String,
         receiver: SubmarineSwapReceiver,
         fundingOutput: SubmarineSwapFundingOutput,
         fees: SubmarineSwapFees?,
         expiresAt: Date,
         willPreOpenChannel: Bool,
         bestRouteFees: [BestRouteFees]?,
         fundingOutputPolicies: FundingOutputPolicies?,
         payedAt: Date?,
         preimageInHex: String?) {
        _swapUuid = swapUuid
        _invoice = invoice
        _receiver = receiver
        _fundingOutput = fundingOutput

        _fees = fees

        _expiresAt = expiresAt
        _willPreOpenChannel = willPreOpenChannel

        _bestRouteFees = bestRouteFees
        _fundingOutputPolicies = fundingOutputPolicies

        _payedAt = payedAt
        _preimageInHex = preimageInHex
    }

    /*
    Lightning fee is calculated in this way:
    1. For lend swaps: Only the routing fee
    2. For 0-conf, 1-conf and top-ups: routing fee + on-chain fee + sweep fee
    */
    public func getLightningFeeInSats(onChainFee: BitcoinAmount) -> Satoshis? {

        // If the invoice didn't have an amount, the fee information might not be available yet
        guard let debtType = _fundingOutput._debtType,
              let fees = _fees else {
            return nil
        }

        if debtType == .LEND {
            return fees._lightning
        }

        return fees._lightning + onChainFee.inSatoshis + fees._sweep
    }
}

public class BestRouteFees: NSObject {
    public let _maxCapacityInSat: Int64
    public let _proportionalMillionth: Int64
    public let _baseInSat: Int64

    init(_maxCapacityInSat: Int64, _proportionalMillionth: Int64, _baseInSat: Int64) {
        self._maxCapacityInSat = _maxCapacityInSat
        self._proportionalMillionth = _proportionalMillionth
        self._baseInSat = _baseInSat
    }
}

public class FundingOutputPolicies: NSObject {
    public let _maximumDebtInSat: Int64
    public let _potentialCollectInSat: Int64
    public let _maxAmountInSatFor0Conf: Int64

    init(_maximumDebtInSat: Int64, _potentialCollectInSat: Int64, _maxAmountInSatFor0Conf: Int64) {
        self._maximumDebtInSat = _maximumDebtInSat
        self._potentialCollectInSat = _potentialCollectInSat
        self._maxAmountInSatFor0Conf = _maxAmountInSatFor0Conf
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
    let _outputAmount: Satoshis?
    public let _confirmationsNeeded: Int?
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

    public let _debtType: DebtType?
    public let _debtAmount: Satoshis?

    init(scriptVersion: Int,
         outputAddress: String,
         outputAmount: Satoshis?,
         confirmationsNeeded: Int?,
         userLockTime: Int?,
         userRefundAddress: MuunAddress?,
         serverPaymentHashInHex: String,
         serverPublicKeyInHex: String,
         expirationTimeInBlocks: Int?,
         userPublicKey: WalletPublicKey?,
         muunPublicKey: WalletPublicKey?,
         debtType: DebtType?,
         debtAmount: Satoshis?) {

        _scriptVersion = scriptVersion
        _outputAddress = outputAddress
        _outputAmount = outputAmount
        _confirmationsNeeded = confirmationsNeeded
        _userLockTime = userLockTime
        _userRefundAddress = userRefundAddress
        _serverPaymentHashInHex = serverPaymentHashInHex
        _serverPublicKeyInHex = serverPublicKeyInHex
        _expirationInBlocks = expirationTimeInBlocks
        _userPublicKey = userPublicKey
        _muunPublicKey = muunPublicKey

        _debtType = debtType
        _debtAmount = debtAmount
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
        return _outputAmount?.value ?? 0
    }

    public func confirmationsNeeded() -> Int {
        return _confirmationsNeeded ?? 0
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
    let _origin: String
    let _bkgTimes: [BackgroundTimeLapse]

    init(invoice: String, swapExpirationInBlocks: Int, origin: String, bkgTimes: [BackgroundTimeLapse]) {
        _invoice = invoice
        _swapExpirationInBlocks = swapExpirationInBlocks
        _origin = origin
        _bkgTimes = bkgTimes
    }
}

public class SwapExecutionParameters: NSObject {
    public let sweepFee: Satoshis
    public let routingFee: Satoshis
    public let debtType: DebtType
    public let debtAmount: Satoshis
    public let confirmationsNeeded: UInt

    public init(sweepFee: Satoshis,
                routingFee: Satoshis,
                debtType: DebtType,
                debtAmount: Satoshis,
                confirmationsNeeded: UInt) {

        self.sweepFee = sweepFee
        self.routingFee = routingFee
        self.debtType = debtType
        self.debtAmount = debtAmount
        self.confirmationsNeeded = confirmationsNeeded
    }

    public var offchainFee: Satoshis {
        return routingFee + sweepFee
    }
}

public struct SubmarineSwapCreated {
    public let swap: SubmarineSwap
    public let maxAlternativeTransactionCount: Int
}