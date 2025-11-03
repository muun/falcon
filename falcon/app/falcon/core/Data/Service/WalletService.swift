//
//  WalletService.swift
//  Muun
//
//  Copyright © 2024 muun. All rights reserved.
//

import GRPC
import NIO
import NIOCore
import RxSwift
import SwiftProtobuf

import Libwallet

public class WalletService {
    private let group: EventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    private let client: Rpc_WalletServiceNIOClient?
    private let empty = Google_Protobuf_Empty()

    init() {
        do {
            let socketPath = Environment.current.libwalletSocketFile.path
            let target = ConnectionTarget.unixDomainSocket(socketPath)
            let channel = try GRPCChannelPool.with(target: target,
                                                   transportSecurity: .plaintext,
                                                   eventLoopGroup: group)
            self.client = Rpc_WalletServiceNIOClient(channel: channel)
        } catch {
            Logger.log(error: error)
            self.client = nil
        }
    }

    func pairSecurityCard() -> Completable {
        guard let client = client else {
            return Completable.error(MuunError(ServiceError.defaultError))
        }

        let call = client.setupSecurityCardV2(empty)

        return performGrpcRequest(call).asCompletable()
    }

    func resetSecurityCard() -> Completable {
        guard let client = client else {
            return Completable.error(MuunError(ServiceError.defaultError))
        }

        let call = client.resetSecurityCard(empty)
        return performGrpcRequest(call).asCompletable()
    }

    func signMessageWithSecurityCard(
        messageHex: String
    ) -> Single<[UInt8]> {
        guard let client = client else {
            return Single.error(MuunError(ServiceError.defaultError))
        }
        let request = Rpc_SignMessageSecurityCardRequest.with { req in
            req.messageHex = messageHex
        }
        let call = client.signMessageSecurityCard(request)

        return performGrpcRequest(call)
            .map { $0.signedMessageHex.stringBytes }
    }

    private func save(key: String, value: Rpc_Value) {
        let request = Rpc_SaveRequest.with {
            $0.key = key
            $0.value = value
        }

        let call = client!.save(request)
        do {
            _ = try call.response.wait()
        } catch let error as GRPCStatus {
            Logger.fatal("Status Code: \(error.code), Message: \(error.message ?? "No message")")
        } catch {
            Logger.fatal("Unexpected error: \(error.localizedDescription)")
        }
    }

    private func get(key: String) -> Rpc_Value {
        let request = Rpc_GetRequest.with {
            $0.key = key
        }
        do {
            let response = try client!.get(request).response.wait()
            return response.value
        } catch let error as GRPCStatus {
            Logger.fatal("Status Code: \(error.code), Message: \(error.message ?? "No message")")
        } catch let error {
            Logger.fatal("Unexpected error: \(error.localizedDescription)")
        }
    }

    func saveBool(key: String, value: Bool?) {
        var rpcValue = Rpc_Value()
        if let boolValue = value {
            rpcValue.kind = .boolValue(boolValue)
        } else {
            rpcValue.kind = .nullValue(Rpc_NullValue.nullValue)
        }
        save(key: key, value: rpcValue)
    }

    func getBool(key: String) -> Bool? {
        let value = get(key: key)
        switch value.kind {
        case .boolValue(let bool):
            return bool
        case .nullValue:
            return nil
        default:
            Logger.fatal("Value for key \(key) is not of type Bool")
        }
    }

    func getBool(key: String, defaultValue: Bool) -> Bool {
        return getBool(key: key) ?? defaultValue
    }

    func performGrpcRequest<Req, Res>(_ call: UnaryCall<Req, Res>) -> Single<Res> {
        return Single<Res>.create { [weak self] single in
            call.response.whenComplete { result in
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    if let grpcError = error as? GRPCStatus {
                        if let detail = self?.extractRpcErrorDetail(from: call) {
                            Logger.log(
                                .err,
                                """
                                Libwallet error detail:
                                - type: \(detail.type)
                                - code: \(detail.code)
                                - message: \(detail.message)
                                - developerMessage: \(detail.developerMessage)
                                """
                            )
                            if detail.type == Rpc_ErrorType.houston {
                                // errorCode is the only property used in UI flows.
                                // The rest of properties of DeveloperError are used for
                                // logging purposes only.
                                // Logs for requestId and status are already handled by libwallet
                                // TODO: Improve this structure.
                                let devError = DeveloperError(
                                    developerMessage: detail.developerMessage,
                                    errorCode: Int(detail.code),
                                    message: detail.message,
                                    requestId: 0,
                                    status: 0
                                )
                                let houstonError = MuunError(ServiceError.customError(devError))
                                single(.error(houstonError))
                            } else {
                                // TODO:
                                // Currently, we are only using error codes of houston for UI flows.
                                // Client errors (Rpc_ErrorType.client) and libwallet errors
                                // (Rpc_ErrorType.libwallet) should be considered in the early
                                // future.
                                single(.error(grpcError))
                            }
                        } else {
                            Logger.log(
                                .err,
                                "gRPC code: \(grpcError.code), Message: \(grpcError.message ?? "No message")"
                            )
                            single(.error(grpcError))
                        }
                    } else {
                        single(.error(error))
                    }
                }
            }
            return Disposables.create { call.cancel(promise: nil) }
        }
    }

    func extractRpcErrorDetail<Req, Resp>(from call: UnaryCall<Req, Resp>) -> Rpc_ErrorDetail? {
        do {
            let trailers = try call.trailingMetadata.wait()
            guard let trailer =
                    trailers.first(where: { $0.name.lowercased() == "grpc-status-details-bin" })
            else {
                Logger.log(.warn, "No grpc-status-details-bin header in trailing metadata")
                return nil
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
                return nil
            }

            let rpcStatus = try Google_Rpc_Status(serializedBytes: data)
            for any in rpcStatus.details {
                let detail = try Rpc_ErrorDetail(unpackingAny: any)
                return detail
            }

      } catch {
        Logger.log(.warn, "Failed to decode gRPC status details: \(error)")
      }
      return nil
    }

}
