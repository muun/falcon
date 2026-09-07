package service

import (
	"encoding/hex"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/domain/model/marketplace/deprecated"
	"github.com/muun/libwallet/domain/model/security_card"
	"github.com/muun/libwallet/service/model"
)

func MapSecurityCardPaired(in model.RegisterSecurityCardOkJSON) *security_card.SecurityCardPaired {
	return security_card.NewSecurityCardPaired(
		mapSecurityCardMetadata(in.Metadata),
		in.IsKnownProvider,
		in.IsCardAlreadyUsed,
	)
}

func MapSecurityCardPairedV3(
	in model.PairSubmitSignedChallengeResponseJSON,
) *security_card.SecurityCardPaired {
	// The response carries card metadata (in.SecurityCard.Metadata), but
	// nothing consumes it yet, so we skip parsing it.
	// TODO: map the metadata once a caller needs it.
	return security_card.NewSecurityCardPaired(
		nil,
		in.IsKnownProvider,
		in.IsCardAlreadyUsed,
	)
}

func mapSecurityCardMetadata(
	in model.SecurityCardMetadataJSON,
) *security_card.SecurityCardMetadata {
	return security_card.NewSecurityCardMetadata(
		in.GlobalPublicKeyInHex,
		in.CardVendorInHex,
		in.CardModelInHex,
		in.FirmwareVersion,
		in.UsageCount,
		in.LanguageCodeInHex,
	)
}

func MapSecurityCardSignChallengeResponse(
	in model.ChallengeSecurityCardSignResponseJSON,
) (*security_card.SecurityCardSignChallenge, error) {

	serverPublicKeyBytes, err := hex.DecodeString(in.ServerPublicKeyInHex)
	if err != nil {
		return nil, errors.Errorf("error decoding server public key: %w", err)
	}

	macBytes, err := hex.DecodeString(in.MacInHex)
	if err != nil {
		return nil, errors.Errorf("error decoding mac: %w", err)
	}

	return security_card.NewSecurityCardSignChallenge(
		serverPublicKeyBytes,
		macBytes,
		in.CardUsageCount,
		in.PairingSlot,
	), nil
}

func MapSecurityCardSignChallengeV3(
	in model.SignRequestChallengeResponseJSON,
	payload model.SignChallengePerCardPayloadJSON,
) (*security_card.SecurityCardSignChallengeV3, error) {

	serverPublicKey, err := hex.DecodeString(in.ServerPubKeyInHex)
	if err != nil {
		return nil, errors.Errorf("error decoding server public key: %w", err)
	}

	reason, err := hex.DecodeString(in.ReasonInHex)
	if err != nil {
		return nil, errors.Errorf("error decoding reason: %w", err)
	}

	mac, err := hex.DecodeString(payload.MacInHex)
	if err != nil {
		return nil, errors.Errorf("error decoding challenge mac: %w", err)
	}

	return security_card.NewSecurityCardSignChallengeV3(
		serverPublicKey,
		payload.ReplayCounter,
		payload.Index,
		reason,
		mac,
	)
}

func MapSecurityCardsMarketplace(
	in model.SecurityCardsMarketplaceJSON,
) (*deprecated.Marketplace, error) {

	providers := make([]deprecated.SecurityCardsProvider, 0, len(in.Providers))
	for _, provider := range in.Providers {

		securityCards := make(
			[]deprecated.SecurityCard,
			0,
			len(provider.SecurityCards),
		)
		for _, sc := range provider.SecurityCards {
			securityCards = append(securityCards, deprecated.NewSecurityCard(
				sc.ID,
				sc.ImageURL,
				sc.Tag,
				sc.SpecID,
				mapDeprecatedPriceInfo(provider.CardPrice),
			))
		}

		shippingPrices := make(
			[]deprecated.ShippingPrice,
			0,
			len(provider.EstimatedShippingPrices),
		)
		for _, shippingPrice := range provider.EstimatedShippingPrices {

			countries := make([]deprecated.Country, 0, len(shippingPrice.Countries))
			for _, country := range shippingPrice.Countries {
				countries = append(countries, deprecated.NewCountry(
					country.Code,
					country.Name,
					country.Flag,
				))
			}

			shippingPrices = append(shippingPrices, deprecated.NewShippingPrice(
				mapDeprecatedPriceInfo(shippingPrice.Price),
				countries,
			))
		}

		providers = append(providers, deprecated.NewSecurityCardsProvider(
			provider.ID,
			provider.Name,
			provider.Description,
			provider.SiteURL,
			mapDeprecatedProviderTheme(provider.LightTheme),
			mapDeprecatedProviderTheme(provider.DarkTheme),
			securityCards,
			shippingPrices,
		))
	}

	specs := make([]deprecated.SecurityCardSpec, 0, len(in.Specs))
	for _, spec := range in.Specs {

		items := make(map[string][]deprecated.SpecItem, len(spec.Items))
		for category, specItems := range spec.Items {
			mapped := make([]deprecated.SpecItem, 0, len(specItems))
			for _, item := range specItems {
				mapped = append(mapped, deprecated.NewSpecItem(
					item.IconURL,
					item.Label,
					item.Value,
					item.AdditionalData,
				))
			}
			items[category] = mapped
		}

		specs = append(specs, deprecated.NewSecurityCardSpec(
			spec.SpecID,
			items,
		))
	}

	return deprecated.NewMarketplace(providers, specs), nil
}

func mapDeprecatedPriceInfo(in model.PriceInfoJSON) deprecated.Price {
	return deprecated.NewPrice(in.CurrencyCode, in.Amount)
}

func mapDeprecatedProviderTheme(in model.SecurityCardProviderThemeJSON) deprecated.ProviderTheme {
	return deprecated.NewProviderTheme(in.PrimaryColor, in.SurfaceColor)
}
