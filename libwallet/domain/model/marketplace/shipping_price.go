package marketplace

import "github.com/muun/libwallet/newop"

// ShippingPrice is one row of a provider's shipping table: the estimated
// price for a set of destination countries.
type ShippingPrice struct {
	Price     *newop.MonetaryAmount
	Countries []CountryInfo
}

func NewShippingPrice(
	price *newop.MonetaryAmount,
	countries []CountryInfo,
) ShippingPrice {
	return ShippingPrice{
		Price:     price,
		Countries: countries,
	}
}
