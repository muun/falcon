//
//  ForwardingPolicyRepository.swift
//  Created by Juan Pablo Civile on 18/09/2020.
//

import Foundation

class ForwardingPolicyRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func store(policies: [ForwardingPolicy]) {
        self.preferences.set(object: policies, forKey: .forwardingPolicies)
    }

    func fetch() -> [ForwardingPolicy] {
        return preferences.object(forKey: .forwardingPolicies) ?? []
    }

}
