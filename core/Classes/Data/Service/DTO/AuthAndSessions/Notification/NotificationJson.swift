//
//  NotificationJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

// This is public for the notification extension
public struct NotificationJson {

    let id: Int
    let previousId: Int
    let senderSessionUuid: String
    public let message: MessagePayloadJson

    public enum MessagePayloadJson {
        case newOperation(NewOperationJson)
        case operationUpdate(OperationUpdateJson)
        case sessionAuthorized
        case unknownMessage(type: String)

        /// These are here to make Apollo users that sign in not loose notifications
        case newContact
        case expiredSession
        case updateContact
        case updateAuthorizeChallenge
        case verifiedEmail
        case completePairingAck
        case addHardwareWallet
        case withdrawalResult
        case getSatelliteState
    }

    public struct NewOperationJson: Decodable {
        public let operation: OperationJson
        let nextTransactionSize: NextTransactionSizeJson
    }

    public struct OperationUpdateJson: Decodable {
        let id: Int
        let confirmations: Int
        let status: OperationStatusJson
        let hash: String?
        let nextTransactionSize: NextTransactionSizeJson
        let swapDetails: SubmarineSwapJson?
    }
}

extension NotificationJson: Decodable {

    private enum CodingKeys: String, CodingKey {
        case id
        case previousId
        case senderSessionUuid
        case messageType
        case message
    }

    // We can't split an enum and we can't reduce the number of notifications
    // so we disable the check
    // swiftlint:disable cyclomatic_complexity
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(Int.self, forKey: .id)
        self.previousId = try container.decode(Int.self, forKey: .previousId)
        self.senderSessionUuid = try container.decode(String.self, forKey: .senderSessionUuid)

        let rawType = try container.decode(String.self, forKey: .messageType)
        switch rawType {

        case "operation/new":
            let message = try container.decode(NewOperationJson.self, forKey: .message)
            self.message = .newOperation(message)

        case "operations/update":
            let message = try container.decode(OperationUpdateJson.self, forKey: .message)
            self.message = .operationUpdate(message)

        case "sessions/authorized":
            self.message = .sessionAuthorized

        case "contact/new":
            self.message = .newContact

        case "session/expired":
            self.message = .expiredSession

        case "contact/update":
            self.message = .updateContact

        case "challenge/update/authorize":
            self.message = .updateAuthorizeChallenge

        case "users/email_verified":
            self.message = .verifiedEmail

        case "satellite/completePairingAck":
            self.message = .completePairingAck

        case "satellite/addHardwareWallet":
            self.message = .addHardwareWallet

        case "satellite/withdrawalResult":
            self.message = .withdrawalResult

        case "satellite/getState":
            self.message = .getSatelliteState

        default:
            self.message = .unknownMessage(type: rawType)
        }
    }
    // swiftlint:enable cyclomatic_complexity

}
