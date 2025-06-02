//
//  CardNfcService.swift
//  Muun
//
//  Created by Daniel Mankowski on 28/02/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import RxSwift

struct CardNfcResponse {
    let response: Data
    let statusCode: Int
}

enum CardNfcError: Error {
    /// An error occurred while decoding the message received from Libwallet.
    case decodingMessageError
    /// No NFC tag of type ISO7816 is currently connected.
    case unsupportedTagConnected
}

protocol CardNfcService {
    func connect(alertMessage: String) -> Completable
    func transmit(message: Data) -> Single<CardNfcResponse>
    func close()
}
