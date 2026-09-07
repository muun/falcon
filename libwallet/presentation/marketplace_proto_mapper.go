package presentation

import (
	"github.com/muun/libwallet/domain/model/marketplace/card"
	"github.com/muun/libwallet/domain/model/marketplace/provider"
	"github.com/muun/libwallet/newop"
	"github.com/muun/libwallet/presentation/api"
)

func toProtoSCMProvider(in provider.Provider) *api.SCMProvider {
	return api.SCMProvider_builder{
		Uuid:    in.UUID,
		Name:    in.Name,
		SiteUrl: in.SiteURL,
		LightTheme: toProtoSCMProviderTheme(
			in.LightTheme,
		),
		DarkTheme: toProtoSCMProviderTheme(
			in.DarkTheme,
		),
	}.Build()
}

func toProtoSCMProviderTheme(in provider.Theme) *api.SCMProviderTheme {
	return api.SCMProviderTheme_builder{
		PrimaryColorHex: in.PrimaryColorHex,
		SurfaceColorHex: in.SurfaceColorHex,
	}.Build()
}

func toProtoSCMCards(in []card.Card) []*api.SCMCard {
	out := make([]*api.SCMCard, 0, len(in))
	for _, c := range in {
		out = append(out, toProtoSCMCard(c))
	}
	return out
}

func toProtoSCMCard(in card.Card) *api.SCMCard {
	return api.SCMCard_builder{
		Uuid:     in.UUID,
		Sku:      in.SKU,
		ImageUrl: in.ImageURL,
		HasStock: in.HasStock,
	}.Build()
}

func toProtoSCMCardMaterial(in card.Material) api.SCMCardMaterial {
	switch in {
	case card.MaterialMetal:
		return api.SCMCardMaterial_SCM_MATERIAL_METAL
	default:
		return api.SCMCardMaterial_SCM_MATERIAL_PLASTIC
	}
}

func toProtoSCMSecureElement(in card.SecureElement) api.SCMSecureElement {
	switch in {
	case card.SecureElementEAL5Plus:
		return api.SCMSecureElement_SCM_EAL_5_PLUS
	case card.SecureElementEAL6:
		return api.SCMSecureElement_SCM_EAL_6
	case card.SecureElementEAL6Plus:
		return api.SCMSecureElement_SCM_EAL_6_PLUS
	default:
		return api.SCMSecureElement_SCM_EAL_5
	}
}

func toProtoSCMBitcoinAmount(
	in *newop.BitcoinAmount,
) *api.SCMBitcoinAmount {
	return api.SCMBitcoinAmount_builder{
		InSat: in.InSat,
		InInputCurrency: toProtoSCMMonetaryAmount(
			in.InInputCurrency,
		),
		InPrimaryCurrency: toProtoSCMMonetaryAmount(
			in.InPrimaryCurrency,
		),
	}.Build()
}

func toProtoSCMMonetaryAmount(
	in *newop.MonetaryAmount,
) *api.SCMMonetaryAmount {
	return api.SCMMonetaryAmount_builder{
		CurrencyCode: in.Currency,
		Amount:       in.ValueAsString(),
	}.Build()
}
