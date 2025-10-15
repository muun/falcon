package model

type RegisterSecurityCardJson struct {
	CardPublicKeyInHex   string                   `json:"cardPublicKeyInHex"`
	ClientPublicKeyInHex string                   `json:"clientPublicKeyInHex"`
	PairingSlot          int                      `json:"pairingSlot"`
	Metadata             SecurityCardMetadataJson `json:"metadata"`
	MacInHex             string                   `json:"macInHex"`
	GlobalSignCardInHex  string                   `json:"globalSignCardInHex"`
}
