package marketplace

import (
	"github.com/go-errors/errors"
	"github.com/shopspring/decimal"

	"github.com/muun/libwallet/newop"
)

const satsPerBitcoin = 100_000_000

// toBitcoinAmount converts a fiat amount into its sats / input currency /
// primary currency triple. rates maps a currency code to the price of
// one BTC in that currency.
//
// NOTE: deliberately duplicated from newop/money.go
// (MonetaryAmount.toBitcoinAmount and ExchangeRateWindow.convert), which are
// unexported there. Unlike the originals, this version propagates missing
// rates as errors instead of computing over zero values.
func toBitcoinAmount(
	amount *newop.MonetaryAmount,
	rates map[string]float64,
	primaryCurrency string,
) (*newop.BitcoinAmount, error) {
	inputRate, ok := rates[amount.Currency]
	if !ok {
		return nil, errors.Errorf(
			"no exchange rate for currency %q", amount.Currency,
		)
	}
	primaryRate, ok := rates[primaryCurrency]
	if !ok {
		return nil, errors.Errorf(
			"no exchange rate for currency %q", primaryCurrency,
		)
	}

	valueInBtc := amount.Value.Div(decimal.NewFromFloat(inputRate))
	inSat := valueInBtc.
		Mul(decimal.NewFromInt(satsPerBitcoin)).
		RoundBank(0).
		IntPart()
	inPrimaryCurrency := &newop.MonetaryAmount{
		Value:    valueInBtc.Mul(decimal.NewFromFloat(primaryRate)),
		Currency: primaryCurrency,
	}

	return &newop.BitcoinAmount{
		InSat:             inSat,
		InInputCurrency:   amount,
		InPrimaryCurrency: inPrimaryCurrency,
	}, nil
}
