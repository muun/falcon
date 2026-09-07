package marketplace

import (
	"github.com/muun/libwallet/domain/model/marketplace/card"
	"github.com/muun/libwallet/domain/model/marketplace/provider"
	"github.com/muun/libwallet/newop"
)

// ProviderListing is a provider's offer for a given country: the cards it
// ships there, the estimated shipping price and the provider's card price.
type ProviderListing struct {
	Provider      provider.Provider
	Cards         []card.Card
	ShippingPrice *newop.BitcoinAmount
	CardPrice     *newop.BitcoinAmount
}

func NewProviderListing(
	provider provider.Provider,
	cards []card.Card,
	shippingPrice *newop.BitcoinAmount,
	cardPrice *newop.BitcoinAmount,
) ProviderListing {
	return ProviderListing{
		Provider:      provider,
		Cards:         cards,
		ShippingPrice: shippingPrice,
		CardPrice:     cardPrice,
	}
}
