//
//  OperationFormatter.swift
//  falcon
//
//  Created by Juan Pablo Civile on 29/03/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import UIKit
import core

struct OperationFormatter {

    let operation: core.Operation

    enum Status {
        case COMPLETED
        case PENDING
        case FAILED
        case CANCELABLE
        case CONFIRMING
    }

    var simpleStatus: Status {
        // Only incoming operations can be cancelable in the UI
        if operation.isCancelable() && operation.direction == .INCOMING {
            return .CANCELABLE
        }

        switch operation.status {

        case .CREATED, .BROADCASTED, .SIGNING, .SIGNED, .SWAP_PENDING, .SWAP_ROUTING:
            return .PENDING

        case .DROPPED, .FAILED, .SWAP_FAILED, .SWAP_EXPIRED:
            return .FAILED

        case .CONFIRMED, .SETTLED, .SWAP_PAYED:
            return .COMPLETED

        case .SWAP_OPENING_CHANNEL, .SWAP_WAITING_CHANNEL:
            return .CONFIRMING
        }
    }

    var title: String {

        switch operation.direction {
        case .CYCLICAL:
            return L10n.OperationFormatter.s1
        case .INCOMING:
            if let metadata = operation.metadata,
               let sender = metadata.lnurlSender {
                return L10n.OperationFormatter.s10(sender)
            }
            return L10n.OperationFormatter.s2
        case .OUTGOING:
            var text = L10n.OperationFormatter.s3

            if let alias = operation.submarineSwap?._receiver._alias {
                text.append(" \(alias)")
            }
            return text
        }
    }

    var shortStatus: String {
        switch simpleStatus {
        case .PENDING, .CONFIRMING:
            return L10n.OperationFormatter.s4
        case .FAILED:
            return L10n.OperationFormatter.s5
        case .CANCELABLE:
            return L10n.OperationFormatter.cancelable
        case .COMPLETED:
            return ""
        }
    }

    var status: String {
        // Only incoming operations can be cancelable in the UI
        if operation.isCancelable() && operation.direction == .INCOMING {
            return L10n.OperationFormatter.cancelable
        }

        switch operation.status {
        case .CREATED, .BROADCASTED, .SIGNING, .SIGNED,
             .SWAP_PENDING, .SWAP_ROUTING, .SWAP_WAITING_CHANNEL, .SWAP_OPENING_CHANNEL:
            return L10n.OperationFormatter.s4
        case .DROPPED, .FAILED, .SWAP_FAILED, .SWAP_EXPIRED:
            return L10n.OperationFormatter.s5
        case .CONFIRMED, .SETTLED, .SWAP_PAYED:
            return L10n.OperationFormatter.s9
        }
    }

    var color: UIColor {
        switch simpleStatus {
        case .PENDING, .CONFIRMING:
            return Asset.Colors.muunWarning.color

        case .FAILED:
            return Asset.Colors.muunRed.color

        case .CANCELABLE:
            return Asset.Colors.muunWarningRBF.color

        case .COMPLETED:
            return Asset.Colors.muunGreen.color
        }
    }

    var shortCreationDate: String {
        return operation.creationDate.format(showTime: false)
    }

    var extendedCreationDate: String {
        return operation.creationDate.format(showTime: true)
    }

    var description: String? {
        return operation.description
    }

    var confirmations: String {
        if let confs = operation.confirmations {
            if confs < 6 {
                return String(describing: confs)
            }
            return "6+"
        }
        return "0"
    }
}
