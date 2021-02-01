//
//  MuunModel.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import Libwallet

struct Signature {
    let hex: String
}

class MuunInput: NSObject {
    let _prevOut: MuunOutput
    let _address: MuunAddress
    let _userSignature: Signature?
    let _muunSignature: Signature?
    let _submarineSwapV1: InputSubmarineSwapV1?
    let _submarineSwapV2: InputSubmarineSwapV2?
    let _incomingSwap: InputIncomingSwap?

    init(prevOut: MuunOutput,
         address: MuunAddress,
         userSignature: Signature?,
         muunSignature: Signature?,
         submarineSwapV1: InputSubmarineSwapV1?,
         submarineSwapV2: InputSubmarineSwapV2?,
         incomingSwap: InputIncomingSwap?) {
        self._prevOut = prevOut
        self._address = address
        self._userSignature = userSignature
        self._muunSignature = muunSignature
        self._submarineSwapV1 = submarineSwapV1
        self._submarineSwapV2 = submarineSwapV2
        self._incomingSwap = incomingSwap

        super.init()
    }
}

class MuunOutput: NSObject {
    let _txId: String
    let _index: Int
    let _amount: Double

    init(txId: String, index: Int, amount: Double) {
        self._txId = txId
        self._index = index
        self._amount = amount

        super.init()
    }
}

class MuunAddress: NSObject {
    let _version: Int
    let _derivationPath: String
    let _address: String

    init(version: Int, derivationPath: String, address: String) {
        self._version = version
        self._derivationPath = derivationPath
        self._address = address

        super.init()
    }
}

class InputSubmarineSwapV1: NSObject {
    let _refundAddress: String
    let _swapPaymentHash256: Data
    let _swapServerPublicKey: Data
    let _lockTime: Int64

    init(refundAddress: String, paymentHash256: Data, serverPublicKey: Data, locktime: Int64) {
        self._refundAddress = refundAddress
        self._swapPaymentHash256 = paymentHash256
        self._swapServerPublicKey = serverPublicKey
        self._lockTime = locktime

        super.init()
    }
}

class InputSubmarineSwapV2: NSObject {
    let _swapPaymentHash256: Data
    let _userPublicKey: Data
    let _muunPublicKey: Data
    let _swapServerPublicKey: Data
    let _blocksForExpiration: Int64
    let _serverSignature: Data?

    init(paymentHash256: Data, userPublicKey: Data, muunPublicKey: Data,
         serverPublicKey: Data, blocksForExpiration: Int64, serverSignature: Data?) {
        self._swapPaymentHash256 = paymentHash256
        self._userPublicKey = userPublicKey
        self._muunPublicKey = muunPublicKey
        self._swapServerPublicKey = serverPublicKey
        self._blocksForExpiration = blocksForExpiration
        self._serverSignature = serverSignature

        super.init()
    }
}

class InputIncomingSwap: NSObject {
    let _sphinx: Data
    let _htlcTx: Data
    let _paymentHash256: Data
    let _swapServerPublicKey: Data
    let _expirationHeight: Int64
    let _collect: Satoshis

    init(sphinx: Data, htlcTx: Data, paymentHash256: Data, swapServerPublicKey: Data,
         expirationHeight: Int64, collect: Satoshis) {
        self._sphinx = sphinx
        self._htlcTx = htlcTx
        self._paymentHash256 = paymentHash256
        self._swapServerPublicKey = swapServerPublicKey
        self._expirationHeight = expirationHeight
        self._collect = collect

        super.init()
    }
}

extension MuunInput: LibwalletInputProtocol {

    func address() -> LibwalletMuunAddressProtocol? {
        return _address
    }

    func muunSignature() -> Data? {
        if let sig = _muunSignature {
            return Data(hex: sig.hex)
        }
        return nil
    }

    func outPoint() -> LibwalletOutpointProtocol? {
        return _prevOut
    }

    func userSignature() -> Data? {
        if let sig = _userSignature {
            return Data(hex: sig.hex)
        }
        return nil
    }

    func submarineSwapV1() -> LibwalletInputSubmarineSwapV1Protocol? {
        if let ss = _submarineSwapV1 {
            return ss
        }
        return nil
    }

    func submarineSwapV2() -> LibwalletInputSubmarineSwapV2Protocol? {
         if let ss = _submarineSwapV2 {
             return ss
         }
         return nil
     }

    func incomingSwap() -> LibwalletInputIncomingSwapProtocol? {
        if let sw = _incomingSwap {
            return sw
        }
        return nil
    }

}

extension MuunOutput: LibwalletOutpointProtocol {

    func amount() -> Int64 {
        return Int64(_amount)
    }

    func index() -> Int {
        return _index
    }

    func txId() -> Data? {
        return Data(hex: _txId)
    }

}

extension MuunAddress: LibwalletMuunAddressProtocol {

    func address() -> String {
        return _address
    }

    func derivationPath() -> String {
        return _derivationPath
    }

    func version() -> Int {
        return _version
    }

}

extension InputSubmarineSwapV1: LibwalletInputSubmarineSwapV1Protocol {

    func lockTime() -> Int64 {
        return _lockTime
    }

    func paymentHash256() -> Data? {
        return _swapPaymentHash256
    }

    func refundAddress() -> String {
        return _refundAddress
    }

    func serverPublicKey() -> Data? {
        return _swapServerPublicKey
    }

}

extension InputSubmarineSwapV2: LibwalletInputSubmarineSwapV2Protocol {

    func blocksForExpiration() -> Int64 {
        return Int64(_blocksForExpiration)
    }

    func muunPublicKey() -> Data? {
        return _muunPublicKey
    }

    func serverSignature() -> Data? {
        return _serverSignature
    }

    func userPublicKey() -> Data? {
        return _userPublicKey
    }

    func paymentHash256() -> Data? {
        return _swapPaymentHash256
    }

    func serverPublicKey() -> Data? {
        return _swapServerPublicKey
    }

}

extension InputIncomingSwap: LibwalletInputIncomingSwapProtocol {

    func sphinx() -> Data? {
        return _sphinx
    }

    func htlcTx() -> Data? {
        return _htlcTx
    }

    func paymentHash256() -> Data? {
        return _paymentHash256
    }

    func swapServerPublicKey() -> String {
        return _swapServerPublicKey.toHexString()
    }

    func expirationHeight() -> Int64 {
        return _expirationHeight
    }

    func collectInSats() -> Int64 {
        return _collect.value
    }
}
