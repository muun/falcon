//
//  NotificationService.swift
//  falconPushNotifications
//
//  Created by Manu Herrera on 26/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UserNotifications
import Libwallet
import FirebaseCrashlytics
import Firebase

class NotificationService: UNNotificationServiceExtension {

    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?

    private var urlSession: URLSession = URLSession.shared

    private func tagFrom(key: String) -> Data {
        return (Identifiers.bundleId + "." + key).data(using: .utf8)!
    }

    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {

        if let firebaseOptions = FirebaseOptions(contentsOfFile: Environment.current.firebaseOptionsPath) {
            FirebaseApp.configure(options: firebaseOptions)
        }

        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        Crashlytics.crashlytics().setCustomValue(request.content.userInfo, forKey: "notification")
        do {
            let report = try getNotificationReport(request.content.userInfo)
            try processNotification(report)
        } catch {
            sendError(error)

            // At least default to something!
            serviceExtensionTimeWillExpire()
        }
    }

    private func processNotification(_ notification: NotificationReportJson) throws {
        let preview = notification.message.preview
        if let notification = preview.first {
            showNotification(notification)
        } else {
            try fetchNotification(id: notification.message.maximumId)
        }

    }

    private func showNotification(_ notification: NotificationJson) {
        if let bestAttemptContent = bestAttemptContent,
           let contentHandler = contentHandler {

            let (title, body) = self.titleAndBody(notification: notification)
            bestAttemptContent.title = title
            bestAttemptContent.body = body

            contentHandler(bestAttemptContent)
        }
    }

    private func getNotificationReport(_ userInfo: [AnyHashable: Any]) throws -> NotificationReportJson {
        if let aps = userInfo["aps"] as? [String: Any],
           let alertReport = aps["alert"] as? [String: Any],
           let data = try? JSONSerialization.data(withJSONObject: alertReport, options: []) {
            return try getDecoded(data: data)
        } else {
            return try getNotificationReportLegacy(userInfo)
        }
    }

    private func getDecoded(data: Data) throws -> NotificationReportJson {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        do {
            return try decoder.decode(NotificationReportJson.self, from: data)
        } catch {
            throw InvalidNotificationStructureError()
        }
    }

    private func getNotificationReportLegacy(_ userInfo: [AnyHashable: Any]) throws -> NotificationReportJson {
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? String,
           let data = alert.data(using: .utf8) {

            return try getDecoded(data: data)
        }
        throw InvalidNotificationStructureError()
    }

    // We can't split an enum and we can't reduce the number of notifications
    // so we disable the check
    // swiftlint:disable cyclomatic_complexity
    private func titleAndBody(notification: NotificationJson) -> (title: String, body: String) {
        switch notification.message {

        case .sessionAuthorized:
            return ("Session", "Authorized")

        case .newOperation(let op):
            return message(newOp: op.operation)

        case .operationUpdate:
            return ("Operation", "Update")

        case .unknownMessage:
            return ("You have a new notification", "")

        case .fulfillIncomingSwap:
            return (
                L10n.NotificationService.fulfillIncomingSwapTitle,
                L10n.NotificationService.fulfillIncomingSwapBody
            )

        // These are here for future compatibility
        case .newContact:
            return ("New contact", "%s has just landed on Muun!")

        case .expiredSession:
            return ("Expired", "Session")

        case .updateContact:
            return ("Update", "Contact")

        case .updateAuthorizeChallenge:
            return ("Update", "Authorize Challenge")

        case .authorizeRcSignIn:
            return ("Authorize", "Recovery code sign in")

        case .verifiedEmail:
            return ("Verified", "Email")

        case .completePairingAck:
            return ("Complete", "Pairing Ack")

        case .addHardwareWallet:
            return ("Add", "Hardware Wallet")

        case .withdrawalResult:
            return ("Withdeawal", "Result")

        case .getSatelliteState:
            return ("Get", "Satellite State")

        case .eventCommunication(let type):
            switch type {
            case .taprootActivated:
                return (
                    L10n.NotificationService.taprootActivatedTitle,
                    L10n.NotificationService.taprootActivatedBody
                )
            case .taprootPreactivation:
                return (
                    L10n.NotificationService.taprootPreactivationTitle,
                    L10n.NotificationService.taprootPreactivationBody
                )
            }

        case .noOp:
            return ("No op", "No op")
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func message(newOp: OperationJson) -> (title: String, body: String) {
        // swiftlint:disable avoid_legacy_currency_formatter_ussage
        let amount = MonetaryAmount(amount: newOp.amount.inInputCurrency.amount,
                                    currency: newOp.amount.inInputCurrency.currency)!
        let amountString = "\(LocaleAmountFormatter.string(from: amount)) \(amount.currency)"
        // swiftlint:enable avoid_legacy_currency_formatter_ussage
        if newOp.direction == .OUTGOING {
            return (L10n.NotificationService.opSentTitle(amount), "")
        }

        let description: String
        do {
            description = try getDescription(from: newOp)
        } catch {
            sendError(error)
            description = ""
        }

        if let senderProfile = newOp.senderProfile {
            let title = L10n.NotificationService.opFromContactTitle(senderProfile.firstName, amountString)
            return (title, description)
        }

        return (L10n.NotificationService.opReceivedTitle(amountString), description)
    }

    private func getDescription(from op: OperationJson) throws -> String {

        let metadata: OperationMetadataJson?
        if let payload = op.receiverMetadata {
            // TODO: Extract the pubkey from somewhere
            let decrypter = try getPrivateKey().decrypter(from: nil)!
            let metadataJson = try decrypter.decrypt(payload)

            metadata = try decodeJson(metadataJson)
        } else {
            metadata = nil
        }

        return metadata?.description ?? op.description ?? ""
    }

    private func loadFromKeychain(_ tag: Data) throws -> String {
        let queryLoad: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrGeneric as String: tag,
            kSecAttrAccount as String: tag,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccessGroup as String: Identifiers.group,
            kSecAttrService as String: Identifiers.bundleId
        ]

        var result: AnyObject?

        if let str = String(data: tag, encoding: .utf8) {
            Crashlytics.crashlytics().log("Trying to fetch key with tag \(str)")
        }

        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }

        if resultCodeLoad == noErr {
            if let result = result as? Data,
                let keyValue = String(data: result, encoding: .utf8) {

                // Found successfully
                return keyValue
            } else {
                throw KeychainBadDataError(data: result)
            }
        }

        throw KeychainError(result: resultCodeLoad)
    }

    private func getAuthToken() throws -> String {
        return try loadFromKeychain(tagFrom(key: "authToken"))
    }

    private func getPrivateKey() throws -> LibwalletHDPrivateKey {
        let rawPrivKey = try loadFromKeychain(tagFrom(key: "privateKey"))
        let path = try loadFromKeychain(tagFrom(key: "baseKeyDerivationPath"))

        let network: LibwalletNetwork
        switch Environment.current {
        case .debug, .regtest:
            network = LibwalletRegtest()!
        case .dev:
            network = LibwalletTestnet()!
        case .stg, .prod:
            network = LibwalletMainnet()!
        }

        let privKey = try doWithError({ err in
            LibwalletNewHDPrivateKeyFromString(rawPrivKey, path, network, err)
        })

        return privKey
    }

    func fetchNotification(id: Int) throws {

        let urlString = "\(Environment.current.houstonURL)/sessions/notifications/\(id)"
        var request: URLRequest
        // The extension has about 30 secs of execution, so timeout at 28 so we can handle the error
        request = URLRequest(url: URL(string: urlString)!, timeoutInterval: TimeInterval(28))
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("\(Bundle.main.infoDictionary!["CFBundleVersion"]!)", forHTTPHeaderField: "X-Client-Version")
        request.addValue(Locale.current.languageCode ?? "en", forHTTPHeaderField: "X-Client-Language")
        request.addValue("FALCON", forHTTPHeaderField: "X-Client-Type")
        request.addValue(try getAuthToken(), forHTTPHeaderField: "Authorization")

        let dataTask = urlSession.dataTask(with: request) { (data, _, error) in

            do {
                if let error = error {
                    throw error
                }

                guard let data = data else {
                    throw EmptyDataError()
                }

                if let str = String(bytes: data, encoding: .utf8) {
                    Crashlytics.crashlytics().setCustomValue(str, forKey: "response")
                }

                let report: NotificationJson = try self.decodeJson(data)
                self.showNotification(report)
            } catch {
                sendError(error)

                // At least default to something!
                self.serviceExtensionTimeWillExpire()
            }

        }
        dataTask.resume()

    }

    private func decodeJson<T: Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601

        return try decoder.decode(T.self, from: data)
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content,
        // otherwise the original push payload will be used.

        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            bestAttemptContent.title = "New notification"
            bestAttemptContent.body = ""
            contentHandler(bestAttemptContent)
        }
    }

}

func doWithError<T>(_ f: (NSErrorPointer) throws -> T?) throws -> T {
    var err: NSError?
    let result = try f(&err)
    if let err = err {
        throw err
    }

    if let result = result {
        return result
    } else {
        throw DoWithErrors.nilResult
    }
}

enum DoWithErrors: Error {
    case nilResult
}

struct InvalidNotificationStructureError: Error {}
struct EmptyDataError: Error {}
struct KeychainError: Error, LocalizedError {
    let result: OSStatus

    var errorDescription: String? {
        return "KeychainError code = \(result)"
    }
}
struct KeychainBadDataError: Error, LocalizedError {
    let data: AnyObject?

    var errorDescription: String? {
        if let data = data as? Data {
            if let str = String(data: data, encoding: .utf8) {
                return "KeychainBadDataError data = \(str)"
            } else {
                let hex = Array(data).reduce("") {
                    var s = String($1, radix: 16)
                    if s.count == 1 {
                        s = "0" + s
                    }
                    return $0 + s
                }
                return "KeychainBadDataError data = \(hex)"
            }
        } else {
            return "KeychainBadDataError type = \(type(of: data)) " +
                "value = \(String(describing: data))"
        }
    }
}

private func sendError(_ error: Error) {
    let crashlytics = Crashlytics.crashlytics()
    crashlytics.setCustomValue(error.localizedDescription, forKey: "description")
    crashlytics.record(error: error)
    crashlytics.sendUnsentReports()
}
