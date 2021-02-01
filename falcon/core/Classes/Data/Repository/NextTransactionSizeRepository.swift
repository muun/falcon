//
//  NextTransactionSizeRepository.swift
//  falcon
//
//  Created by Manu Herrera on 12/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

class NextTransactionSizeRepository {

    private let preferences: Preferences

    init(preferences: Preferences) {
        self.preferences = preferences
    }

    func setNextTransactionSize(_ nextTransactionSize: NextTransactionSize) {
        preferences.set(object: nextTransactionSize, forKey: .nextTransactionSize)
    }

    func watchNextTransactionSize() -> Observable<NextTransactionSize?> {
        return preferences.watchObject(key: .nextTransactionSize)
    }

    func getNextTransactionSize() -> NextTransactionSize? {
        return preferences.object(forKey: .nextTransactionSize)
    }

}
