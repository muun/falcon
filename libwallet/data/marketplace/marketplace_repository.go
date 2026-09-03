// Package marketplace provides access to the security cards marketplace
// catalog. The final data sourcing is still undefined: it will likely mix
// houston-served data, libwallet storage and hardcoded values. Until that
// lands, the only implementation is backed by the mock houston service and
// its scaffolding JSON.
package marketplace

import (
	"github.com/go-errors/errors"

	marketplace_model "github.com/muun/libwallet/domain/model/marketplace"
	"github.com/muun/libwallet/service"
)

// MarketplaceRepository provides the marketplace catalog and the countries
// where it is available.
type MarketplaceRepository interface { //nolint:revive // marketplace.MarketplaceRepository mirrors the rates repository naming
	Catalog() (*marketplace_model.Catalog, error)
	AvailableCountries() ([]marketplace_model.CountryInfo, error)
}

type houstonMarketplaceRepository struct {
	houstonService service.HoustonService
}

// NewMarketplaceRepository creates a marketplace repository backed by the
// (mock) houston service.
func NewMarketplaceRepository(
	houstonService service.HoustonService,
) MarketplaceRepository {
	return &houstonMarketplaceRepository{houstonService: houstonService}
}

func (r *houstonMarketplaceRepository) Catalog() (
	*marketplace_model.Catalog,
	error,
) {
	marketplaceJSON, err := r.houstonService.FetchSecurityCardsMarketplace()
	if err != nil {
		return nil, errors.Errorf(
			"error fetching marketplace from server: %w", err,
		)
	}

	return mapCatalog(marketplaceJSON)
}

func (r *houstonMarketplaceRepository) AvailableCountries() (
	[]marketplace_model.CountryInfo,
	error,
) {
	countriesJSON, err := r.houstonService.FetchSecurityCardsAvailableCountries()
	if err != nil {
		return nil, errors.Errorf(
			"error fetching marketplace countries from server: %w", err,
		)
	}

	return mapAvailableCountries(countriesJSON), nil
}
