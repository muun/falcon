//
//  BitcoinURIViewModel.swift
//  Muun
//
//  Created by Lucas Serruya on 28/11/2022.
//  Copyright © 2022 muun. All rights reserved.
//



struct BitcoinURIViewModel {
    let uri: String
    let invoice: IncomingInvoiceInfo
    let address: String
    let amount: Satoshis?

    var addressWithAmount: String {
        guard let amount = amount else {
            return address
        }
        return "bitcoin:" + address + "?amount=" + "\(amount.toBTCDecimal())"
    }

    static func from(raw: RawBitcoinURI) -> BitcoinURIViewModel {
        let info = IncomingInvoiceInfo.from(raw: raw.rawInvoice)

        return BitcoinURIViewModel(uri: raw.uri,
                                   invoice: info,
                                   address: raw.address,
                                   amount: raw.amount)
    }
}
