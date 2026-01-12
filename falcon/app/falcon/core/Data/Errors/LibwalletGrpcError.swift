//
//  LibwalletGrpcError.swift
//  falcon
//
//  Created by Daniel Mankowski on 28/11/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation
import NIOHPACK

enum LibwalletGrpcErrorDetailType: Int {
    case unknown = -1
    case client = 0
    case libwallet = 1
    case houston = 2
}

struct LibwalletGrpcErrorDetail {
    let type: LibwalletGrpcErrorDetailType
    let code: Int64
    let message: String
    let developerMessage: String

    var libwalletCode: LibwalletGrpcErrorCodes {
        LibwalletGrpcErrorCodes(rawValue: code) ?? .unknown
    }
}

enum LibwalletGrpcErrorCodes: Int64 {
    case signInternalError = 14_100
    case signMacValidationFailed = 14_101
    case challengeExpired = 14_102
    case pairInternalError = 14_103
    case noSlotsAvailable = 14_104
    case muunAppletNotFound = 14_105
    case unknown = 14_999
}

struct LibwalletGrpcError: Error {
    var errorDetail: LibwalletGrpcErrorDetail?

    init(trailers: HPACKHeaders) {
        guard let trailer =
                trailers.first(where: { $0.name.lowercased() == "grpc-status-details-bin" })
        else {
            Logger.log(.warn, "No grpc-status-details-bin header in trailing metadata")
            return
        }

        // gRPC transmits “-bin” metadata using unpadded Base64.
        // However, the Swift standard library doesn’t provide a way to handle it.
        // Data(base64Encoded:) requires padded Base64.
        // As a result, we manually re-add “=” padding to ensure correct decoding.
        var base64Value = trailer.value
        let remainder = base64Value.count % 4
        if remainder > 0 {
            base64Value += String(repeating: "=", count: 4 - remainder)
        }
        guard let data = Data(base64Encoded: base64Value) else {
            Logger.log(.warn, "Base64 decoding failed for grpc-status-details-bin header")
            return
        }

        do {
            let rpcStatus = try Google_Rpc_Status(serializedBytes: data)
            for any in rpcStatus.details {
                let detail = try Rpc_ErrorDetail(unpackingAny: any)
                errorDetail = LibwalletGrpcErrorDetail(
                    type: mapToErrorDetailType(grpcErrorType: detail.type),
                    code: detail.code,
                    message: detail.message,
                    developerMessage: detail.developerMessage
                )
                return
            }
        } catch {
            Logger.log(.warn, "Failed to decode gRPC status details: \(error)")
        }
    }

    private func mapToErrorDetailType(
        grpcErrorType: Rpc_ErrorType
    ) -> LibwalletGrpcErrorDetailType {
        switch grpcErrorType {
        case .client:
            return .client
        case .libwallet:
            return .libwallet
        case .houston:
            return .houston
        case .UNRECOGNIZED:
            return .unknown
        }
    }
}
