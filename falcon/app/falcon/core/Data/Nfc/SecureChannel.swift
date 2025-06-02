//
//  SecureChannel.swift
//  Muun
//
//  Created by Daniel Mankowski on 20/03/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Libwallet

final class SecureChannel {
    private var iv: Data?
    private var initializedSecureChannel = false
    private var sharedKey: Data!
    private var computerPrivateKey: WalletPrivateKey! // Custom type, ECC private key
    private var cardEphemeralPublicKey: LibwalletPublicKey! // Custom type for ECC public key
    private var derivedKey: Data!

    // Designated initializer with IV defaulting to 16 zero bytes.
    init(iv: Data? = Data(repeating: 0x00, count: 16)) {
        self.iv = iv
    }

    // Factory method similar to Kotlin’s init()
    static func initialize() -> SecureChannel {
        return SecureChannel(iv: Data(repeating: 0x00, count: 16))
    }

    // MARK: - Secure Channel Initialization

    func cardInitiateSecureChannel(cardNfcService: CardNfcService) -> Bool {
        do {
            let (apduMessage, privKey) = try initSecureChannelMessage()
            self.computerPrivateKey = privKey

            let cardResponse = try cardNfcService.transmit(message: apduMessage)
                .toBlocking()
                .single()
            guard cardResponse.statusCode == NfcStatusCode.responseOk.rawValue else {
                Logger.log(.debug, "Wrong response code: \(cardResponse.statusCode)")
                return false
            }

            // Extract card public key, card ECDH, and derived key bytes from the card response.
            let cardPubKeyBytes = cardResponse.response.subdata(in: 0..<65)
            let cardEcdh = cardResponse.response.subdata(in: 65..<97)
            let cardDerivedKey = cardResponse.response.subdata(in: 97..<117)

            // Verify ECDH shared secret.
            try verifyEcdh(cardPublicKeyBytes: cardPubKeyBytes, cardEcdh: cardEcdh)
            try verifyDerivedKeys(sharedSecret: cardEcdh, cardDerivedKey: cardDerivedKey)

            self.cardEphemeralPublicKey = try parsePubKey(pubKeyBytes: cardPubKeyBytes)
            self.initializedSecureChannel = true
            return true
        } catch {
            Logger.log(.debug, "Error during secure channel initialization: \(error)")
            return false
        }
    }

    // Encrypt a message using AES-CBC with zero IV, generate HMAC-SHA1, and build encrypted APDU.
    func cardEncryptSecureChannelMessageRequest(apdu: Data) throws -> Data {
        guard initializedSecureChannel else {
            Logger.log(.debug, "Secure channel not initialized")
            return Data()
        }
        // Extract header fields from the APDU if needed.
        let cla = apdu[0]
        let ins = apdu[1]
        let p1 = apdu[2]
        let p2 = apdu[3]
        let plainData = apdu.subdata(in: 5..<apdu.count)

        // Encrypt plainData with AES-CBC using zero IV.
        let zeroIV = Data(repeating: 0x00, count: 16)
        let keyData = derivedKey.prefix(16) // Use first 16 bytes for AES key.
        let cipherText = try aesEncrypt(plainText: plainData, key: keyData, iv: zeroIV)

        // Generate MAC using HMAC-SHA1.
        let macBytes = try hmacSHA1(message: cipherText, key: derivedKey).removeTrailingZeroes()

        let encryptedData = cipherText + macBytes

        // Build new APDU message (you need to have an APDU builder utility in Swift).
        let msg = APDU.buildAPDU(cls: cla, ins: ins, data: encryptedData.bytes, p1: p1, p2: p2)
        return msg.apduMessage()
    }

    // MARK: - Helper Methods

    private func initSecureChannelMessage() throws -> (Data, WalletPrivateKey) {
        let cla: UInt8 = 0x80   // javaCard.MUUNCARD_CLA_EDGE
        let ins: UInt8 = 0x40   // INS_MUUNCARD_INIT_SECURE_CHANNEL
        let p1: UInt8 = 0x00    // javacard.NULL_BYTE
        let p2: UInt8 = 0x00    // javacard.NULL_BYTE

        let deterministicKey = WalletPrivateKey.createRandom()
        let pubKeyData = deterministicKey.walletPublicKey().serializeUncompressed()!.bytes
        let apdu = APDU.buildAPDU(cls: cla, ins: ins, data: pubKeyData, p1: p1, p2: p2)

        Logger.log(.debug, "initSecureChannelMessage: length of pubKey: \(pubKeyData.count)")

        return (apdu.apduMessage(), deterministicKey)
    }

    private func verifyEcdh(cardPublicKeyBytes: Data, cardEcdh: Data) throws {
        let computedSharedSecret = try generateSharedSecret(privateKey: computerPrivateKey.key,
                                                            publicKey: cardPublicKeyBytes)
        guard computedSharedSecret == cardEcdh else {
            Logger.log(.debug, "ECDH shared secret mismatch")
            return
        }
        self.sharedKey = cardEcdh
    }

    private func generateSharedSecret(privateKey: LibwalletHDPrivateKey,
                                      publicKey: Data) throws -> Data {

        LibwalletGenerateSharedSecret(privateKey, publicKey)!
    }

    private func verifyDerivedKeys(sharedSecret: Data, cardDerivedKey: Data) throws {
        let salt = "deriv_key".data(using: .utf8)!
        let derivedKey = try hmacSHA1(message: salt, key: sharedSecret).removeTrailingZeroes()
        guard derivedKey == cardDerivedKey else {
            Logger.log(.debug, "Derived key mismatch")
            return
        }
        self.derivedKey = derivedKey
    }

    func verifyResponseMAC(response: Data) -> Data? {
        guard response.count >= 20 else {
            Logger.log(.debug, "Response too short to contain MAC")
            return nil
        }
        let dataLen = response.count - 20
        let dataPart = response.subdata(in: 0..<dataLen)
        let responseMAC = response.subdata(in: dataLen..<response.count)

        let salt = "deriv_key".data(using: .utf8)!
        // swiftlint:disable force_error_handling
        let expectedMAC = try? hmacSHA1(message: salt, key: self.sharedKey).removeTrailingZeroes()

        guard responseMAC == expectedMAC else {
            Logger.log(.debug, "Response MAC verification failed")
            return nil
        }
        return dataPart
    }

    private func parsePubKey(pubKeyBytes: Data) throws -> LibwalletPublicKey? {
        let publicKey = try doWithError({ error in
            LibwalletNewPublicKeyFromBytes(pubKeyBytes, error)
        })
        return publicKey
    }

    private func hmacSHA1(message: Data, key: Data) throws -> Data {
        return LibwalletEncryptHMacSha1(key, message)!
    }

    // AES Encryption function using CommonCrypto or a Swift library
    private func aesEncrypt(plainText: Data, key: Data, iv: Data) throws -> Data {
        let cypherText = try doWithError { error in
            LibwalletAesEncrypt(key, iv, plainText, error)
        }
        return cypherText
    }
}

/// Extension for Data to remove trailing zeroes (assuming you have such utility)
extension Data {
    func removeTrailingZeroes() throws -> Data {
        var newLength = self.count
        while newLength > 0 && self[self.index(self.startIndex, offsetBy: newLength - 1)] == 0 {
            newLength -= 1
        }
        return self.prefix(newLength)
    }
}
