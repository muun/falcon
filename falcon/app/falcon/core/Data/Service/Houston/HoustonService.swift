//
//  HoustonService.swift
//  falcon
//
//  Created by Manu Herrera on 23/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift

public class HoustonService: BaseService {

    private let decrypter: OperationMetadataDecrypter

    init(preferences: Preferences,
         urlSession: URLSession,
         sessionRepository: SessionRepository,
         debugRequestRepository: DebugRequestsRepository,
         deviceCheckTokenProvider: DeviceCheckTokenProvider,
         backgroundExecutionMetricsProvider: BackgroundExecutionMetricsProvider,
         decrypter: OperationMetadataDecrypter) {

        self.decrypter = decrypter

        super.init(preferences: preferences,
                   urlSession: urlSession,
                   sessionRepository: sessionRepository,
                   debugRequestsRepository: debugRequestRepository,
                   deviceCheckTokenProvider: deviceCheckTokenProvider,
                   backgroundExecutionMetricsProvider: backgroundExecutionMetricsProvider,
                   sendAuth: true)
    }

    override public func getBaseURL() -> String {
        return Environment.current.houstonURL
    }

    // ---------------------------------------------------------------------------------------------
    // Authentication and Sessions:

    func createSession(session: CreateLoginSession) -> Single<CreateSessionOk> {
        let jsonData = JSONEncoder.data(from: session)

        return post("sessions-v2/login", body: jsonData, andReturn: CreateSessionOkJson.self)
            .map({ $0.toModel() })
    }

    func createFirstSession(firstSession: CreateFirstSession) -> Single<CreateFirstSessionOk> {
        let jsonData = JSONEncoder.data(from: firstSession)

        return post("sessions-v2/first",
                    body: jsonData,
                    andReturn: CreateFirstSessionOkJson.self,
                    shouldForceDeviceCheckToken: true)
        .map({ $0.toModel() })
    }

    func resendVerificationCode(verificationType: VerificationType) -> Single<()> {
        let jsonData = JSONEncoder.data(from: verificationType)

        return post("sessions/current/resend-code", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func confirmPhone(phoneConfirmation: PhoneConfirmation) -> Single<PhoneConfirmation> {
        let jsonData = JSONEncoder.data(from: phoneConfirmation)

        return put("sessions/current/confirm-phone", body: jsonData, andReturn: PhoneConfirmationJson.self)
            .map({ $0.toModel() })
    }

    func setUpPassword(_ passwordSetup: PasswordSetup) -> Single<()> {
        let jsonData = JSONEncoder.data(from: passwordSetup)

        return post("sessions-v2/password", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func startEmailSetup(_ emailSetup: StartEmailSetup) -> Single<()> {
        let jsonData = JSONEncoder.data(from: emailSetup)

        return post("sessions-v2/email/start", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func updateGcmToken(gcmToken: String) -> Single<()> {
        guard let data = gcmToken.data(using: .utf8) else {
            fatalError("Cant encode value for key")
        }

        return put("sessions/current/gcm-token",
                   body: data,
                   andReturn: EmptyJson.self,
                   maxRetries: 5)
        .map({ $0.toModel() })
    }

    public func fetchNotification(notificationId: Int) -> Single<Notification?> {
        return get("sessions/notifications/\(notificationId)", andReturn: NotificationJson.self)
            .map({ $0.toModel(decrypter: self.decrypter) })
    }

    func fetchNotificationReportAfter(notificationId: Int?) -> Single<NotificationReport> {
        var queryParams: [String: Any] = [:]

        if let nId = notificationId {
            queryParams = ["after": nId]
        }

        return get("sessions/notification_report", queryParams: queryParams, andReturn: NotificationReportJson.self)
            .map({ $0.toModel(decrypter: self.decrypter) })
    }

    func confirmNotificationsDeliveryUntil(notificationId: Int,
                                           deviceModel: String,
                                           osVersion: String,
                                           appStatus: String) -> Completable {
        let queryParams: [String: Any] = [
            "until": notificationId,
            "deviceModel": deviceModel,
            "osVersion": osVersion,
            "appStatus": appStatus
        ]

        return put("sessions/notifications/confirm",
                   body: Data(),
                   queryParams: queryParams,
                   andReturn: EmptyJson.self)
            .asCompletable()
    }

    func requestChallenge(challengeType: String) -> Single<Challenge?> {
        let queryParams = ["type": challengeType]

        return get("user/challenge", queryParams: queryParams, andReturn: ChallengeJson.self)
            .map({ $0.toModel() })
    }

    func setupChallenge(challengeSetup: ChallengeSetup) -> Single<SetupChallengeResponse> {
        let jsonData = JSONEncoder.data(from: challengeSetup)

        return post("user/challenge/setup", body: jsonData, andReturn: SetupChallengeResponseJson.self)
            .map({ $0.toModel() })
    }
    
    func startChallenge(challengeSetup: ChallengeSetup) -> Single<SetupChallengeResponse> {
        let jsonData = JSONEncoder.data(from: challengeSetup)

        return post("user/challenge/setup/start", body: jsonData, andReturn: SetupChallengeResponseJson.self)
            .map({ $0.toModel() })
    }
    
    func finishChallenge(challengeType: ChallengeType, challengeSetupPublicKey: String) -> Completable {
        precondition(challengeType == .RECOVERY_CODE)

        let challengeSetup = ChallengeSetupVerifyJson(type: ChallengeTypeJson.RECOVERY_CODE,
                                                      publicKey: challengeSetupPublicKey)
        
        let jsonData = JSONEncoder.data(json: challengeSetup)

        return post("user/challenge/setup/finish", body: jsonData, andReturn: EmptyJson.self).asCompletable()
    }

    func logIn(loginJson: LoginJson) -> Single<KeySet> {
        let jsonData = JSONEncoder.data(json: loginJson)

        return post("sessions/current/login",
                    body: jsonData,
                    andReturn: KeySetJson.self,
                    shouldForceDeviceCheckToken: true)
            .map({ $0.toModel() })
    }

    func publicStatus() -> Single<()> {
        return get("public/status", andReturn: EmptyJson.self).map({ $0.toModel() })
    }

    func loginCompatWithoutChallenge() -> Single<KeySet> {
        return post("sessions/current/login/compat", andReturn: KeySetJson.self)
            .map({ $0.toModel() })
    }

    // Create session for an existing user with a given recovery code.
    func createRecoveryCodeLoginSession(_ rcLoginSession: CreateRcLoginSession) -> Single<(Challenge)> {
        let jsonData = JSONEncoder.data(from: rcLoginSession)

        return post("sessions-v2/recovery-code/start",
                    body: jsonData,
                    andReturn: ChallengeJson.self,
                    shouldForceDeviceCheckToken: true)
            .map({ $0.toModel() })
    }

    // Login using recovery code only flow (may need email auth, if email setup).
    func loginWithRecoveryCode(_ signature: ChallengeSignature) -> Single<(CreateSessionRcOk)> {
        let jsonData = JSONEncoder.data(from: signature)

        return post("sessions-v2/recovery-code/finish", body: jsonData, andReturn: CreateSessionRcOkJson.self)
            .map({ $0.toModel() })
    }

    func authorizeLoginWithRecoveryCode(linkAction: LinkAction) -> Single<()> {
        let jsonData = JSONEncoder.data(from: linkAction)

        return post("sessions-v2/recovery-code/authorize", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func fetchKeySet() -> Single<KeySet> {
        return get("sessions-v2/current/key-set", andReturn: KeySetJson.self)
            .map({ $0.toModel() })
    }

    func notifyLogout() -> Completable {
        return post("sessions/logout", andReturn: EmptyJson.self).asCompletable()
    }

    func authorizeSession(linkAction: LinkAction) -> Single<()> {
        let jsonData = JSONEncoder.data(from: linkAction)

        return post("sessions/current/authorize", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func verifySignUp(linkAction: LinkAction) -> Single<()> {
        let jsonData = JSONEncoder.data(from: linkAction)

        return post("sessions-v2/email/finish", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func sendEncryptedKeysEmail(encryptedKey: SendEncryptedKeys) -> Single<()> {
        let jsonData = JSONEncoder.data(from: encryptedKey)

        return post("user/export-keys", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // User and Profile:

    func fetchUserInfo() -> Single<(User, UserPreferences)> {
        return get("user", andReturn: UserJson.self)
            .map({
                ($0.toModel(), $0.preferences!)
            })
    }

    func fetchKeySet(challengeType: String, signature: String) -> Single<KeySet> {
        let queryParams = ["challenge_type": challengeType,
                           "challenge_signature": signature]

        return get("user/key-set", queryParams: queryParams, andReturn: KeySetJson.self)
            .map({ $0.toModel() })
    }

    func updatePublicKeySet(publicKey: WalletPublicKey) -> Single<PublicKeySet> {
        let jsonData = JSONEncoder.data(from: PublicKeySet(basePublicKey: publicKey))

        return put("user/public-key-set", body: jsonData, andReturn: PublicKeySetJson.self)
            .map({ $0.toModel() })
    }

    func fetchExternalAddressesRecord() -> Single<ExternalAddressesRecord> {
        return get("user/external-addresses-record", andReturn: ExternalAddressesRecordJson.self)
            .map({ $0.toModel() })
    }

    func update(externalAddressesRecord: ExternalAddressesRecord)
        -> Single<ExternalAddressesRecord> {
        let jsonData = JSONEncoder.data(from: externalAddressesRecord)

        return put("user/external-addresses-record", body: jsonData, andReturn: ExternalAddressesRecordJson.self)
            .map({ $0.toModel() })
    }

    func updateUser(user: User) -> Single<User> {
        let jsonData = JSONEncoder.data(from: user)

        return patch("user", body: jsonData, andReturn: UserJson.self)
            .map({ $0.toModel() })
    }

    func updateCurrency(user: User) -> Single<User> {
        let jsonData = JSONEncoder.data(from: user)

        return post("user/currency", body: jsonData, andReturn: UserJson.self)
            .map({ $0.toModel() })
    }

    func beginPasswordChange(challengeSignature: ChallengeSignature) -> Single<PendingChallengeUpdate> {
        let jsonData = JSONEncoder.data(from: challengeSignature)

        return post("user/password", body: jsonData, andReturn: PendingChallengeUpdateJson.self)
            .map({ $0.toModel() })
    }

    func verifyChangePassword(linkAction: LinkAction) -> Single<()> {
        let jsonData = JSONEncoder.data(from: linkAction)

        return post("user/password/authorize", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func finishPasswordChange(challengeUpdate: ChallengeUpdate) -> Single<SetupChallengeResponse> {
        let jsonData = JSONEncoder.data(from: challengeUpdate)

        return post("user/password/finish", body: jsonData, andReturn: SetupChallengeResponseJson.self)
            .map({ $0.toModel() })
    }

    func submitFeedback(feedback: String, type: FeedbackTypeJson) -> Single<()> {
        let payload = FeedbackJson(content: feedback, type: type)
        // swiftlint:disable force_error_handling
        guard let jsonData = try? JSONEncoder().encode(payload) else {
            fatalError("ERROR")
        }

        return post("user/feedback", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func setEmergencyKitExported(exportEmergencyKit: ExportEmergencyKit) -> Single<()> {
        let jsonData = JSONEncoder.data(from: exportEmergencyKit)

        return post("user/emergency-kit/exported", body: jsonData, andReturn: EmptyJson.self)
            .map({ $0.toModel() })
    }

    func updateUserPreferences(_ preferences: UserPreferences) -> Completable {
        let jsonData = JSONEncoder.data(json: preferences)
        
        return put("user/preferences", body: jsonData, andReturn: EmptyJson.self)
            .asCompletable()
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
    // Real-time data:

    func fetchRealTimeData() -> Single<RealTimeData> {
        return get("realtime", andReturn: RealTimeDataJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // Real-time fees:
    func fetchRealTimeFees(realTimeFeesRequest: RealTimeFeesRequestJson) -> Single<RealTimeFees> {
        return post(
            "realtime/fees",
            body: JSONEncoder.data(json: realTimeFeesRequest),
            andReturn: RealTimeFeesJson.self
        ).map { $0.toModel() }
    }

    // ---------------------------------------------------------------------------------------------
    // Operations:

    func fetchOperations() -> Single<[Operation]> {
        return get("operations", andReturn: [OperationJson].self)
            .map({
                $0.map({ operationJson in operationJson.toModel(decrypter: self.decrypter) })
            })
    }

    func newOperation(operation: OperationJson) -> Single<OperationCreated> {
        return post(
            "operations",
            body: JSONEncoder.data(json: operation),
            andReturn: OperationCreatedJson.self,
            maxRetries: 1 // Due to nonce reuse attacks we never retry this endpoint automatically
        ).map({ $0.toModel(decrypter: self.decrypter) })
    }

    func updateOperationMetadata(operationId: Int, metadata: String) -> Completable {
        let path = "operations/{operationId}/metadata"
            .replacingOccurrences(of: "{operationId}", with: String(describing: operationId))

        let json = UpdateOperationMetadataJson(receiverMetadata: metadata)

        return put(path, body: JSONEncoder.data(json: json), andReturn: EmptyJson.self)
            .asCompletable()
    }

    func pushTransactions(
        rawTransaction: RawTransaction?,
        alternativeTransactions: [RawTransaction],
        operationId: Int
    ) -> Single<RawTransactionResponse> {
        let jsonData = JSONEncoder.data(json: PushTransactionsJson(
            rawTransaction: rawTransaction?.toJson(),
            alternativeTransactions: alternativeTransactions.toJson()
        ))

        let path = "operations/{operationId}/raw-transactions"
        let finalPath = path.replacingOccurrences(of: "{operationId}", with: String(describing: operationId))

        return put(
            finalPath,
            body: jsonData,
            andReturn: RawTransactionResponseJson.self,
            maxRetries: 1 // Due to nonce reuse attacks we never retry this endpoint automatically
        )
        .map({ $0.toModel(decrypter: self.decrypter) })
    }

    func fetchNextTransactionSize() -> Single<NextTransactionSize> {
        return get("operations/next-transaction-size", andReturn: NextTransactionSizeJson.self)
            .map({ $0.toModel() })
    }

    // ---------------------------------------------------------------------------------------------
    // Submarine swaps:

    func createSubmarineSwap(submarineSwapRequest: SubmarineSwapRequest) -> Single<SubmarineSwapCreated> {
        let jsonData = JSONEncoder.data(from: submarineSwapRequest)

        return post("operations/sswap/create", body: jsonData, andReturn: SubmarineSwapJson.self)
            .map({
                SubmarineSwapCreated(
                    swap: $0.toModel(),
                    maxAlternativeTransactionCount: $0.maxAlternativeTransactionCount
                )
            })
    }

    // ---------------------------------------------------------------------------------------------
    // Incoming swaps:

    func registerInvoices(_ invoices: [UserInvoiceJson]) -> Completable {
        let jsonData = JSONEncoder.data(json: invoices)

        return post("incoming-swaps/invoices", body: jsonData, andReturn: EmptyJson.self)
            .asCompletable()
    }

    func fetchFulfillmentData(for uuid: String) -> Single<IncomingSwapFulfillmentData> {
        return post("incoming-swaps/\(uuid)/fulfillment", andReturn: IncomingSwapFulfillmentDataJson.self)
            .map({ $0.toModel() })
    }

    func pushFulfillmentTransaction(rawTransaction: RawTransaction, incomingSwap: String) -> Single<FulfillmentPushed> {
        let jsonData = JSONEncoder.data(from: rawTransaction)

        let path = "incoming-swaps/\(incomingSwap)/fulfillment"
        return put(path, body: jsonData, andReturn: FulfillmentPushedJson.self)
            .map({ $0.toModel() })
    }

    func expireInvoice(_ invoiceHex: String) -> Completable {
        return delete("incoming-swaps/invoices/\(invoiceHex)", andReturn: EmptyJson.self)
            .asCompletable()
    }

    func fulfill(incomingSwap: String, preimage: Data) -> Completable {
        let jsonData = JSONEncoder.data(json: PreimageJson(hex: preimage.toHexString()))
        return put("incoming-swaps/\(incomingSwap)", body: jsonData, andReturn: EmptyJson.self)
            .asCompletable()
    }

    // ---------------------------------------------------------------------------------------------
    // Other endpoints:

    func checkIntegrity(request: IntegrityCheck) -> Single<IntegrityStatus> {
        return post("integrity/check", body: JSONEncoder.data(from: request), andReturn: IntegrityStatusJson.self)
            .map({ $0.toModel() })
    }

    func fetchMuunKeyFingerprint() -> Single<String> {
        return get("migrations/fingerprints", andReturn: KeyFingerprintMigrationJson.self)
            .map({ $0.muunKeyFingerprint })
    }

}

private struct Container<T>: Codable where T: Codable {
    let value: T
}
