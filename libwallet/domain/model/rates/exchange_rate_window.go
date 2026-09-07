// Package rates holds the exchange rate domain model.
package rates

import "github.com/muun/libwallet/platform/preconditions"

// ExchangeRateWindow holds a snapshot of exchange rates from BTC to every currency we handle,
// as fetched from Houston.
//
// The JSON tags define the canonical serialization of the window stored under the
// exchangeRateWindow KV key. Falcon and Apollo produce and parse this exact document,
// so any change here must stay compatible with both platforms.
type ExchangeRateWindow struct {
	WindowID          int64              `json:"windowId"`
	FetchDateInMillis int64              `json:"fetchDateInMillis"`
	Rates             map[string]float64 `json:"rates"`
}

// NewExchangeRateWindow creates an ExchangeRateWindow.
func NewExchangeRateWindow(
	windowID int64,
	fetchDateInMillis int64,
	rates map[string]float64,
) *ExchangeRateWindow {
	preconditions.CheckStatef(len(rates) > 0, "expected rates to be non-empty")

	return &ExchangeRateWindow{
		WindowID:          preconditions.CheckPositive(windowID),
		FetchDateInMillis: preconditions.CheckPositive(fetchDateInMillis),
		Rates:             rates,
	}
}
