//
//  CurrencyActions.swift
//  falcon
//
//  Created by Juan Pablo Civile on 17/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

public class CurrencyActions {

    private let exchangeRateRepository: ExchangeRateWindowRepository
    private let userRepository: UserRepository

    init(exchangeRateRepository: ExchangeRateWindowRepository, userRepository: UserRepository) {
        self.exchangeRateRepository = exchangeRateRepository
        self.userRepository = userRepository
    }

    func watchPrimaryExchangeRate() -> Observable<(String, Decimal)?> {
        return Observable.combineLatest(
                userRepository.watchUser(),
                exchangeRateRepository.watchExchangeRateWindow()
            ).map({ (user, exchangeRate) in

                guard let user = user, let window = exchangeRate else {
                    return nil
                }

                let primaryCurrency = user.primaryCurrencyWithValidExchangeRate(window: window)

                guard let rate = try? window.rate(for: primaryCurrency) else {
                    return nil
                }

                // we already know there is a valid value for rate here
                return (primaryCurrency, rate)
            })
    }

}
