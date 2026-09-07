package newop

import (
	"github.com/shopspring/decimal"

	"github.com/muun/libwallet"
)

// ExchangeRateWindow holds a map of exchange rates from BTC to every currency we handle
type ExchangeRateWindow struct {
	WindowId int //nolint:staticcheck // gomobile export
	rates    map[string]float64
}

func (w *ExchangeRateWindow) AddRate(
	currency string,
	rate float64,
) {
	if w.rates == nil {
		w.rates = make(map[string]float64)
	}
	w.rates[currency] = rate
}

func (w *ExchangeRateWindow) Rate(currency string) float64 {
	return w.rates[currency]
}

func (w *ExchangeRateWindow) Currencies() *libwallet.StringList {
	var currencies []string
	for key := range w.rates {
		currencies = append(currencies, key)
	}
	return libwallet.NewStringListWithElements(currencies)
}

func (w *ExchangeRateWindow) convert(amount *MonetaryAmount, currency string) *MonetaryAmount {
	fromRate := decimal.NewFromFloat(w.Rate(amount.Currency))
	toRate := decimal.NewFromFloat(w.Rate(currency))
	value := amount.Value.Div(fromRate).Mul(toRate)

	return &MonetaryAmount{Value: value, Currency: currency}
}
