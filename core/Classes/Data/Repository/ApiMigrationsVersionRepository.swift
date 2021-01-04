//
//  ApiMigrationsVersionRepository.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 25/11/2020.
//

import Foundation

public class ApiMigrationsVersionRepository {

    private let preferences: Preferences

    public init(preferences: Preferences) {
        self.preferences = preferences
    }

    func set(version: Int) {
        preferences.set(value: version, forKey: .apiMigrationsVersion)
    }

    public func get() -> Int {
        return preferences.integer(forKey: .apiMigrationsVersion)
    }

}
