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
    public let raw: String
}

public enum AddressHelper {

    static let muunScheme = "muun:"
    static let bitcoinScheme = "bitcoin:"

    public static func parse(_ raw: String) throws -> PaymentIntent {
        // swiftlint:disable force_error_handling
        if let address = try? parse(rawAddress: raw) {
            return address
        }
        // swiftlint:disable force_error_handling
        if let invoice = try? parse(rawInvoice: raw) {
            return invoice
        }
        if let lnurl = parse(lnurl: raw) {
            return lnurl
        }
        throw MuunError(ParseError.addressError)
    }

    public static func isValid(rawAddress: String) -> Bool {
        // swiftlint:disable force_error_handling
        let uri = try? parse(rawAddress)
        if uri != nil {
            return true
        }

        return false
    }

    public static func isValid(lnurl: String) -> Bool {
        return LibwalletLNURLValidate(lnurl)
    }

    static func parse(rawAddress: String) throws -> PaymentIntent {
        let muunUri = try doWithError { error in
            LibwalletGetPaymentURI(rawAddress, Environment.current.network, error)
        }

        if let invoice = muunUri.invoice {
            return .submarineSwap(invoice: invoice)
        }

        let address: String? = !muunUri.address.isEmpty ? muunUri.address : nil
        let bip70Url: String? = !muunUri.bip70Url.isEmpty ? muunUri.bip70Url : nil

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
                                 expiresTime: nil,
                                 raw: rawAddress)

        return .toAddress(uri: uri)
    }

    static func parse(rawInvoice: String) throws -> PaymentIntent {
        let invoice = try doWithError { error in
            LibwalletParseInvoice(rawInvoice, Environment.current.network, error)
        }

        return .submarineSwap(invoice: invoice)
    }

    static func parse(lnurl: String) -> PaymentIntent? {
        if LibwalletLNURLValidate(lnurl) {
            return .lnurlWithdraw(lnurl: lnurl)
        }
        return nil
    }

    private enum ParseError: Error {
        case addressError
    }

}
