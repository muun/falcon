package model

type CreateFirstSessionJSON struct {
	Client          ClientJSON    `json:"client"`
	GcmToken        *string       `json:"gcmToken,omitempty"`
	PrimaryCurrency string        `json:"primaryCurrency"`
	BasePublicKey   PublicKeyJSON `json:"basePublicKey"`
}
