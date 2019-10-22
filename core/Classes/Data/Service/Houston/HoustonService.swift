//
//  HoustonService.swift
//  falcon
//
//  Created by Manu Herrera on 23/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import RxSwift

public class HoustonService: BaseService {

    init(preferences: Preferences, urlSession: URLSession, sessionRepository: SessionRepository) {
        super.init(preferences: preferences,
                   urlSession: urlSession,
                   sessionRepository: sessionRepository,
                   sendAuth: true)
    }

    override public func getBaseURL() -> String {
        return Environment.current.houstonURL
    }

    // ---------------------------------------------------------------------------------------------
    // Authentication and Sessions:

    func createSession(session: Session) -> Single<CreateSessionOk> {
        let jsonData = data(from: session)

        return post("sessions", body: jsonData, andReturn: CreateSessionOkJson.self)
            .map({ $0.toModel() })
    }

    func resendVerificationCode(verificationType: VerificationType) -> Single<()> {
        let jsonData = data(from: verificationType)

        return post("sessions/current/resend-code", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func confirmPhone(phoneConfirmation: PhoneConfirmation) -> Single<PhoneConfirmation> {
        let jsonData = data(from: phoneConfirmation)

        return put("sessions/current/confirm-phone", body: jsonData, andReturn: PhoneConfirmationJson.self)
            .map({ $0.toModel() })
    }

    func signup(signupObject: Signup) -> Single<SignupOk> {
        let jsonData = data(from: signupObject)

        return post("sign-up", body: jsonData, andReturn: SignupOkJson.self)
            .map({ $0.toModel() })
    }

    func updateGcmToken(gcmToken: String) -> Single<()> {
        guard let data = gcmToken.data(using: .utf8) else {
            fatalError("Cant encode value for key")
        }

        return put("sessions/current/gcm-token", body: data, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func fetchNotificationsAfter(notificationId: Int?) -> Single<[Notification]> {
        var queryParams: [String: Any] = [:]

        if let nId = notificationId {
            queryParams = ["after": nId]
        }

        return get("sessions/notifications", queryParams: queryParams, andReturn: [NotificationJson].self)
            .map({ $0.toModel() })
    }

    func confirmNotificationsDeliveryUntil(notificationId: Int) -> Completable {
        let queryParams = ["until": notificationId]

        return put("sessions/notifications/confirm",
                   body: Data(),
                   queryParams: queryParams,
                   andReturn: EmptyJson.self)
            .asCompletable()
    }

    func requestChallenge(challengeType: String) -> Single<Challenge> {
        let queryParams = ["type": challengeType]

        return get("user/challenge", queryParams: queryParams, andReturn: ChallengeJson.self)
            .map({ $0.toModel() })
    }

    func setupChallenge(challengeSetup: ChallengeSetup) -> Single<SetupChallengeResponse> {
        let jsonData = data(from: challengeSetup)

        return post("user/challenge/setup", body: jsonData, andReturn: SetupChallengeResponseJson.self)
            .map({ $0.toModel() })
    }

    func logIn(challengeSignature: ChallengeSignature) -> Single<KeySet> {
        let jsonData = data(from: challengeSignature)

        return post("sessions/current/login", body: jsonData, andReturn: KeySetJson.self)
            .map({ $0.toModel() })
    }

    func notifyLogout() -> Completable {
        return post("sessions/logout", andReturn: EmptyJson.self).asCompletable()
    }

    func authorizeSession(linkAction: LinkAction) -> Single<()> {
        let jsonData = data(from: linkAction)

        return post("sessions/current/authorize", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func sendEncryptedKeysEmail(encryptedKey: SendEncryptedKeys) -> Single<()> {
        let jsonData = data(from: encryptedKey)

        return post("user/export-keys", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // User and Profile:

    func fetchUserInfo() -> Single<User> {
        return get("user", andReturn: UserJson.self)
            .map({ $0.toModel() })
    }

    func fetchKeySet(challengeType: String, signature: String) -> Single<KeySet> {
        let queryParams = ["challenge_type": challengeType,
                           "challenge_signature": signature]

        return get("user/key-set", queryParams: queryParams, andReturn: KeySetJson.self)
            .map({ $0.toModel() })
    }

    func updatePublicKeySet(publicKey: WalletPublicKey) -> Single<PublicKeySet> {
        let jsonData = data(from: PublicKeySet(basePublicKey: publicKey))

        return put("user/public-key-set", body: jsonData, andReturn: PublicKeySetJson.self)
            .map({ $0.toModel() })
    }

    func fetchExternalAddressesRecord() -> Single<ExternalAddressesRecord> {
        return get("user/external-addresses-record", andReturn: ExternalAddressesRecordJson.self)
            .map({ $0.toModel() })
    }

    func update(externalAddressesRecord: ExternalAddressesRecord)
        -> Single<ExternalAddressesRecord> {
        let jsonData = data(from: externalAddressesRecord)

        return put("user/external-addresses-record", body: jsonData, andReturn: ExternalAddressesRecordJson.self)
            .map({ $0.toModel() })
    }

    func updateUser(user: User) -> Single<User> {
        let jsonData = data(from: user)

        return patch("user", body: jsonData, andReturn: UserJson.self)
            .map({ $0.toModel() })
    }

    func updateCurrency(user: User) -> Single<User> {
        let jsonData = data(from: user)

        return post("user/currency", body: jsonData, andReturn: UserJson.self)
            .map({ $0.toModel() })
    }

    func beginPasswordChange(challengeSignature: ChallengeSignature) -> Single<PendingChallengeUpdate> {
        let jsonData = data(from: challengeSignature)

        return post("user/password", body: jsonData, andReturn: PendingChallengeUpdateJson.self)
            .map({ $0.toModel() })
    }

    func finishPasswordChange(challengeUpdate: ChallengeUpdate) -> Single<SetupChallengeResponse> {
        let jsonData = data(from: challengeUpdate)

        return post("user/password/finish", body: jsonData, andReturn: SetupChallengeResponseJson.self)
            .map({ $0.toModel() })
    }

    func submitFeedback(feedback: String) -> Single<()> {
        let payload = FeedbackJson(content: feedback)
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            fatalError("ERROR")
        }

        return post("user/feedback", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // Contacts:

    func fetchContacts() -> Single<[Contact]> {
        return get("contacts", andReturn: [ContactJson].self)
            .map({ $0.toModel() })
    }

    func fetchContact(contactId: Double) -> Single<Contact> {
        let path = "contacts/{contactId}"
        let finalPath = path.replacingOccurrences(of: "{contactId}", with: String(describing: contactId))

        return get(finalPath, andReturn: ContactJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // Real-time data and Operations:

    func fetchRealTimeData() -> Single<RealTimeData> {
        return get("realtime", andReturn: RealTimeDataJson.self)
            .map({ $0.toModel() })
    }

    func fetchOperations() -> Single<[Operation]> {
        return get("operations", andReturn: [OperationJson].self)
            .map({ $0.toModel() })
    }

    func newOperation(operation: Operation) -> Single<OperationCreated> {
        return post("operations", body: data(from: operation), andReturn: OperationCreatedJson.self)
            .map({ $0.toModel() })
    }

    func pushTransaction(rawTransaction: RawTransaction, operationId: Int) -> Single<RawTransactionResponse> {
        let jsonData = data(from: rawTransaction)

        let path = "operations/{operationId}/raw-transaction"
        let finalPath = path.replacingOccurrences(of: "{operationId}", with: String(describing: operationId))

        return put(finalPath, body: jsonData, andReturn: RawTransactionResponseJson.self)
            .map({ $0.toModel() })
    }

    func fetchNextTransactionSize() -> Single<NextTransactionSize> {
        return get("operations/next-transaction-size", andReturn: NextTransactionSizeJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // Submarine swaps:

    func createSubmarineSwap(submarineSwapRequest: SubmarineSwapRequest) -> Single<SubmarineSwap> {
        let jsonData = data(from: submarineSwapRequest)

        return post("operations/sswap/create", body: jsonData, andReturn: SubmarineSwapJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // Other endpoints:

    func checkIntegrity(request: IntegrityCheck) -> Single<IntegrityStatus> {
        return post("integrity/check", body: data(from: request), andReturn: IntegrityStatusJson.self)
            .map({ $0.toModel() })
    }

}

private struct Container<T>: Codable where T: Codable {
    let value: T
}
