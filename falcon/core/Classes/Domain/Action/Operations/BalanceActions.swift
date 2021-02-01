//
//  BalanceActions.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 12/01/2021.
//

import RxSwift

public class BalanceActions {

    private let currencyActions: CurrencyActions
    private let nextTransactionSizeRepository: NextTransactionSizeRepository

    private let balanceCache: BehaviorSubject<MonetaryAmount>
    private let disposeBag: DisposeBag

    init(currencyActions: CurrencyActions,
         nextTransactionSizeRepository: NextTransactionSizeRepository) {

        self.currencyActions = currencyActions
        self.nextTransactionSizeRepository = nextTransactionSizeRepository

        self.disposeBag = DisposeBag()
        self.balanceCache = BehaviorSubject(value: MonetaryAmount(amount: 0, currency: "BTC"))

        generateBalanceCache()
    }

    private func generateBalanceCache() {

        Observable.combineLatest(
            watchBalanceInSatoshis(),
            currencyActions.watchPrimaryExchangeRate().compactMap { $0 }
        )
        .map({ (inSatoshis: Satoshis, exchangeRate: (String, Decimal)) -> MonetaryAmount in
            let (currency, rate) = exchangeRate
            return inSatoshis.valuation(at: rate, currency: currency)
        })
        .subscribe(onNext: self.balanceCache.onNext)
        .disposed(by: disposeBag)
    }

    func watchBalanceInSatoshis() -> Observable<Satoshis> {
        return nextTransactionSizeRepository.watchNextTransactionSize()
            .map({ nts in
                return nts?.uiBalance() ?? Satoshis(value: 0)
            })
    }

    public func watchBalance() -> Observable<MonetaryAmount> {
        return balanceCache.asObservable()
    }
}
