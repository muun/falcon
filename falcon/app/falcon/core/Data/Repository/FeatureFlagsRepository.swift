//
//  FeatureFlagsRepository.swift
//  Created by Juan Pablo Civile on 21/10/2021.
//

import Foundation
import RxSwift
import Libwallet

public class FeatureFlagsRepository : NSObject {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    public func store(flags: [FeatureFlags]) {
        preferences.set(value: flags.map { $0.rawValue }, forKey: .featureFlags)
    }

    public func fetch() -> [FeatureFlags] {
        return parse(preferences.array(forKey: .featureFlags))
    }

    public func watch() -> Observable<[FeatureFlags]> {
        return preferences.watchArray(key: .featureFlags)
            .map(self.parse)
    }

    private func parse(_ array: [Any]?) -> [FeatureFlags] {
        return (array as? [String])?.compactMap { FeatureFlags(rawValue: $0) } ?? []
    }
}

// Not for application use. This is a bridge to provide feature flag information to libwallet
// until we implement a more generic libwallet-side storage mechanism.
extension FeatureFlagsRepository : App_provided_dataBackendActivatedFeatureStatusProviderProtocol {
    public func isBackendFlagEnabled(_ flag: String?) -> Bool {
        guard let flag = flag else {
            Logger.log(.err, "Tried to read null feature flag from libwallet.")
            return false
        }
        if let flags = preferences.array(forKey: .featureFlags) as? [String] {
            return flags.contains(flag)
        }
        return false
    }
}
