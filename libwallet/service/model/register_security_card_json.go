package model

type RegisterSecurityCardJSON struct {
	CardPublicKeyInHex   string                   `json:"cardPublicKeyInHex"`
	ClientPublicKeyInHex string                   `json:"clientPublicKeyInHex"`
	PairingSlot          uint16                   `json:"pairingSlot"`
	Metadata             SecurityCardMetadataJSON `json:"metadata"`
	MacInHex             string                   `json:"macInHex"`
	GlobalSignCardInHex  string                   `json:"globalSignCardInHex"`
}
