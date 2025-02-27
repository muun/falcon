//
//  BackgroundTimesRepository.swift
//
//  Created by Lucas Serruya on 17/01/2024.
//

import Foundation

class BackgroundTimesRepository {
    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func recordBackgroundTimestamp() {
        preferences.set(value: Date().timeIntervalSince1970,
                        forKey: .lastBackgroundBeginTime)
    }

    func wipeBackgroundTimestamp() {
        preferences.remove(key: .lastBackgroundBeginTime)
    }

    func lastWentBackgroundTimeLapse() -> Double? {
        return preferences.double(forKey: .lastBackgroundBeginTime)
    }

    func getBackgroundTimeLapses() -> [BackgroundTimeLapse] {
        let values: [BackgroundTimeLapse]? = preferences.object(forKey: .backgroundTimes)
        return values ?? [BackgroundTimeLapse]()
    }

    func saveBackgroundLapse(lapse: BackgroundTimeLapse) {
        let savedTimes: [BackgroundTimeLapse]? = preferences.object(forKey: .backgroundTimes)
        var savedTimeLapsesToBeAdded = savedTimes ?? [BackgroundTimeLapse]()
        savedTimeLapsesToBeAdded.append(lapse)
        preferences.set(object: savedTimeLapsesToBeAdded, forKey: .backgroundTimes)
    }

    func pruneKeepingLast(numberOfLapsesToKept: Int) {
        let trimmedBackgroundTimeLapses = getBackgroundTimeLapses().suffix(numberOfLapsesToKept)

        preferences.set(object: Array(trimmedBackgroundTimeLapses),
                        forKey: .backgroundTimes)
    }
}

// seraparate into domain and data models.
public struct BackgroundTimeLapse: Codable {
    public let beginTimestampInMillis: Int64
    public let durationInMillis: Int64
}
