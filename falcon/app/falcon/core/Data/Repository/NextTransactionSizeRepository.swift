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

    func setNextTransactionSize(
        _ nextTransactionSize: NextTransactionSize,
        filename: StaticString = #file,
        line: UInt = #line,
        funcName: StaticString = #function
    ) {
        logOnStaleNTS(nextTransactionSize, filename, line, funcName)
        preferences.set(object: nextTransactionSize, forKey: .nextTransactionSize)
    }

    func watchNextTransactionSize() -> Observable<NextTransactionSize?> {
        return preferences.watchObject(key: .nextTransactionSize)
    }

    func getNextTransactionSize() -> NextTransactionSize? {
        return preferences.object(forKey: .nextTransactionSize)
    }

    private func logOnStaleNTS(_ nextTransactionSize: NextTransactionSize,
                             _ filename: StaticString,
                             _ line: UInt,
                             _ funcName: StaticString) {
        if let currentNTSOpId = getNextTransactionSize()?.validAtOperationHid,
           let newNTSOpId = nextTransactionSize.validAtOperationHid,
           newNTSOpId < currentNTSOpId {
            Logger.log(
                .err, "NTS stored was newer than the new one",
                filename: filename,
                line: line,
                funcName: funcName
            )
        }
    }
}
