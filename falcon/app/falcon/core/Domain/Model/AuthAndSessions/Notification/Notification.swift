//
//  NotificationJson.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

public struct Notification {

    let id: Int
    let previousId: Int
    let senderSessionUuid: String
    public let message: Message

    public enum Message {
        case sessionAuthorized
        case newOperation(NewOperation)
        case operationUpdate(OperationUpdate)
        case unknownMessage(type: String)
        case updateAuthorizeChallenge
        case authorizeRcSignIn
        case fulfillIncomingSwap(uuid: String)
        case eventCommunication(type: EventCommunicationType)

        // Empty one to be used by beam to fix broken id sequences
        case noOp

        // These are here for future compatibility
        case newContact
        case expiredSession
        case updateContact
        case verifiedEmail
        case completePairingAck
        case addHardwareWallet
        case withdrawalResult
        case getSatelliteState
    }

    public struct NewOperation {
        public let operation: Operation
        let nextTransactionSize: NextTransactionSize
    }

    public struct OperationUpdate {
        let id: Int
        let confirmations: Int
        let status: OperationStatus
        let hash: String?
        let nextTransactionSize: NextTransactionSize
        let swapDetails: SubmarineSwap?
    }

    public enum EventCommunicationType {
        case taprootActivated
        case taprootPreactivation
    }
}
