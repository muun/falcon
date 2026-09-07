package model

type SecurityCardsAvailableCountriesJSON struct {
	Countries []CountryInfoJSON `json:"countries"`
}

type SecurityCardsMarketplaceJSON struct {
	Providers []SecurityCardsProviderJSON `json:"providers"`
	Specs     []SecurityCardSpecJSON      `json:"specs"`
}

type SecurityCardSpecJSON struct {
	SpecID string                                `json:"specId"`
	Items  map[string][]SecurityCardSpecItemJSON `json:"items"`
}

type SecurityCardSpecItemJSON struct {
	IconURL        string `json:"iconUrl"`
	Label          string `json:"label"`
	Value          string `json:"value"`
	AdditionalData string `json:"additionalData"`
}

type SecurityCardsProviderJSON struct {
	ID                      string                        `json:"id"`
	UUID                    string                        `json:"uuid"`
	Name                    string                        `json:"name"`
	Description             string                        `json:"description"`
	SiteURL                 string                        `json:"siteUrl"`
	LightTheme              SecurityCardProviderThemeJSON `json:"lightTheme"`
	DarkTheme               SecurityCardProviderThemeJSON `json:"darkTheme"`
	CardPrice               PriceInfoJSON                 `json:"cardPrice"`
	SecurityCards           []SecurityCardJSON            `json:"securityCards"`
	EstimatedShippingPrices []ShippingPriceInfoJSON       `json:"estimatedShippingPrices"`
	MinShippingTimeDays     int32                         `json:"minShippingTimeDays"`
	MaxShippingTimeDays     int32                         `json:"maxShippingTimeDays"`
}

type SecurityCardJSON struct {
	ID            string  `json:"id"`
	UUID          string  `json:"uuid"`
	ImageURL      string  `json:"imageUrl"`
	Tag           string  `json:"tag"`
	SpecID        string  `json:"specId"`
	Sku           string  `json:"sku"`
	Material      string  `json:"material"`
	WidthMm       float32 `json:"widthMm"`
	HeightMm      float32 `json:"heightMm"`
	ThicknessMm   float32 `json:"thicknessMm"`
	WeightGrams   float32 `json:"weightGrams"`
	SecureElement string  `json:"secureElement"`
	HasStock      bool    `json:"hasStock"`
}

type SecurityCardProviderThemeJSON struct {
	PrimaryColor string `json:"primaryColor"`
	SurfaceColor string `json:"surfaceColor"`
}

type ShippingPriceInfoJSON struct {
	Price     PriceInfoJSON     `json:"price"`
	Countries []CountryInfoJSON `json:"countries"`
}

type PriceInfoJSON struct {
	CurrencyCode string `json:"currencyCode"`
	Amount       string `json:"amount"`
}

type CountryInfoJSON struct {
	Code string `json:"code"`
	Name string `json:"name"`
	Flag string `json:"flag"`
}
