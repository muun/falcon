package model

type SolveSecurityCardChallengeJSON struct {
	PublicKeyInHex string `json:"publicKeyInHex"`
	MacInHex       string `json:"macInHex"`
}
