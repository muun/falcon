package model

type RegisterSecurityCardOkJSON struct {
	Metadata          SecurityCardMetadataJSON `json:"metadata"`
	IsKnownProvider   bool                     `json:"isKnownProvider"`
	IsCardAlreadyUsed bool                     `json:"isCardAlreadyUsed"`
}
