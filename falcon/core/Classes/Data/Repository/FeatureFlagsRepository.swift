//
//  FeatureFlagsRepository.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 21/10/2021.
//

import Foundation
import RxSwift

public class FeatureFlagsRepository {

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
