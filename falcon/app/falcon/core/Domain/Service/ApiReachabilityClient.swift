//
//  ApiReachabilityClient.swift
//
//  Created by Lucas Serruya on 19/10/2023.
//

import Foundation
import RxSwift

class ApiReachabilityClient: ReachabilityService {
    var houstonService: HoustonService?
    private var disposeBag = DisposeBag()

    private let sessionActions: SessionActions
    private let featureFlagsRepository: FeatureFlagsRepository
    private let reachabilityStatusRepository: ReachabilityStatusRepository
    private let pingService: PingURLService

    init(sessionActions: SessionActions,
         featureFlagsRepository: FeatureFlagsRepository,
         reachabilityStatusRepository: ReachabilityStatusRepository,
         pingService: PingURLService) {
        self.reachabilityStatusRepository = reachabilityStatusRepository
        self.sessionActions = sessionActions
        self.featureFlagsRepository = featureFlagsRepository
        self.pingService = pingService

        collectReachabilityOnCollectFlagOn()
    }

    func collectReachabilityStatusIfNeeded() {
        guard !sessionActions.isLoggedIn() else {
            return
        }

        collectReachabilityStatusUnlessCached()
    }

    func getReachabilityStatus() -> ReachabilityStatus? {
        guard statusWasNeverProvided() else {
            return nil
        }

        reachabilityStatusRepository.markValueAsProvidedToBackend()
        return reachabilityStatusRepository.fetch()
    }
}

private extension ApiReachabilityClient {
    func canReachDeviceCheck() -> Single<Bool> {
        return pingService.run(url: "https://humb.apple.com:443")
    }

    func canReachHouston() -> Single<Bool> {
        houstonService!.publicStatus().flatMap({ _ in
            Single.just(true)
        }).catchErrorJustReturn(false)
    }

    func collectReachabilityStatusUnlessCached() {
        guard !hasReachabilityBeenMeasured() else {
            return
        }

        Single.zip(canReachDeviceCheck(),
                   canReachHouston()
        ).subscribe { [weak self] in
            let (canReachDeviceCheck, canReachHouston) = $0
            let status = ReachabilityStatus(houston: canReachHouston,
                                            deviceCheck: canReachDeviceCheck)

            self?.reachabilityStatusRepository.set(status)
        }.disposed(by: disposeBag)
    }

    func collectReachabilityOnCollectFlagOn() {
        featureFlagsRepository.watch().subscribe { [weak self] flags in
            if flags.contains(.collectDeviceCheckReachability) {
                self?.collectReachabilityStatusUnlessCached()
            }
        }.disposed(by: disposeBag)
    }

    func hasReachabilityBeenMeasured() -> Bool {
        reachabilityStatusRepository.hasAValue()
    }

    func statusWasNeverProvided() -> Bool {
        !reachabilityStatusRepository.hasValueBeenAlreadyProvidedToBackend()
    }
}
