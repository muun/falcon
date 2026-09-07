package model

type ChallengeSecurityCardSignResponseJSON struct {
	ServerPublicKeyInHex string `json:"serverPublicKeyInHex"`
	MacInHex             string `json:"macInHex"`
	CardUsageCount       uint16 `json:"cardUsageCount"`
	PairingSlot          uint16 `json:"pairingSlot"`
}
