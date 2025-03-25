//
//  BackgroundTimesService.swift
//
//  Created by Lucas Serruya on 17/01/2024.
//

import Foundation

public class BackgroundTimesService {
    private let backgroundTimesRepository: BackgroundTimesRepository

    init(backgroundTimesRepository: BackgroundTimesRepository) {
        self.backgroundTimesRepository = backgroundTimesRepository
    }

    private func pruneTimeLapsesToAvoidLongArrays() {
        let maxAllowedLapses = 99
        backgroundTimesRepository.pruneKeepingLast(numberOfLapsesToKept: maxAllowedLapses)
    }

    public func onEnterForeground() {
        pruneTimeLapsesToAvoidLongArrays()

        guard let backgroundTimestamp = backgroundTimesRepository.lastWentBackgroundTimeLapse() else {
            return
        }

        let diffBetweenNowAndBackgroundTimestamp = Date().timeIntervalSince1970 - backgroundTimestamp
        let backgroundLapseInMili = Int64(diffBetweenNowAndBackgroundTimestamp * 1000)
        let backgroundTimeLapse = BackgroundTimeLapse(beginTimestampInMillis: Int64(backgroundTimestamp*1000), durationInMillis: backgroundLapseInMili)

        backgroundTimesRepository.saveBackgroundLapse(lapse: backgroundTimeLapse)
        backgroundTimesRepository.wipeBackgroundTimestamp()
    }

    public func onEnterBackground() {
        backgroundTimesRepository.recordBackgroundTimestamp()
    }

    public func retrieveTimeLapses() -> [BackgroundTimeLapse] {
        return backgroundTimesRepository.getBackgroundTimeLapses()
    }
}
