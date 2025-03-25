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

import Libwallet

class WalletService {
    private let group: EventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    private let client: Rpc_WalletServiceNIOClient?
    private let emptyRequest = Rpc_EmptyMessage()

    init() {
        do {
            let socketPath = Environment.current.libwalletSocketFile.absoluteString
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
}
