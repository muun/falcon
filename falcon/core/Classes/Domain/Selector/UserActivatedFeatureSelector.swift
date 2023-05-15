//
//  UserActivatedFeatureSelector.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 21/10/2021.
//

import Foundation
import RxSwift
import Libwallet

public enum UserActivatedFeatureStatus {
    case active,
         scheduledActivation(blocksLeft: UInt),
         preactivated(blocksLeft: UInt),
         canActivate,
         canPreactivate(blocksLeft: UInt),
         off
}

public class UserActivatedFeaturesSelector {

    private let blockheightRepository: BlockchainHeightRepository
    private let featureFlagsRepository: FeatureFlagsRepository
    private let userRepository: UserRepository

    init(blockheightRepository: BlockchainHeightRepository,
         featureFlagsRepository: FeatureFlagsRepository,
         userRepository: UserRepository) {
        self.blockheightRepository = blockheightRepository
        self.featureFlagsRepository = featureFlagsRepository
        self.userRepository = userRepository
    }

    public func watch(for feature: LibwalletUserActivatedFeatureProtocol) -> Observable<UserActivatedFeatureStatus> {

        return Observable.combineLatest(
            blockheightRepository.watch(),
            featureFlagsRepository.watch(),
            userRepository.watchUser()
        ).map { (height, flags, user) in
            self.determineStatus(for: feature, blockHeight: height, user: user, featureFlags: flags)
        }

    }

    public func get(for feature: LibwalletUserActivatedFeatureProtocol) -> UserActivatedFeatureStatus {
        return determineStatus(
            for: feature,
            blockHeight: blockheightRepository.getCurrentBlockchainHeight(),
            user: userRepository.getUser(),
            featureFlags: featureFlagsRepository.fetch()
        )
    }

    private func determineStatus(
        for feature: LibwalletUserActivatedFeatureProtocol,
        blockHeight: Int?,
        user: User?,
        featureFlags: [FeatureFlags]) -> UserActivatedFeatureStatus {

        guard let user = user, let blockHeight = blockHeight else {
            return .off
        }

#if DEBUG
        if let debugValue = debugValue {
            return debugValue
        }
#endif

        let status = LibwalletDetermineUserActivatedFeatureStatus(
            feature,
            blockHeight,
            (user.exportedKitVersions ?? []).toLibwallet(),
            featureFlags.map { $0.rawValue }.toLibwallet(),
            Environment.current.network
        )

        let activationHeight = Libwallet.userActivatedFeatureTaproot()!.blockheight(Environment.current.network)
        let currentHeight = blockheightRepository.getCurrentBlockchainHeight()
        let blocksLeft = UInt(max(0, activationHeight - currentHeight))

        switch status {
        case LibwalletUserActivatedFeatureStatusActive:
            return .active
        case LibwalletUserActivatedFeatureStatusScheduledActivation:
            return .scheduledActivation(blocksLeft: blocksLeft)
        case LibwalletUserActivatedFeatureStatusPreactivated:
            return .preactivated(blocksLeft: blocksLeft)
        case LibwalletUserActivatedFeatureStatusCanActivate:
            return .canActivate
        case LibwalletUserActivatedFeatureStatusCanPreactivate:
            return .canPreactivate(blocksLeft: blocksLeft)
        case LibwalletUserActivatedFeatureStatusOff:
            return .off
        default:
            Logger.fatal("Unmapped return value from libwallet \(status)")
        }

    }

#if DEBUG
    private var debugValue: UserActivatedFeatureStatus? = nil
    public func debugChangeTaprootActivation() {
        switch get(for: Libwallet.userActivatedFeatureTaproot()!) {
        case .active:
            debugValue = .scheduledActivation(blocksLeft: 1000)
        case .scheduledActivation:
            debugValue = .preactivated(blocksLeft: 1000)
        case .preactivated:
            debugValue = .canActivate
        case .canActivate:
            debugValue = .canPreactivate(blocksLeft: 1000)
        case .canPreactivate:
            debugValue = .off
        case .off:
            debugValue = .active
        }
    }
#endif
}
