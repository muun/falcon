package marketplace

import (
	"github.com/muun/libwallet/domain/model/marketplace/card"
	"github.com/muun/libwallet/domain/model/marketplace/provider"
	"github.com/muun/libwallet/newop"
)

// ProviderCatalog is one provider's full catalog entry: the cards it sells,
// its card price, its shipping times and everywhere it ships.
type ProviderCatalog struct {
	Provider            provider.Provider
	Cards               []card.Card
	CardPrice           *newop.MonetaryAmount
	ShippingPrices      []ShippingPrice
	MinShippingTimeDays int32
	MaxShippingTimeDays int32
}

func NewProviderCatalog(
	provider provider.Provider,
	cards []card.Card,
	cardPrice *newop.MonetaryAmount,
	shippingPrices []ShippingPrice,
	minShippingTimeDays int32,
	maxShippingTimeDays int32,
) ProviderCatalog {
	return ProviderCatalog{
		Provider:            provider,
		Cards:               cards,
		CardPrice:           cardPrice,
		ShippingPrices:      shippingPrices,
		MinShippingTimeDays: minShippingTimeDays,
		MaxShippingTimeDays: maxShippingTimeDays,
	}
}

// ShippingTo returns the provider's estimated shipping price for the given
// country, and whether the provider ships there at all.
func (p *ProviderCatalog) ShippingTo(
	country CountryInfo,
) (*newop.MonetaryAmount, bool) {
	for _, shippingPrice := range p.ShippingPrices {
		for _, shippingCountry := range shippingPrice.Countries {
			if shippingCountry.Code == country.Code {
				return shippingPrice.Price, true
			}
		}
	}
	return nil, false
}
