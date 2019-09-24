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
    let _submarineSwap: InputSubmarineSwap?

    init(prevOut: MuunOutput,
         address: MuunAddress,
         userSignature: Signature?,
         muunSignature: Signature?,
         submarineSwap: InputSubmarineSwap?) {
        self._prevOut = prevOut
        self._address = address
        self._userSignature = userSignature
        self._muunSignature = muunSignature
        self._submarineSwap = submarineSwap

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

class InputSubmarineSwap: NSObject {
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

    func submarineSwap() -> LibwalletInputSubmarineSwapProtocol? {
        if let ss = _submarineSwap {
            return ss
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

extension InputSubmarineSwap: LibwalletInputSubmarineSwapProtocol {

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
