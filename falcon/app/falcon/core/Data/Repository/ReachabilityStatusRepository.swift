//
//  ReachabilityRepository.swift
//
//  Created by Lucas Serruya on 26/10/2023.
//

import Foundation

class ReachabilityStatusRepository {
    let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func fetch() -> ReachabilityStatus? {
        guard let dto: ReachabilityStatusDTO =
                preferences.object(forKey: .reachabilityStatus) else {
            return nil
        }

        return ReachabilityStatus(houston: dto.houston, deviceCheck: dto.deviceCheck)
    }

    func set(_ status: ReachabilityStatus) {
        let dto = ReachabilityStatusDTO.from(model: status)

        preferences.set(object: dto, forKey: .reachabilityStatus)
    }

    func hasAValue() -> Bool {
        preferences.has(key: .reachabilityStatus)
    }

    func hasValueBeenAlreadyProvidedToBackend() -> Bool {
        preferences.bool(forKey: .reachabilityStatusAlreadyProvided)
    }

    func markValueAsProvidedToBackend() {
        preferences.set(value: true, forKey: .reachabilityStatusAlreadyProvided)
        assert(hasValueBeenAlreadyProvidedToBackend())
    }
}

struct ReachabilityStatusDTO: Encodable, Decodable {
    let houston: Bool
    let deviceCheck: Bool

    static func from(model: ReachabilityStatus) -> ReachabilityStatusDTO {
        return ReachabilityStatusDTO(houston: model.houston,
                                     deviceCheck: model.deviceCheck)
    }
}
