package model

type SetupChallengeResponseJSON struct {
	CosignerKey            *string `json:"muunKey,omitempty"`
	CosignerKeyFingerprint *string `json:"muunKeyFingerprint,omitempty"`
}
