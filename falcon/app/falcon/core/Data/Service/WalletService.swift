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
    private let storageClient: Proto_StorageServiceNIOClient?
    private let emptyRequest = Rpc_EmptyMessage()

    init() {
        do {
            let socketPath = Environment.current.libwalletSocketFile.path
            let target = ConnectionTarget.unixDomainSocket(socketPath)
            let channel = try GRPCChannelPool.with(target: target,
                                                   transportSecurity: .plaintext,
                                                   eventLoopGroup: group)
            self.client = Rpc_WalletServiceNIOClient(channel: channel)
            self.storageClient = Proto_StorageServiceNIOClient(channel: channel)
        } catch {
            Logger.log(error: error)
            self.client = nil
            self.storageClient = nil
        }
    }

    func deleteWallet() -> Single<Rpc_OperationStatus> {
        guard let client = client else {
            return Single.error(MuunError(ServiceError.internetError))
        }

        let call = client.deleteWallet(emptyRequest)
        return Single.create { single in
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let response = try call.response.wait()
                    single(.success(response))
                } catch {
                    single(.error(error))
                }
            }
            return Disposables.create()
        }
    }

    func nfcTransmit(apduCommand: Data) -> Single<CardNfcResponse> {
        guard let client = client else {
            return Single.error(MuunError(ServiceError.internetError))
        }

        return Single.create { single in
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    let request = Rpc_NfcTransmitRequest.with { req in
                        req.apduCommand = apduCommand
                    }
                    let call = client.nfcTransmit(request)
                    let response = try call.response.wait()
                    let cardResponse = CardNfcResponse(response: response.apduResponse,
                                                       statusCode: Int(response.statusCode))
                    single(.success(cardResponse))
                } catch {
                    Logger.log(.debug, "Error transmiting Nfc Request")
                    single(.error(MuunError(error)))
                }
            }
            return Disposables.create()
        }
    }

    private func save(key: String, value: Proto_Value) {
        let request = Proto_SaveRequest.with {
            $0.key = key
            $0.value = value
        }

        let call = storageClient!.save(request)
        do {
            _ = try call.response.wait()
        } catch let error as GRPCStatus {
            Logger.fatal("Status Code: \(error.code), Message: \(error.message ?? "No message")")
        } catch {
            Logger.fatal("Unexpected error: \(error.localizedDescription)")
        }

    }

    private func get(key: String) -> Proto_Value {
        let request = Proto_GetRequest.with {
            $0.key = key
        }
        do {
            let response = try storageClient!.get(request).response.wait()
            return response.value
        } catch let error as GRPCStatus {
            Logger.fatal("Status Code: \(error.code), Message: \(error.message ?? "No message")")
        } catch let error {
            Logger.fatal("Unexpected error: \(error.localizedDescription)")
        }
    }

    func saveBool(key: String, value: Bool?) {
        var rpcValue = Proto_Value()
        if let boolValue = value {
            rpcValue.kind = .boolValue(boolValue)
        } else {
            rpcValue.kind = .nullValue(Proto_NullValue.nullValue)
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

}
