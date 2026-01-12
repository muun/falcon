//
//  WalletService.swift
//  Muun
//
//  Copyright © 2024 muun. All rights reserved.
//

import GRPC
import NIO
import NIOCore
import NIOHPACK
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

        return performAsyncRequest(call).asCompletable()
    }

    func resetSecurityCard() -> Completable {
        guard let client = client else {
            return Completable.error(MuunError(ServiceError.defaultError))
        }

        let call = client.resetSecurityCard(empty)
        return performAsyncRequest(call).asCompletable()
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

        return performAsyncRequest(call)
            .map { $0.signedMessageHex.stringBytes }
    }

    func signMessageWithSecurityCardV2() -> Completable {
        guard let client = client else {
            return Completable.error(MuunError(ServiceError.defaultError))
        }

        let call = client.signMessageSecurityCardV2(empty)

        return performAsyncRequest(call).asCompletable()
    }

    private func save(key: String, value: Rpc_Value) {
        let request = Rpc_SaveRequest.with {
            $0.key = key
            $0.value = value
        }

        let call = client!.save(request)
        do {
            _ = try performSyncRequest(call)
        } catch {
            Logger.fatal("Unexpected error: \(error.localizedDescription)")
        }
    }

    private func get(key: String) -> Rpc_Value {
        let request = Rpc_GetRequest.with {
            $0.key = key
        }

        let call = client!.get(request)
        do {
            return try performSyncRequest(call).value
        } catch {
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

    func performSyncRequest<Req, Res>(_ call: UnaryCall<Req, Res>) throws -> Res {
        do {
            let response = try call.response.wait()
            return response
        } catch let grpcError as GRPCStatus {
            let trailers: HPACKHeaders?
            do {
                trailers = try call.trailingMetadata.wait()
            } catch {
                Logger.log(.warn, "Failed to fetch gRPC trailers: \(error)")
                trailers = nil
            }
            throw mapToMuunError(trailers: trailers, grpcError: grpcError)
        } catch {
            Logger.log(.err, "Failed to perform gRPC call: \(error)")
            throw MuunError(error)
        }
    }

    func performAsyncRequest<Req, Res>(_ call: UnaryCall<Req, Res>) -> Single<Res> {
        return Single<Res>.create { single in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let response = try call.response.wait()
                    single(.success(response))
                } catch let grpcError as GRPCStatus {
                    let trailers: HPACKHeaders?
                    do {
                        trailers = try call.trailingMetadata.wait()
                    } catch {
                        Logger.log(.warn, "Failed to fetch gRPC trailers: \(error)")
                        trailers = nil
                    }
                    let muunError = self.mapToMuunError(trailers: trailers, grpcError: grpcError)
                    single(.error(muunError))
                } catch {
                    Logger.log(.err, "Failed to perform gRPC call: \(error)")
                    single(.error(MuunError(error)))
                }
            }
            return Disposables.create()
        }
    }

    private func mapToMuunError(trailers: HPACKHeaders?, grpcError: GRPCStatus) -> MuunError {

        guard let trailers else {
            return MuunError(grpcError)
        }

        let libwalletGrpcError = LibwalletGrpcError(trailers: trailers)

        guard let errorDetail = libwalletGrpcError.errorDetail else {
            Logger.log(
                .err,
                """
                gRPC code: \(grpcError.localizedDescription),
                Message: \(grpcError.message ?? "No message")
                """
            )
            return MuunError(grpcError)
        }

        Logger.log(
            .err,
            """
            Libwallet error detail:
            - type: \(errorDetail.type)
            - code: \(errorDetail.code)
            - message: \(errorDetail.message)
            - developerMessage: \(errorDetail.developerMessage)
            """
        )

        if libwalletGrpcError.errorDetail?.type == .houston {
            // errorCode is the only property used in UI flows.
            // The rest of properties of DeveloperError are used for
            // logging purposes only.
            // Logs for requestId and status are already handled by libwallet
            let devError = DeveloperError(
                developerMessage: errorDetail.developerMessage,
                errorCode: Int(errorDetail.code),
                message: errorDetail.message,
                requestId: 0,
                status: 0
            )
            return MuunError(devError)
        } else {
            return MuunError(libwalletGrpcError)
        }
    }
}
