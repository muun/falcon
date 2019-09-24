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

                guard let user = user,
                    let rate = try exchangeRate?.rate(for: user.primaryCurrency) else {
                    return nil
                }

                return (user.primaryCurrency, rate)
            })
    }

}
