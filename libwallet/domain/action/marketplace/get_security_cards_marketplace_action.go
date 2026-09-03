package marketplace

import (
	"fmt"

	"github.com/muun/libwallet/domain/model/marketplace/deprecated"
	"github.com/muun/libwallet/service"
)

type GetSecurityCardsMarketplaceAction struct {
	// TODO: This will be changed in favor of a repository.
	houstonService service.HoustonService
}

func NewGetSecurityCardsMarketplaceAction(houstonService service.HoustonService) *GetSecurityCardsMarketplaceAction { //nolint:lll // TODO: line too long
	return &GetSecurityCardsMarketplaceAction{houstonService: houstonService}
}

func (ac *GetSecurityCardsMarketplaceAction) Run() (*deprecated.Marketplace, error) {
	marketplaceJSON, err := ac.houstonService.FetchSecurityCardsMarketplace()
	if err != nil {
		return nil, fmt.Errorf("error fetching security cards marketplace from server: %w", err) //nolint:forbidigo // TODO: use errors.Errorf from go-errors for stack traces
	}

	return service.MapSecurityCardsMarketplace(marketplaceJSON)
}
