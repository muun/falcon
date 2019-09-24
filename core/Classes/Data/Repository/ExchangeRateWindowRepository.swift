//
//  ExchangeRateWindowRepository.swift
//  falcon
//
//  Created by Manu Herrera on 10/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class ExchangeRateWindowRepository {

    private let preferences: Preferences

    public init(preferences: Preferences) {
        self.preferences = preferences
    }

    func setExchangeRateWindow(_ exchangeRateWindow: ExchangeRateWindow) {
        preferences.set(object: exchangeRateWindow, forKey: .exchangeRateWindow)
    }

    func watchExchangeRateWindow() -> Observable<ExchangeRateWindow?> {
        return preferences.watchObject(key: .exchangeRateWindow)
    }

    // FIXME: This shouldn't be public
    public func getExchangeRateWindow() -> ExchangeRateWindow? {
        return preferences.object(forKey: .exchangeRateWindow)
    }

}
