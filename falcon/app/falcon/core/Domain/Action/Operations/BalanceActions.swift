//
//  BalanceActions.swift
//  Created by Federico Bond on 12/01/2021.
//

import RxSwift

public class BalanceActions {

    private let currencyActions: CurrencyActions
    private let nextTransactionSizeRepository: NextTransactionSizeRepository

    private let balanceCache: BehaviorSubject<BitcoinAmount>
    private let disposeBag: DisposeBag

    init(
        currencyActions: CurrencyActions,
        nextTransactionSizeRepository: NextTransactionSizeRepository
    ) {

        self.currencyActions = currencyActions
        self.nextTransactionSizeRepository = nextTransactionSizeRepository

        self.disposeBag = DisposeBag()
        self.balanceCache = BehaviorSubject(value: BitcoinAmount(
            inSatoshis: Satoshis.zero,
            inInputCurrency: MonetaryAmount(amount: 0, currency: "BTC"),
            inPrimaryCurrency: MonetaryAmount(amount: 0, currency: "BTC")
        ))

        generateBalanceCache()
    }

    private func generateBalanceCache() {

        Observable.combineLatest(
            watchBalanceInSatoshis(),
            currencyActions.watchPrimaryExchangeRate().compactMap { $0 }
        )
        .map({ (inSatoshis: Satoshis, exchangeRate: (String, Decimal)) -> BitcoinAmount in
            let (currency, rate) = exchangeRate
            // Satoshis are the source of truth: only convert forward (multiply by the rate),
            // never divide fiat back into satoshis.
            return BitcoinAmount(
                inSatoshis: inSatoshis,
                inInputCurrency: inSatoshis.toBTC(),
                inPrimaryCurrency: inSatoshis.valuation(at: rate, currency: currency)
            )
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

    public func watchBalance() -> Observable<BitcoinAmount> {
        return balanceCache.asObservable()
    }
}
