package marketplace

import (
	"strconv"
	"strings"

	"github.com/go-errors/errors"
	"github.com/shopspring/decimal"

	marketplace_model "github.com/muun/libwallet/domain/model/marketplace"
	"github.com/muun/libwallet/domain/model/marketplace/card"
	"github.com/muun/libwallet/domain/model/marketplace/provider"
	"github.com/muun/libwallet/newop"
	"github.com/muun/libwallet/service/model"
)

// The mapping in this file is scaffolding, expected to change: it translates
// SecurityCardsMarketplaceJSON, which doesn't represent any real server
// contract. That JSON exists only so the new endpoints can coexist with the
// deprecated marketplace implementation (both read the same mock dataset),
// and so the mock data can be tweaked as data instead of hardcoded Go spread
// through the codebase. Once the real data sourcing lands (a mix of houston,
// libwallet storage and hardcoded values), this mapping dies with the JSON.
func mapCatalog(
	in model.SecurityCardsMarketplaceJSON,
) (*marketplace_model.Catalog, error) {
	providers := make(
		[]marketplace_model.ProviderCatalog, 0, len(in.Providers),
	)
	for _, p := range in.Providers {
		cardPrice, err := mapMonetaryAmount(p.CardPrice)
		if err != nil {
			return nil, err
		}
		shippingPrices, err := mapShippingPrices(p.EstimatedShippingPrices)
		if err != nil {
			return nil, err
		}

		providers = append(
			providers,
			marketplace_model.NewProviderCatalog(
				mapProvider(p),
				mapCards(p.SecurityCards),
				cardPrice,
				shippingPrices,
				p.MinShippingTimeDays,
				p.MaxShippingTimeDays,
			),
		)
	}
	return marketplace_model.NewCatalog(providers), nil
}

func mapAvailableCountries(
	in model.SecurityCardsAvailableCountriesJSON,
) []marketplace_model.CountryInfo {
	countries := make(
		[]marketplace_model.CountryInfo, 0, len(in.Countries),
	)
	for _, country := range in.Countries {
		countries = append(
			countries,
			marketplace_model.NewCountryInfo(country.Code),
		)
	}
	return countries
}

func mapProvider(
	in model.SecurityCardsProviderJSON,
) provider.Provider {
	return provider.NewProvider(
		in.UUID,
		in.Name,
		in.SiteURL,
		mapProviderTheme(in.LightTheme),
		mapProviderTheme(in.DarkTheme),
	)
}

func mapProviderTheme(
	in model.SecurityCardProviderThemeJSON,
) provider.Theme {
	return provider.NewTheme(
		parseColorHex(in.PrimaryColor),
		parseColorHex(in.SurfaceColor),
	)
}

func mapCards(in []model.SecurityCardJSON) []card.Card {
	out := make([]card.Card, 0, len(in))
	for _, c := range in {
		out = append(out, mapCard(c))
	}
	return out
}

func mapCard(in model.SecurityCardJSON) card.Card {
	return card.NewCard(
		in.UUID,
		in.Sku,
		in.ImageURL,
		in.HasStock,
		parseMaterial(in.Material),
		in.WidthMm,
		in.HeightMm,
		in.ThicknessMm,
		in.WeightGrams,
		parseSecureElement(in.SecureElement),
	)
}

func mapShippingPrices(
	in []model.ShippingPriceInfoJSON,
) ([]marketplace_model.ShippingPrice, error) {
	out := make([]marketplace_model.ShippingPrice, 0, len(in))
	for _, sp := range in {
		price, err := mapMonetaryAmount(sp.Price)
		if err != nil {
			return nil, err
		}

		countries := make(
			[]marketplace_model.CountryInfo, 0, len(sp.Countries),
		)
		for _, c := range sp.Countries {
			countries = append(
				countries,
				marketplace_model.NewCountryInfo(c.Code),
			)
		}
		out = append(
			out,
			marketplace_model.NewShippingPrice(price, countries),
		)
	}
	return out, nil
}

// mapMonetaryAmount translates a fiat price into a monetary amount. Its
// sats and primary currency equivalents are not part of the source data:
// the domain computes them, from the rates and primary currency the actions
// provide, when answering each screen.
func mapMonetaryAmount(
	in model.PriceInfoJSON,
) (*newop.MonetaryAmount, error) {
	value, err := decimal.NewFromString(in.Amount)
	if err != nil {
		return nil, errors.Errorf(
			"unparseable price amount %q: %w", in.Amount, err,
		)
	}
	return &newop.MonetaryAmount{
		Value:    value,
		Currency: in.CurrencyCode,
	}, nil
}

// TODO: fail on unknown materials instead of silently defaulting to plastic.
func parseMaterial(s string) card.Material {
	switch strings.ToUpper(s) {
	case "METAL":
		return card.MaterialMetal
	default:
		return card.MaterialPlastic
	}
}

// TODO: fail on unknown secure elements instead of silently defaulting to
// EAL5.
func parseSecureElement(s string) card.SecureElement {
	switch strings.ToUpper(s) {
	case "EAL_5_PLUS":
		return card.SecureElementEAL5Plus
	case "EAL_6":
		return card.SecureElementEAL6
	case "EAL_6_PLUS":
		return card.SecureElementEAL6Plus
	default:
		return card.SecureElementEAL5
	}
}

// TODO: fail on malformed colors instead of silently mapping them to 0.
func parseColorHex(s string) uint32 {
	s = strings.TrimPrefix(s, "#")
	if len(s) > 8 {
		s = s[:8]
	}
	v, _ := strconv.ParseUint(s, 16, 32)
	return uint32(v)
}
