//
//  Mapper.swift
//  falcon
//
//  Created by Juan Pablo Civile on 05/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

// swiftlint:disable file_length
// swiftlint:disable cyclomatic_complexity
protocol ModelOperationConvertible {
    associatedtype OperationOutput

    func toModel(decrypter: OperationMetadataDecrypter) -> OperationOutput
}

extension CreateLoginSession: APIConvertible {

    func toJson() -> CreateLoginSessionJson {
        return CreateLoginSessionJson(client: client.toJson(), email: email, gcmToken: gcmToken)
    }

}

extension CreateSessionOkJson: ModelConvertible {

    public func toModel() -> CreateSessionOk {
        return CreateSessionOk(isExistingUser: isExistingUser,
                               canUseRecoveryCode: canUseRecoveryCode,
                               passwordSetupDate: passwordSetupDate,
                               recoveryCodeSetupDate: recoveryCodeSetupDate)
    }

}

extension CreateFirstSession: APIConvertible {

    func toJson() -> CreateFirstSessionJson {
        return CreateFirstSessionJson(client: client.toJson(),
                                      gcmToken: gcmToken,
                                      primaryCurrency: primaryCurrency,
                                      basePublicKey: basePublicKey.toJson(),
                                      anonChallengeSetup: anonChallengeSetup.toJson())
    }

}

extension CreateFirstSessionOkJson: ModelConvertible {

    public func toModel() -> CreateFirstSessionOk {
        return CreateFirstSessionOk(user: user, cosigningPublicKey: cosigningPublicKey.toModel())
    }

}

extension Client: APIConvertible {

    func toJson() -> ClientJson {
        return ClientJson(type: type, buildType: buildType, version: version)
    }

}

extension VerificationType: APIConvertible {

    func toJson() -> VerificationTypeJson {

        switch self {
        case .SMS:
            return .SMS
        case .CALL:
            return .CALL
        }
    }

}

extension EmptyJson: ModelConvertible {

    public func toModel() {
        return ()
    }

}

extension PublicKeyJson: ModelConvertible {

    public func toModel() -> WalletPublicKey {
        return WalletPublicKey.fromBase58(key, on: path)
    }

}

extension WalletPublicKey: APIConvertible {

    func toJson() -> PublicKeyJson {
        return PublicKeyJson(key: toBase58(), path: path)
    }

}

extension StartEmailSetup: APIConvertible {

    func toJson() -> StartEmailSetupJson {
        return StartEmailSetupJson(email: email, challengeSignature: challengeSignature.toJson())
    }

}

extension PasswordSetup: APIConvertible {

    func toJson() -> PasswordSetupJson {
        return PasswordSetupJson(challengeSignature: challengeSignature.toJson(),
                                 challengeSetup: challengeSetup.toJson())
    }

}

extension ChallengeSetup: APIConvertible {

    func toJson() -> ChallengeSetupJson {
        return ChallengeSetupJson(type: type.toJson(),
                                  passwordSecretPublicKey: passwordSecretPublicKey,
                                  passwordSecretSalt: passwordSecretSalt,
                                  encryptedPrivateKey: encryptedPrivateKey,
                                  version: version)
    }

}

extension ChallengeType: APIConvertible {

    func toJson() -> ChallengeTypeJson {

        switch self {

        case .PASSWORD:
            return .PASSWORD
        case .RECOVERY_CODE:
            return .RECOVERY_CODE
        case .ANON:
            return .ANON
        }
    }

}

extension NotificationJson: ModelOperationConvertible {

    public func toModel(decrypter: OperationMetadataDecrypter) -> Notification {
        return Notification(id: id,
                            previousId: previousId,
                            senderSessionUuid: senderSessionUuid,
                            message: message.toModel(decrypter: decrypter))
    }

}

extension NotificationJson.MessagePayloadJson: ModelOperationConvertible {

    func toModel(decrypter: OperationMetadataDecrypter) -> Notification.Message {
        switch self {

        case .sessionAuthorized: return .sessionAuthorized

        case .newOperation(let newOperation):
            return .newOperation(newOperation.toModel(decrypter: decrypter))

        case .operationUpdate(let operationUpdate): return .operationUpdate(operationUpdate.toModel())

        case .unknownMessage(let type): return .unknownMessage(type: type)

        case .newContact: return .newContact

        case .expiredSession: return .expiredSession

        case .updateContact: return .updateContact

        case .updateAuthorizeChallenge: return .updateAuthorizeChallenge

        case .verifiedEmail: return .verifiedEmail

        case .completePairingAck: return .completePairingAck

        case .addHardwareWallet: return .addHardwareWallet

        case .withdrawalResult: return .withdrawalResult

        case .getSatelliteState: return .getSatelliteState
        }
    }

}

extension NotificationJson.NewOperationJson: ModelOperationConvertible {

    func toModel(decrypter: OperationMetadataDecrypter) -> Notification.NewOperation {
        return Notification.NewOperation(operation: operation.toModel(decrypter: decrypter),
                                         nextTransactionSize: nextTransactionSize.toModel())
    }

}

extension NotificationJson.OperationUpdateJson: ModelConvertible {

    public func toModel() -> Notification.OperationUpdate {
        return Notification.OperationUpdate(id: id,
                                            confirmations: confirmations,
                                            status: status.toModel(),
                                            hash: hash,
                                            nextTransactionSize: nextTransactionSize.toModel(),
                                            swapDetails: swapDetails?.toModel())
    }

}

extension UserJson: ModelConvertible {

    public func toModel() -> User {
        return User(id: id,
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phoneNumber: phoneNumber?.toModel(),
                    profilePictureUrl: profilePictureUrl,
                    primaryCurrency: primaryCurrency,
                    isEmailVerified: isEmailVerified,
                    hasPasswordChallengeKey: hasPasswordChallengeKey,
                    hasRecoveryCodeChallengeKey: hasRecoveryCodeChallengeKey,
                    hasP2PEnabled: hasP2PEnabled,
                    hasExportedKeys: hasExportedKeys,
                    createdAt: createdAt,
                    emergencyKitLastExportedDate: emergencyKitLastExportedAt)
    }

}

extension User: APIConvertible {

    func toJson() -> UserJson {
        return UserJson(id: id,
                        firstName: firstName,
                        lastName: lastName,
                        email: email,
                        phoneNumber: phoneNumber?.toJson(),
                        profilePictureUrl: profilePictureUrl,
                        primaryCurrency: primaryCurrency,
                        isEmailVerified: isEmailVerified,
                        hasPasswordChallengeKey: hasPasswordChallengeKey,
                        hasRecoveryCodeChallengeKey: hasRecoveryCodeChallengeKey,
                        hasP2PEnabled: hasP2PEnabled,
                        hasExportedKeys: hasExportedKeys ?? false,
                        createdAt: createdAt ?? nil,
                        emergencyKitLastExportedAt: emergencyKitLastExportedDate)
    }

}

extension ExportEmergencyKit: APIConvertible {

    func toJson() -> ExportEmergencyKitJson {
        return ExportEmergencyKitJson(lastExportedAt: lastExportedAt, verificationCode: verificationCode)
    }

}

extension PhoneNumber: APIConvertible {

    func toJson() -> PhoneNumberJson {
        return PhoneNumberJson(isVerified: isVerified,
                               number: number)
    }

}

extension PhoneNumberJson: ModelConvertible {

    public func toModel() -> PhoneNumber {
        return PhoneNumber(isVerified: isVerified,
                           number: number)
    }

}

extension PendingChallengeUpdateJson: ModelConvertible {

    public func toModel() -> PendingChallengeUpdate {
        return PendingChallengeUpdate(uuid: uuid,
                                      type: type.toModel())
    }

}

extension ChallengeUpdate: APIConvertible {

    func toJson() -> ChallengeUpdateJson {
        return ChallengeUpdateJson(uuid: uuid, challengeSetup: challengeSetup.toJson())
    }

}

extension ChallengeJson: ModelConvertible {

    public func toModel() -> Challenge {
        return Challenge(type: type.toModel(),
                         challenge: challenge,
                         salt: salt)
    }

}

extension ChallengeTypeJson: ModelConvertible {

    public func toModel() -> ChallengeType {
        return ChallengeType(rawValue: rawValue) ?? .PASSWORD
    }

}

extension SetupChallengeResponseJson: ModelConvertible {

    public func toModel() -> SetupChallengeResponse {
        return SetupChallengeResponse(muunKey: muunKey)
    }

}

extension SetupChallengeResponse: APIConvertible {

    func toJson() -> SetupChallengeResponseJson {
        return SetupChallengeResponseJson(muunKey: muunKey)
    }

}

extension ChallengeSignature: APIConvertible {

    func toJson() -> ChallengeSignatureJson {
        return ChallengeSignatureJson(type: type.toJson(),
                                      hex: hex)
    }

}

extension KeySetJson: ModelConvertible {

    public func toModel() -> KeySet {

        return KeySet(encryptedPrivateKey: encryptedPrivateKey,
                      muunKey: muunKey,
                      challengeKeys: challengeKeys.map({ $0.toModel() }))
    }

}

extension ChallengeKeyJson: ModelConvertible {

    public func toModel() -> ChallengeKey {
        return ChallengeKey(type: type.toModel(),
                            publicKey: Data(hex: publicKey),
                            salt: Data(hex: salt))
    }

}

extension PhoneConfirmation: APIConvertible {

    func toJson() -> PhoneConfirmationJson {
        return PhoneConfirmationJson(verificationCode: verificationCode,
                                     signedUp: signedUp,
                                     hasPasswordChallengeKey: hasPasswordChallengeKey,
                                     hasRecoveryCodeChallengeKey: hasRecoveryCodeChallengeKey)
    }

}

extension PhoneConfirmationJson: ModelConvertible {

    public func toModel() -> PhoneConfirmation {
        return PhoneConfirmation(verificationCode: verificationCode,
                                 signedUp: signedUp,
                                 hasPasswordChallengeKey: hasPasswordChallengeKey,
                                 hasRecoveryCodeChallengeKey: hasRecoveryCodeChallengeKey)
    }

}

extension ExternalAddressesRecord: APIConvertible {

    func toJson() -> ExternalAddressesRecordJson {
        return ExternalAddressesRecordJson(maxUsedIndex: maxUsedIndex,
                                           maxWatchingIndex: maxWatchingIndex)
    }

}

extension ExternalAddressesRecordJson: ModelConvertible {

    public func toModel() -> ExternalAddressesRecord {
        return ExternalAddressesRecord(maxUsedIndex: maxUsedIndex,
                                       maxWatchingIndex: maxWatchingIndex)
    }

}

extension PublicKeySet: APIConvertible {

    func toJson() -> PublicKeySetJson {
        return PublicKeySetJson(basePublicKey: basePublicKey.toJson(),
                                baseCosigningPublicKey: baseCosigningPublicKey?.toJson(),
                                externalPublicKeyIndices: externalPublicKeyIndices?.toJson())
    }

}

extension PublicKeySetJson: ModelConvertible {

    public func toModel() -> PublicKeySet {
        return PublicKeySet(basePublicKey: basePublicKey.toModel(),
                            baseCosigningPublicKey: baseCosigningPublicKey?.toModel(),
                            externalPublicKeyIndices: externalPublicKeyIndices?.toModel())
    }

}

extension SendEncryptedKeys: APIConvertible {

    func toJson() -> SendEncryptedKeysJson {
        return SendEncryptedKeysJson(userKey: userKey)
    }

}

extension IntegrityCheck: APIConvertible {

    func toJson() -> IntegrityCheckJson {
        return IntegrityCheckJson(publicKeySet: publicKeySet.toJson(), balanceInSatoshis: balanceInSatoshis)
    }

}

extension IntegrityStatusJson: ModelConvertible {

    public func toModel() -> IntegrityStatus {
        return IntegrityStatus(isBasePublicKeyOk: isBasePublicKeyOk,
                               isExternalMaxUsedIndexOk: isExternalMaxUsedIndexOk,
                               isBalanceOk: isBalanceOk)
    }

}

extension NextTransactionSizeJson: ModelConvertible {

    public func toModel() -> NextTransactionSize {
        return NextTransactionSize(sizeProgression: sizeProgression.map({ $0.toModel() }),
                                   validAtOperationHid: validAtOperationHid,
                                   _expectedDebt: Satoshis(value: expectedDebtInSat))
    }

}

extension NextTransactionSize: APIConvertible {

    func toJson() -> NextTransactionSizeJson {
        return NextTransactionSizeJson(sizeProgression: sizeProgression.map({ $0.toJson() }),
                                       validAtOperationHid: validAtOperationHid,
                                       expectedDebtInSat: expectedDebt.value)
    }

}

extension SizeForAmountJson: ModelConvertible {

    public func toModel() -> SizeForAmount {
        return SizeForAmount(
            amountInSatoshis: Satoshis(value: amountInSatoshis),
            sizeInBytes: sizeInBytes,
            outpoint: outpoint
        )
    }

}

extension SizeForAmount: APIConvertible {

    func toJson() -> SizeForAmountJson {
        return SizeForAmountJson(
            amountInSatoshis: amountInSatoshis.value,
            sizeInBytes: sizeInBytes,
            outpoint: outpoint ?? ""
        )
    }

}

extension RawTransaction: APIConvertible {

    func toJson() -> RawTransactionJson {
        return RawTransactionJson(hex: hex)
    }

}

extension RawTransactionJson: ModelConvertible {

    public func toModel() -> RawTransaction {
        return RawTransaction(hex: hex)
    }

}

extension RawTransactionResponse: APIConvertible {

    func toJson() -> RawTransactionResponseJson {
        return RawTransactionResponseJson(hex: self.hex, nextTransactionSize: self.nextTransactionSize.toJson())
    }

}

extension RawTransactionResponseJson: ModelConvertible {

    public func toModel() -> RawTransactionResponse {
        return RawTransactionResponse(hex: self.hex, nextTransactionSize: self.nextTransactionSize.toModel())
    }

}

extension PublicProfile: APIConvertible {

    func toJson() -> PublicProfileJson {
        return PublicProfileJson(userId: userId,
                                 firstName: firstName,
                                 lastName: lastName,
                                 profilePictureUrl: profilePictureUrl)
    }

}

extension PublicProfileJson: ModelConvertible {

    public func toModel() -> PublicProfile {
        return PublicProfile(userId: userId,
                             firstName: firstName,
                             lastName: lastName,
                             profilePictureUrl: profilePictureUrl)
    }

}

extension BitcoinAmount: APIConvertible {

    func toJson() -> BitcoinAmountJson {
        return BitcoinAmountJson(inSatoshis: inSatoshis.value,
                                 inInputCurrency: inInputCurrency.toJson(),
                                 inPrimaryCurrency: inPrimaryCurrency.toJson())
    }

}

extension BitcoinAmountJson: ModelConvertible {

    public func toModel() -> BitcoinAmount {
        return BitcoinAmount(inSatoshis: Satoshis(value: inSatoshis),
                             inInputCurrency: inInputCurrency.toModel(),
                             inPrimaryCurrency: inPrimaryCurrency.toModel())
    }

}

extension MonetaryAmount: APIConvertible {

    func toJson() -> MonetaryAmountJson {
        return MonetaryAmountJson(amount: amount.stringValue(locale: Constant.houstonLocale),
                                  currency: currency)
    }

}

extension MonetaryAmountJson: ModelConvertible {

    public func toModel() -> MonetaryAmount {
        return MonetaryAmount(amount: amount, currency: currency)!
    }

}

extension OperationStatus: APIConvertible {

    func toJson() -> OperationStatusJson {

        switch self {

        case .CREATED: return .CREATED
        case .SIGNING: return .SIGNING
        case .SIGNED: return .SIGNED
        case .BROADCASTED: return .BROADCASTED
        case .SWAP_EXPIRED: return .SWAP_EXPIRED
        case .SWAP_OPENING_CHANNEL: return .SWAP_OPENING_CHANNEL
        case .SWAP_WAITING_CHANNEL: return .SWAP_WAITING_CHANNEL
        case .SWAP_ROUTING: return .SWAP_ROUTING
        case .SWAP_FAILED: return .SWAP_FAILED
        case .SWAP_PAYED: return .SWAP_PAYED
        case .SWAP_PENDING: return .SWAP_PENDING
        case .CONFIRMED: return .CONFIRMED
        case .SETTLED: return .SETTLED
        case .DROPPED: return .DROPPED
        case .FAILED: return .FAILED
        }
    }

}

extension OperationStatusJson: ModelConvertible {

    public func toModel() -> OperationStatus {

        switch self {

        case .CREATED: return .CREATED
        case .SIGNING: return .SIGNING
        case .SIGNED: return .SIGNED
        case .BROADCASTED: return .BROADCASTED
        case .SWAP_EXPIRED: return .SWAP_EXPIRED
        case .SWAP_OPENING_CHANNEL: return .SWAP_OPENING_CHANNEL
        case .SWAP_WAITING_CHANNEL: return .SWAP_WAITING_CHANNEL
        case .SWAP_ROUTING: return .SWAP_ROUTING
        case .SWAP_FAILED: return .SWAP_FAILED
        case .SWAP_PAYED: return .SWAP_PAYED
        case .SWAP_PENDING: return .SWAP_PENDING
        case .CONFIRMED: return .CONFIRMED
        case .SETTLED: return .SETTLED
        case .DROPPED: return .DROPPED
        case .FAILED: return .FAILED
        }
    }

}

extension Transaction: APIConvertible {

    func toJson() -> TransactionJson {
        return TransactionJson(hash: hash, confirmations: confirmations)
    }

}

extension TransactionJson: ModelConvertible {

    public func toModel() -> Transaction {
        return Transaction(hash: hash, confirmations: confirmations)
    }

}

extension Operation: APIConvertible {

    func toJson() -> OperationJson {
        return OperationJson(id: id,
                             requestId: requestId,
                             isExternal: isExternal,
                             direction: direction.toJson(),
                             senderProfile: senderProfile?.toJson(),
                             senderIsExternal: senderIsExternal,
                             receiverProfile: receiverProfile?.toJson(),
                             receiverIsExternal: receiverIsExternal,
                             receiverAddress: receiverAddress,
                             receiverAddressDerivationPath: receiverAddressDerivationPath,
                             amount: amount.toJson(),
                             fee: fee.toJson(),
                             confirmations: confirmations,
                             exchangeRatesWindowId: exchangeRatesWindowId,
                             status: status.toJson(),
                             transaction: transaction?.toJson(),
                             creationDate: creationDate,
                             outputAmountInSatoshis: outputAmount.value,
                             swapUuid: submarineSwap?._swapUuid,
                             swap: submarineSwap?.toJson(),
                             description: description,
                             outpoints: outpoints)
    }
}

extension SubmarineSwap: APIConvertible {
    func toJson() -> SubmarineSwapJson {
        return SubmarineSwapJson(swapUuid: _swapUuid,
                                 invoice: _invoice,
                                 receiver: _receiver.toJson(),
                                 fundingOutput: _fundingOutput.toJson(),
                                 fees: _fees.toJson(),
                                 expiresAt: _expiresAt,
                                 willPreOpenChannel: _willPreOpenChannel,
                                 payedAt: _payedAt,
                                 preimageInHex: _preimageInHex)
    }
}

extension SubmarineSwapFees: APIConvertible {
    func toJson() -> SubmarineSwapFeesJson {
        return SubmarineSwapFeesJson(lightningInSats: _lightning.value,
                                     sweepInSats: _sweep.value,
                                     channelOpenInSats: _channelOpen.value,
                                     channelCloseInSats: _channelClose.value)
    }
}

extension SubmarineSwapFeesJson: ModelConvertible {
    func toModel() -> SubmarineSwapFees {
        return SubmarineSwapFees(lightning: Satoshis(value: lightningInSats),
                                 sweep: Satoshis(value: sweepInSats),
                                 channelOpen: Satoshis(value: channelOpenInSats),
                                 channelClose: Satoshis(value: channelCloseInSats))
    }
}

extension SubmarineSwapReceiver: APIConvertible {
    func toJson() -> SubmarineSwapReceiverJson {
        return SubmarineSwapReceiverJson(alias: _alias,
                                         networkAddresses: _networkAddresses,
                                         publicKey: _publicKey)
    }
}

extension SubmarineSwapFundingOutput: APIConvertible {
    func toJson() -> SubmarineSwapFundingOutputJson {
        return SubmarineSwapFundingOutputJson(scriptVersion: _scriptVersion,
                                              outputAddress: _outputAddress,
                                              outputAmountInSatoshis: _outputAmount.value,
                                              confirmationsNeeded: _confirmationsNeeded,
                                              userLockTime: _userLockTime,
                                              serverPaymentHashInHex: _serverPaymentHashInHex,
                                              serverPublicKeyInHex: _serverPublicKeyInHex,
                                              expirationInBlocks: _expirationInBlocks,
                                              userRefundAddress: _userRefundAddress?.toJson(),
                                              userPublicKey: _userPublicKey?.toJson(),
                                              muunPublicKey: _muunPublicKey?.toJson(),
                                              debtType: _debtType.rawValue,
                                              debtAmountInSats: _debtAmount.value)
    }
}

extension SubmarineSwapJson: ModelConvertible {
    public func toModel() -> SubmarineSwap {
        return SubmarineSwap(swapUuid: swapUuid,
                             invoice: invoice,
                             receiver: receiver.toModel(),
                             fundingOutput: fundingOutput.toModel(),
                             fees: fees.toModel(),
                             expiresAt: expiresAt,
                             willPreOpenChannel: willPreOpenChannel,
                             payedAt: payedAt,
                             preimageInHex: preimageInHex)
    }
}

extension SubmarineSwapReceiverJson: ModelConvertible {
    public func toModel() -> SubmarineSwapReceiver {
        return SubmarineSwapReceiver(alias: alias,
                                     networkAddresses: networkAddresses,
                                     publicKey: publicKey)
    }
}

extension SubmarineSwapFundingOutputJson: ModelConvertible {
    public func toModel() -> SubmarineSwapFundingOutput {
        return SubmarineSwapFundingOutput(scriptVersion: scriptVersion,
                                          outputAddress: outputAddress,
                                          outputAmount: Satoshis(value: outputAmountInSatoshis),
                                          confirmationsNeeded: confirmationsNeeded,
                                          userLockTime: userLockTime,
                                          userRefundAddress: userRefundAddress?.toModel(),
                                          serverPaymentHashInHex: serverPaymentHashInHex,
                                          serverPublicKeyInHex: serverPublicKeyInHex,
                                          expirationTimeInBlocks: expirationInBlocks,
                                          userPublicKey: userPublicKey?.toModel(),
                                          muunPublicKey: muunPublicKey?.toModel(),
                                          debtType: DebtType(rawValue: debtType) ?? .NONE,
                                          debtAmount: Satoshis(value: debtAmountInSats))
    }
}

extension OperationJson: ModelOperationConvertible  {

    func toModel(decrypter: OperationMetadataDecrypter) -> Operation {

        // Decrypt the metadata
        let metadata = try? decrypter.decrypt(operation: self)

        // Collect all the metadata fields
        let description = metadata?.description ?? self.description

        return Operation(id: id,
                         requestId: requestId,
                         isExternal: isExternal,
                         direction: direction.toModel(),
                         senderProfile: senderProfile?.toModel(),
                         senderIsExternal: senderIsExternal,
                         receiverProfile: receiverProfile?.toModel(),
                         receiverIsExternal: receiverIsExternal,
                         receiverAddress: receiverAddress,
                         receiverAddressDerivationPath: receiverAddressDerivationPath,
                         amount: amount.toModel(),
                         fee: fee.toModel(),
                         confirmations: confirmations,
                         exchangeRatesWindowId: exchangeRatesWindowId,
                         description: description,
                         status: status.toModel(),
                         transaction: transaction?.toModel(),
                         creationDate: creationDate,
                         submarineSwap: swap?.toModel(),
                         outpoints: outpoints)
    }

}

extension OperationDirection: APIConvertible {

    func toJson() -> OperationDirectionJson {

        switch self {

        case .INCOMING: return .INCOMING
        case .OUTGOING: return .OUTGOING
        case .CYCLICAL: return .CYCLICAL
        }
    }

}

extension OperationDirectionJson: ModelConvertible {

    public func toModel() -> OperationDirection {

        switch self {

        case .INCOMING: return .INCOMING
        case .OUTGOING: return .OUTGOING
        case .CYCLICAL: return .CYCLICAL
        }
    }

}

extension MuunOutputJson: ModelConvertible {

    public func toModel() -> MuunOutput {
        return MuunOutput(txId: txId, index: index, amount: amount)
    }

}

extension MuunAddressJson: ModelConvertible {

    public func toModel() -> MuunAddress {
        return MuunAddress(version: version, derivationPath: derivationPath, address: address)
    }

}

extension MuunAddress: APIConvertible {

    func toJson() -> MuunAddressJson {
        return MuunAddressJson(version: _version, derivationPath: _derivationPath, address: _address)
    }

}

extension SignatureJson: ModelConvertible {

    public func toModel() -> Signature {
        return Signature(hex: hex)
    }

}

extension MuunInputJson: ModelConvertible {

    public func toModel() -> MuunInput {
        return MuunInput(prevOut: prevOut.toModel(),
                         address: address.toModel(),
                         userSignature: userSignature?.toModel(),
                         muunSignature: muunSignature?.toModel(),
                         submarineSwapV1: submarineSwap?.toModel(),
                         submarineSwapV2: submarineSwapV102?.toModel())
    }

}

extension InputSubmarineSwapV1Json: ModelConvertible {

    public func toModel() -> InputSubmarineSwapV1 {
        return InputSubmarineSwapV1(refundAddress: refundAddress,
                                    paymentHash256: Data(hex: swapPaymentHash256Hex),
                                    serverPublicKey: Data(hex: swapServerPublicKeyHex),
                                    locktime: lockTime)
    }

}

extension InputSubmarineSwapV2Json: ModelConvertible {

    public func toModel() -> InputSubmarineSwapV2 {
        let sig = swapServerSignature.map({ Data(hex: $0.hex) })
        return InputSubmarineSwapV2(paymentHash256: Data(hex: swapPaymentHash256Hex),
                                    userPublicKey: Data(hex: userPublicKeyHex),
                                    muunPublicKey: Data(hex: muunPublicKeyHex),
                                    serverPublicKey: Data(hex: swapServerPublicKeyHex),
                                    blocksForExpiration: Int64(numBlocksForExpiration),
                                    serverSignature: sig)
    }

}

extension PartiallySignedTransactionJson: ModelConvertible {

    public func toModel() -> PartiallySignedTransaction {
        return PartiallySignedTransaction(hexTransaction: hexTransaction,
                                          inputs: inputs.map({ $0.toModel() }))
    }

}

extension OperationCreatedJson: ModelOperationConvertible {

    public func toModel(decrypter: OperationMetadataDecrypter) -> OperationCreated {
        return OperationCreated(operation: operation.toModel(decrypter: decrypter),
                                partiallySignedTransaction: partiallySignedTransaction.toModel(),
                                nextTransactionSize: nextTransactionSize.toModel(),
                                change: changeAddress?.toModel())
    }

}

extension FeeWindowJson: ModelConvertible {

    public func toModel() -> FeeWindow {
        var newTargetedFees: [UInt: FeeRate] = [:]
        for value in targetedFees {
            newTargetedFees[UInt(value.key)] = FeeRate(satsPerWeightUnit: Decimal(value.value))
        }

        return FeeWindow(
            id: id,
            fetchDate: fetchDate,
            targetedFees: newTargetedFees,
            fastConfTarget: fastConfTarget,
            mediumConfTarget: mediumConfTarget,
            slowConfTarget: slowConfTarget
        )
    }

}

extension ExchangeRateWindowJson: ModelConvertible {

    public func toModel() -> ExchangeRateWindow {
        return ExchangeRateWindow(id: id,
                                  fetchDate: fetchDate,
                                  rates: rates)
    }

}

extension RealTimeDataJson: ModelConvertible {

    public func toModel() -> RealTimeData {
        return RealTimeData(feeWindow: feeWindow.toModel(),
                            exchangeRateWindow: exchangeRateWindow.toModel(),
                            currentBlockchainHeight: currentBlockchainHeight)
    }

}

extension ContactJson: ModelConvertible {

    public func toModel() -> Contact {
        return Contact(publicProfile: publicProfile.toModel(),
                       maxAddressVersion: maxAddressVersion,
                       publicKey: publicKey.toModel(),
                       cosigningPublicKey: cosigningPublicKey.toModel(),
                       lastDerivationIndex: lastDerivationIndex)
    }

}

extension LinkAction: APIConvertible {

    func toJson() -> LinkActionJson {
        return LinkActionJson(uuid: uuid)
    }

}

extension SubmarineSwapRequest: APIConvertible {

    func toJson() -> SubmarineSwapRequestJson {
        return SubmarineSwapRequestJson(invoice: _invoice, swapExpirationInBlocks: _swapExpirationInBlocks)
    }

}

extension LappJson: ModelConvertible {

    func toModel() -> Lapp {
        return Lapp(name: name, description: description, image: image, link: link)
    }

}

extension Array: ModelConvertible where Element: ModelConvertible {

    typealias Output = [Element.Output]

    func toModel() -> [Element.Output] {
        return map({ $0.toModel() })
    }

}

extension Array: ModelOperationConvertible where Element: ModelOperationConvertible {

    typealias OperationOutput = [Element.OperationOutput]

    func toModel(decrypter: OperationMetadataDecrypter) -> [Element.OperationOutput] {
        return map({ $0.toModel(decrypter: decrypter) })
    }

}

// swiftlint:enable cyclomatic_complexity
// swiftlint:enable file_length
