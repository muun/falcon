package rates

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestExchangeRateWindow_CanonicalJSON(t *testing.T) {
	window := NewExchangeRateWindow(123456, 1754424000000, map[string]float64{
		"USD": 114521.55,
		"ARS": 152300000.0,
		"BTC": 1,
	})

	got, err := json.Marshal(window)
	require.NoError(t, err)

	require.JSONEq(
		t,
		`{
			"windowId": 123456,
			"fetchDateInMillis": 1754424000000,
			"rates": {"USD": 114521.55, "ARS": 152300000.0, "BTC": 1}
		}`,
		string(got),
	)
}

func TestExchangeRateWindow_RoundTrip(t *testing.T) {
	original := NewExchangeRateWindow(987654, 1754424123456, map[string]float64{
		"EUR": 98765.43,
	})

	serialized, err := json.Marshal(original)
	require.NoError(t, err)

	var deserialized *ExchangeRateWindow
	require.NoError(t, json.Unmarshal(serialized, &deserialized))
	require.Equal(t, original, deserialized)
}

func TestExchangeRateWindow_InvalidArgumentsPanic(t *testing.T) {
	validRates := map[string]float64{"USD": 114521.55}

	require.Panics(t, func() { NewExchangeRateWindow(0, 1754424000000, validRates) })
	require.Panics(t, func() { NewExchangeRateWindow(-1, 1754424000000, validRates) })
	require.Panics(t, func() { NewExchangeRateWindow(123456, 0, validRates) })
	require.Panics(t, func() { NewExchangeRateWindow(123456, 1754424000000, nil) })
	require.Panics(t, func() {
		NewExchangeRateWindow(123456, 1754424000000, map[string]float64{})
	})
}

func TestExchangeRateWindow_IgnoresUnknownFields(t *testing.T) {
	// Adding optional fields to the document later must not break existing readers.
	document := `{
		"windowId": 42,
		"fetchDateInMillis": 1754424000000,
		"rates": {"USD": 114521.55},
		"someFutureField": "ignored"
	}`

	var window *ExchangeRateWindow
	require.NoError(t, json.Unmarshal([]byte(document), &window))
	require.Equal(t, int64(42), window.WindowID)
	require.Equal(t, int64(1754424000000), window.FetchDateInMillis)
	require.Equal(t, map[string]float64{"USD": 114521.55}, window.Rates)
}
