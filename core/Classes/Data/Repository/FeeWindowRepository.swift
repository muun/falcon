//
//  FeeWindowRepository.swift
//  falcon
//
//  Created by Manu Herrera on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

class FeeWindowRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func setFeeWindow(_ feeWindow: FeeWindow) {
        preferences.set(object: feeWindow, forKey: .feeWindow)
    }

    func watchFeeWindow() -> Observable<FeeWindow?> {
        return preferences.watchObject(key: .feeWindow)
    }

    func getFeeWindow() -> FeeWindow? {
        return preferences.object(forKey: .feeWindow)
    }

    func isSet() -> Bool {
        return getFeeWindow() != nil
    }

}
