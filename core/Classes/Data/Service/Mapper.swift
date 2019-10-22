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
extension Session: APIConvertible {

    func toJson() -> SessionJson {
        return SessionJson(uuid: uuid,
                           requestId: requestId,
                           email: email,
                           buildType: buildType,
                           version: version,
                           gcmRegistrationToken: gcmRegistrationToken,
                           clientType: clientType)
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

extension Signup: APIConvertible {

    func toJson() -> SignupJson {
        return SignupJson(firstName: firstName,
                          lastName: lastName,
                          email: email,
                          primaryCurrency: primaryCurrency,
                          basePublicKey: basePublicKey.toJson(),
                          passwordChallengeSetup: passwordChallengeSetup.toJson())
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
        }
    }

}

extension SignupOk: APIConvertible {

    func toJson() -> SignupOkJson {
        return SignupOkJson(cosigningPublicKey: cosigningPublicKey.toJson())
    }

}

extension SignupOkJson: ModelConvertible {

    public func toModel() -> SignupOk {
        return SignupOk(cosigningPublicKey: cosigningPublicKey.toModel())
    }

}

extension NotificationJson: ModelConvertible {

    public func toModel() -> Notification {
        return Notification(id: id,
                            previousId: previousId,
                            senderSessionUuid: senderSessionUuid,
                            message: message.toModel())
    }

}

extension NotificationJson.MessagePayloadJson: ModelConvertible {

    public func toModel() -> Notification.Message {
        switch self {

        case .sessionAuthorized: return .sessionAuthorized

        case .newOperation(let newOperation): return .newOperation(newOperation.toModel())

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

extension NotificationJson.NewOperationJson: ModelConvertible {

    public func toModel() -> Notification.NewOperation {
        return Notification.NewOperation(operation: operation.toModel(),
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
                    hasP2PEnabled: hasP2PEnabled)
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
                        hasP2PEnabled: hasP2PEnabled)
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
                                   validAtOperationHid: validAtOperationHid)
    }

}

extension NextTransactionSize: APIConvertible {

    func toJson() -> NextTransactionSizeJson {
        return NextTransactionSizeJson(sizeProgression: sizeProgression.map({ $0.toJson() }),
                                       validAtOperationHid: validAtOperationHid)
    }

}

extension SizeForAmountJson: ModelConvertible {

    public func toModel() -> SizeForAmount {
        return SizeForAmount(amountInSatoshis: Satoshis(value: amountInSatoshis),
                             sizeInBytes: sizeInBytes)
    }

}

extension SizeForAmount: APIConvertible {

    func toJson() -> SizeForAmountJson {
        return SizeForAmountJson(amountInSatoshis: amountInSatoshis.value,
                                 sizeInBytes: sizeInBytes)
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
                             description: description,
                             status: status.toJson(),
                             transaction: transaction?.toJson(),
                             creationDate: creationDate,
                             outputAmountInSatoshis: outputAmountInSatoshis,
                             swapUuid: submarineSwap?._swapUuid,
                             swap: submarineSwap?.toJson())
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
        return SubmarineSwapFundingOutputJson(outputAddress: _outputAddress,
                                              outputAmountInSatoshis: _outputAmount.value,
                                              confirmationsNeeded: _confirmationsNeeded,
                                              userLockTime: _userLockTime,
                                              userRefundAddress: _userRefundAddress.toJson(),
                                              serverPaymentHashInHex: _serverPaymentHashInHex,
                                              serverPublicKeyInHex: _serverPublicKeyInHex)
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
        return SubmarineSwapFundingOutput(outputAddress: outputAddress,
                                          outputAmount: Satoshis(value: outputAmountInSatoshis),
                                          confirmationsNeeded: confirmationsNeeded,
                                          userLockTime: userLockTime,
                                          userRefundAddress: userRefundAddress.toModel(),
                                          serverPaymentHashInHex: serverPaymentHashInHex,
                                          serverPublicKeyInHex: serverPublicKeyInHex)
    }
}

extension OperationJson: ModelConvertible {

    public func toModel() -> Operation {
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
                         submarineSwap: swap?.toModel())
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
                         submarineSwap: submarineSwap?.toModel())
    }

}

extension InputSubmarineSwapJson: ModelConvertible {

    public func toModel() -> InputSubmarineSwap {
        return InputSubmarineSwap(refundAddress: refundAddress,
                                  paymentHash256: Data(hex: swapPaymentHash256Hex),
                                  serverPublicKey: Data(hex: swapServerPublicKeyHex),
                                  locktime: lockTime)
    }

}

extension PartiallySignedTransactionJson: ModelConvertible {

    public func toModel() -> PartiallySignedTransaction {
        return PartiallySignedTransaction(hexTransaction: hexTransaction,
                                          inputs: inputs.map({ $0.toModel() }))
    }

}

extension OperationCreatedJson: ModelConvertible {

    public func toModel() -> OperationCreated {
        return OperationCreated(operation: operation.toModel(),
                                partiallySignedTransaction: partiallySignedTransaction.toModel(),
                                nextTransactionSize: nextTransactionSize.toModel())
    }

}

extension FeeWindowJson: ModelConvertible {

    public func toModel() -> FeeWindow {
        var newTargetedFees: [UInt: FeeRate] = [:]
        for value in targetedFees {
            newTargetedFees[UInt(value.key)] = FeeRate(satsPerWeightUnit: Decimal(value.value))
        }

        return FeeWindow(id: id,
                         fetchDate: fetchDate,
                         targetedFees: newTargetedFees)
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
// swiftlint:enable cyclomatic_complexity
// swiftlint:enable file_length
