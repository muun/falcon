//
//  AddressHelper.swift
//  falcon
//
//  Created by Manu Herrera on 04/01/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import Libwallet

public struct MuunPaymentURI {
    public let address: String?
    public let label: String?
    let message: String?
    let amount: Decimal?
    let others: [String: String]
    public let uri: URL
    public let bip70URL: String?
    let creationTime: String?
    let expiresTime: String?
}

public enum AddressHelper {

    static let muunScheme = "muun:"
    static let bitcoinScheme = "bitcoin:"

    public static func parse(_ raw: String) throws -> PaymentIntent {
        do {
            return try parse(rawAddress: raw)
        } catch {
            return try parse(rawInvoice: raw)
        }
    }

    public static func isValid(rawAddress: String) -> Bool {
        let uri = try? parse(rawAddress)
        if uri != nil {
            return true
        }

        return false
    }

    static func parse(rawAddress: String) throws -> PaymentIntent {
        let muunUri = try doWithError { error in
            LibwalletGetPaymentURI(rawAddress, Environment.current.network, error)
        }

        let address: String? = !muunUri.address.isEmpty ? muunUri.address : nil
        let bip70Url: String? = !muunUri.biP70Url.isEmpty ? muunUri.biP70Url : nil

        guard let actualUriString = muunUri.uri.trimmingCharacters(in: .whitespaces)
            .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: actualUriString) else {
                throw MuunError(ParseError.addressError)
        }

        let uri = MuunPaymentURI(address: address,
                                 label: muunUri.label,
                                 message: muunUri.message,
                                 amount: Decimal(string: muunUri.amount),
                                 others: [:],
                                 uri: url,
                                 bip70URL: bip70Url,
                                 creationTime: nil,
                                 expiresTime: nil)

        return .toAddress(uri: uri)
    }

    static func parse(rawInvoice: String) throws -> PaymentIntent {
        let invoice = try doWithError { error in
            LibwalletParseInvoice(rawInvoice, Environment.current.network, error)
        }

        return .submarineSwap(invoice: invoice)
    }

    private enum ParseError: Error {
        case addressError
    }

}
