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
    private static let gracefulCloseDeadline: TimeAmount = .seconds(3)

    private let group: EventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    private var client: Rpc_WalletServiceNIOClient?
    private var channel: GRPCChannel?
    private let empty = Google_Protobuf_Empty()

    init() {
        connect()
    }

    /// Connect to the libwallet gRPC server.
    func connect() {
        // Close any existing channel before creating a new one.
        disconnect()

        do {
            let socketPath = Environment.current.libwalletSocketFile.path
            let target = ConnectionTarget.unixDomainSocket(socketPath)
            let newChannel = try GRPCChannelPool.with(
                target: target,
                transportSecurity: .plaintext,
                eventLoopGroup: group
            )
            self.channel = newChannel
            self.client = Rpc_WalletServiceNIOClient(channel: newChannel)
        } catch {
            Logger.log(error: error)
            self.channel = nil
            self.client = nil
        }
    }

    /// Disconnect from the libwallet gRPC server.
    func disconnect() {
        guard let channel = channel else {
            return
        }
        defer {
            self.channel = nil
            self.client = nil
        }
        let promise = group.next().makePromise(of: Void.self)
        promise.futureResult.whenFailure { error in
            Logger.log(.warn, "Failed to close gRPC channel gracefully: \(error)")
        }
        channel.closeGracefully(
            deadline: .now() + WalletService.gracefulCloseDeadline,
            promise: promise
        )
    }

    func resetData() throws {
        guard let client = client else {
            throw MuunError(ServiceError.defaultError)
        }

        let call = client.resetData(empty)
        _ = try performSyncRequest(call)
    }

    func pairSecurityCard() -> Completable {
        guard let client = client else {
            return Completable.error(MuunError(ServiceError.defaultError))
        }

        let call = client.setupSecurityCardV2(empty)

        return performAsyncRequest(call).asCompletable()
    }

    func signMessageWithSecurityCardV2() -> Completable {
        guard let client = client else {
            return Completable.error(MuunError(ServiceError.defaultError))
        }

        let call = client.signMessageSecurityCardV2(empty)

        return performAsyncRequest(call).asCompletable()
    }

    func generateEmergencyKitPDF(
        data: EmergencyKitData,
        outputPath: String,
        language: String
    ) throws -> Rpc_GenerateEmergencyKitPDFResponse {
        guard let client = client else {
            throw MuunError(ServiceError.defaultError)
        }

        let request = Rpc_GenerateEmergencyKitPDFRequest.with { req in
            req.ekInput = Rpc_EKInputRequest.with { ekInput in
                ekInput.firstEncryptedKey = data.userKey
                ekInput.firstFingerprint = data.userFingerprint
                ekInput.secondEncryptedKey = data.muunKey
                ekInput.secondFingerprint = data.muunFingerprint
                ekInput.rcChecksum = data.rcChecksum
            }
            req.outputPath = outputPath
            req.language = language
        }

        let call = client.generateEmergencyKitPDF(request)
        return try performSyncRequest(call)
    }

    func zipDataDir(outputPath: String) {
        guard let client = client else {
            Logger.fatal("grpc client shouldn't be nil")
        }

        let request = Rpc_ZipDataDirRequest.with { req in
            req.outputPath = outputPath
        }

        let call = client.zipDataDir(request)
        do {
            _ = try performSyncRequest(call)
        } catch {
            Logger.log(.err, "Unexpected error: \(error.localizedDescription)")
        }
    }

    func secureKeyValueStoragePut(key: String, value: Data) throws {
        guard let client = client else {
            throw MuunError(ServiceError.defaultError)
        }

        let request = Rpc_SecureKeyValueStoragePutRequest.with {
            $0.key = key
            $0.value = value
        }

        let call = client.secureKeyValueStoragePut(request)
        _ = try performSyncRequest(call)
    }

    func secureKeyValueStorageGet(key: String) throws -> Secret {
        guard let client = client else {
            throw MuunError(ServiceError.defaultError)
        }

        let request = Rpc_SecureKeyValueStorageGetRequest.with {
            $0.key = key
        }

        let call = client.secureKeyValueStorageGet(request)
        return Secret(try performSyncRequest(call).value)
    }

    func secureKeyValueStorageDelete(key: String) throws {
        guard let client = client else {
            throw MuunError(ServiceError.defaultError)
        }

        let request = Rpc_SecureKeyValueStorageDeleteRequest.with {
            $0.key = key
        }

        let call = client.secureKeyValueStorageDelete(request)
        _ = try performSyncRequest(call)
    }

    func secureKeyValueStorageWipe() throws {
        guard let client = client else {
            throw MuunError(ServiceError.defaultError)
        }

        let call = client.secureKeyValueStorageWipe(empty)
        _ = try performSyncRequest(call)
    }

    func getSecurityCardsMarketplace() -> Single<[SecurityCardProvider]> {
        guard let client = client else {
            return Single.error(MuunError(ServiceError.defaultError))
        }
        let call = client.getSecurityCardsMarketplace(empty)
        return performAsyncRequest(call).map { $0.toModel() }
    }

    private func save(key: String, value: Rpc_Value) {
        let request = Rpc_SaveRequest.with {
            $0.key = key
            $0.value = value
        }

        guard let client = client else {
            Logger.fatal("grpc client shouldn't be nil")
        }
        let call = client.save(request)
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

        guard let client = client else {
            Logger.fatal("grpc client shouldn't be nil")
        }
        let call = client.get(request)
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

    func saveInt32(key: String, value: Int32?) {
        var rpcValue = Rpc_Value()
        if let intValue = value {
            rpcValue.kind = .intValue(intValue)
        } else {
            rpcValue.kind = .nullValue(Rpc_NullValue.nullValue)
        }
        save(key: key, value: rpcValue)
    }

    func getInt32(key: String) -> Int32? {
        let value = get(key: key)
        switch value.kind {
        case .intValue(let int):
            return int
        case .nullValue:
            return nil
        default:
            Logger.fatal("Value for key \(key) is not of type Int32")
        }
    }

    func getInt32(key: String, defaultValue: Int32) -> Int32 {
        getInt32(key: key) ?? defaultValue
    }

    private func getByPrefix(prefix: String) -> Rpc_Struct {
        let request = Rpc_GetByPrefixRequest.with {
            $0.prefix = prefix
        }

        guard let client = client else {
            Logger.fatal("grpc client shouldn't be nil")
        }
        let call = client.getByPrefix(request)
        do {
            return try performSyncRequest(call).items
        } catch {
            Logger.fatal("Unexpected error: \(error.localizedDescription)")
        }
    }

    func getBoolByPrefix(prefix: String) -> [String: Bool] {
        let items = getByPrefix(prefix: prefix)
        var result: [String: Bool] = [:]
        items.fields.forEach {
            switch $0.value.kind {
            case .boolValue(let bool):
                return result[$0.key] = bool
            case .nullValue:
                break
            default:
                Logger.fatal("Value for key \($0.key) is not of type Bool")
            }
        }
        return result
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
