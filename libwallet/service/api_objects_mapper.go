package service

import (
	"encoding/binary"
	"encoding/hex"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/domain/nfc"
	"github.com/muun/libwallet/service/model"
)

func MapRegisterSecurityCardJSON(
	pairingResponse *nfc.PairingResponse,
	clientPublicKey []byte,
) (*model.RegisterSecurityCardJSON, error) {

	metadata, err := mapSecurityCardMetadataJSON(pairingResponse.Metadata)
	if err != nil {
		return nil, err
	}

	return &model.RegisterSecurityCardJSON{
		CardPublicKeyInHex:   hex.EncodeToString(pairingResponse.CardPublicKey),
		ClientPublicKeyInHex: hex.EncodeToString(clientPublicKey),
		PairingSlot:          binary.BigEndian.Uint16(pairingResponse.PairingSlot),
		Metadata:             *metadata,
		MacInHex:             hex.EncodeToString(pairingResponse.MAC),
		GlobalSignCardInHex:  hex.EncodeToString(pairingResponse.GlobalSignature),
	}, nil
}

func mapSecurityCardMetadataJSON(
	metadata *nfc.CardMetadata,
) (*model.SecurityCardMetadataJSON, error) {
	if metadata == nil {
		return nil, errors.Errorf("missing card metadata in pairing response")
	}

	globalPubCardInHex := hex.EncodeToString(metadata.GlobalPubCard[:])
	cardVendorInHex := hex.EncodeToString(metadata.CardVendor[:])
	cardModelInHex := hex.EncodeToString(metadata.CardModel[:])
	firmwareVersion := binary.BigEndian.Uint16(metadata.FirmwareVersion[:])
	languageCodeInHex := hex.EncodeToString(metadata.LanguageCode[:])

	metadataJSON := &model.SecurityCardMetadataJSON{
		GlobalPublicKeyInHex: globalPubCardInHex,
		CardVendorInHex:      cardVendorInHex,
		CardModelInHex:       cardModelInHex,
		FirmwareVersion:      firmwareVersion,
		UsageCount:           metadata.UsageCount,
		LanguageCodeInHex:    languageCodeInHex,
	}

	return metadataJSON, nil
}

func mapSecurityCardV3MetadataJSON(
	metadata *nfc.CardMetadataV3,
) (*model.SecurityCardV3MetadataJSON, error) {
	if metadata == nil {
		return nil, errors.Errorf("missing card metadata in pairing response")
	}

	return &model.SecurityCardV3MetadataJSON{
		AttestationPubKeyInHex: hex.EncodeToString(metadata.AttestationPub[:]),
		CardVendorInHex:        hex.EncodeToString(metadata.CardVendor[:]),
		CardModelInHex:         hex.EncodeToString(metadata.CardModel[:]),
		FirmwareVersion:        binary.BigEndian.Uint16(metadata.FirmwareVersion[:]),
		CapabilitiesInHex:      hex.EncodeToString(metadata.Capabilities[:]),
		OperationCount:         metadata.OperationCount,
		ProviderPubKeyInHex:    hex.EncodeToString(metadata.ProviderPub[:]),
		ProviderSigInHex:       hex.EncodeToString(metadata.ProviderSig),
	}, nil
}
