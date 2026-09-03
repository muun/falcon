package marketplace

import (
	"github.com/go-errors/errors"
)

// Catalog is the full security cards marketplace universe: every provider,
// the cards they sell and where they ship. The selection rules that answer
// each screen's question live here.
type Catalog struct {
	Providers []ProviderCatalog
}

func NewCatalog(providers []ProviderCatalog) *Catalog {
	return &Catalog{Providers: providers}
}

// ListingsFor answers which providers ship to the given country: the cards
// each one offers there, its estimated shipping price and its card price.
// rates maps a currency code to the price of one BTC in that currency;
// together with primaryCurrency it prices every amount in sats, in the
// provider's currency and in the user's primary currency.
func (c *Catalog) ListingsFor(
	country CountryInfo,
	rates map[string]float64,
	primaryCurrency string,
) ([]ProviderListing, error) {
	var listings []ProviderListing

	for _, p := range c.Providers {
		fiatShippingPrice, ships := p.ShippingTo(country)
		if !ships {
			continue
		}

		shippingPrice, err := toBitcoinAmount(fiatShippingPrice, rates, primaryCurrency)
		if err != nil {
			return nil, err
		}
		cardPrice, err := toBitcoinAmount(p.CardPrice, rates, primaryCurrency)
		if err != nil {
			return nil, err
		}

		listings = append(listings, NewProviderListing(
			p.Provider,
			p.Cards,
			shippingPrice,
			cardPrice,
		))
	}

	return listings, nil
}

// OfferFor answers a provider's offer of the given card for the given
// country: the card itself plus the provider's shipping terms there.
// rates maps a currency code to the price of one BTC in that currency;
// together with primaryCurrency it prices every amount in sats, in the
// provider's currency and in the user's primary currency.
func (c *Catalog) OfferFor(
	country CountryInfo,
	cardUUID string,
	rates map[string]float64,
	primaryCurrency string,
) (*CardOffer, error) {
	for _, p := range c.Providers {
		for _, providerCard := range p.Cards {
			if providerCard.UUID != cardUUID {
				continue
			}

			fiatShippingPrice, ships := p.ShippingTo(country)
			if !ships {
				return nil, errors.Errorf(
					"provider %q does not ship to country %q",
					p.Provider.UUID, country.Code,
				)
			}

			shippingPrice, err := toBitcoinAmount(fiatShippingPrice, rates, primaryCurrency)
			if err != nil {
				return nil, err
			}
			cardPrice, err := toBitcoinAmount(p.CardPrice, rates, primaryCurrency)
			if err != nil {
				return nil, err
			}

			return NewCardOffer(
				p.Provider,
				providerCard,
				country,
				p.MinShippingTimeDays,
				p.MaxShippingTimeDays,
				shippingPrice,
				cardPrice,
			), nil
		}
	}

	return nil, errors.Errorf(
		"security card with uuid %q not found", cardUUID,
	)
}
