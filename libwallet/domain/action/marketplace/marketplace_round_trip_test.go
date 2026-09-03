package marketplace

import (
	"testing"

	marketplace_data "github.com/muun/libwallet/data/marketplace"
	"github.com/muun/libwallet/service"
)

// The round trip pins the selection contract across the marketplace screens
// using the mock houston data as fixture: every card listed for a country
// can be fetched as an offer for that same country, consistently.
func TestMarketplaceListToDetailRoundTrip(t *testing.T) {
	repository := marketplace_data.NewMarketplaceRepository(
		service.NewMockHoustonService(nil),
	)
	fetchCountries := NewFetchAvailableCountriesAction(repository)
	fetchListings := NewFetchProviderListingsByCountryAction(repository)
	fetchOffer := NewFetchCardOfferAction(repository)

	countries, err := fetchCountries.Run()
	if err != nil {
		t.Fatalf("fetching countries: %v", err)
	}
	if len(countries) == 0 {
		t.Fatal("expected available countries")
	}

	listedSomewhere := false
	for _, country := range countries {
		listings, err := fetchListings.Run(country)
		if err != nil {
			t.Fatalf("fetching listings for %q: %v", country.Code, err)
		}

		for _, listing := range listings {
			listedSomewhere = true
			for _, listedCard := range listing.Cards {
				offer, err := fetchOffer.Run(country, listedCard.UUID)
				if err != nil {
					t.Fatalf(
						"fetching offer for card %q in %q: %v",
						listedCard.UUID, country.Code, err,
					)
				}

				if offer.Provider.UUID != listing.Provider.UUID {
					t.Errorf(
						"card %q: offer provider %q != listing provider %q",
						listedCard.UUID,
						offer.Provider.UUID,
						listing.Provider.UUID,
					)
				}
				if offer.Card.UUID != listedCard.UUID {
					t.Errorf(
						"expected offered card %q, got %q",
						listedCard.UUID, offer.Card.UUID,
					)
				}
				if offer.ShippingCountry.Code != country.Code {
					t.Errorf(
						"card %q: expected shipping country %q, got %q",
						listedCard.UUID,
						country.Code,
						offer.ShippingCountry.Code,
					)
				}
				if offer.CardPrice.InSat <= 0 {
					t.Errorf(
						"card %q: expected a positive sats card price, got %d",
						listedCard.UUID, offer.CardPrice.InSat,
					)
				}
				if offer.CardPrice.InPrimaryCurrency.Currency != "USD" {
					t.Errorf(
						"card %q: expected a USD primary price, got %q",
						listedCard.UUID,
						offer.CardPrice.InPrimaryCurrency.Currency,
					)
				}
			}
		}
	}

	if !listedSomewhere {
		t.Fatal(
			"mock data has no provider listing in any available country",
		)
	}
}

func TestMarketplaceOfferForUnknownCard(t *testing.T) {
	repository := marketplace_data.NewMarketplaceRepository(
		service.NewMockHoustonService(nil),
	)
	fetchCountries := NewFetchAvailableCountriesAction(repository)
	fetchOffer := NewFetchCardOfferAction(repository)

	countries, err := fetchCountries.Run()
	if err != nil {
		t.Fatalf("fetching countries: %v", err)
	}

	_, err = fetchOffer.Run(countries[0], "unknown-card-uuid")
	if err == nil {
		t.Fatal("expected an error for an unknown card uuid")
	}
}
