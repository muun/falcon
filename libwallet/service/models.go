package service

type ClientJson struct {
	Type        string `json:"type"`
	BuildType   string `json:"buildType"`
	Version     int    `json:"version"`
	VersionName string `json:"versionName"`
	Language    string `json:"language"`
	// TODO: Add rest of attributes for background execution metrics
}

type PublicKeyJson struct {
	Key  string `json:"key"`
	Path string `json:"path"`
}

type CreateFirstSessionJson struct {
	Client          ClientJson    `json:"client"`
	GcmToken        *string       `json:"gcmToken,omitempty"`
	PrimaryCurrency string        `json:"primaryCurrency"`
	BasePublicKey   PublicKeyJson `json:"basePublicKey"`
}

type CreateFirstSessionOkJson struct {
	CosigningPublicKey  PublicKeyJson `json:"cosigningPublicKey"`
	SwapServerPublicKey PublicKeyJson `json:"swapServerPublicKey"`
	// TODO: user UserJson `json:"client"`
	PlayIntegrityNonce *string `json:"playIntegrityNonce,omitempty"`
}

type FeeWindowJson struct {
	Id int64 `json:"id"`
	// TODO: Using time.Time is ok when we unmarshal FetchDate,
	//  but we need to test that the marshaling also works.
	FetchDate string `json:"fetchDate"`
	// TODO: Check if we are ok with using "string" instead of "int" as key for TargetedFees.
	//  If not, a custom mapping should be created.
	TargetedFees     map[string]float64 `json:"targetedFees"`
	FastConfTarget   int                `json:"fastConfTarget"`
	MediumConfTarget int                `json:"mediumConfTarget"`
	SlowConfTarget   int                `json:"slowConfTarget"`
}

type ChallengeSetupJson struct {
	Type                string `json:"type"`
	PublicKey           string `json:"passwordSecretPublicKey"`
	Salt                string `json:"passwordSecretSalt"`
	EncryptedPrivateKey string `json:"encryptedPrivateKey"`
	Version             string `json:"version"`
}

type ChallengeSetupVerifyJson struct {
	ChallengeType string `json:"type"`
	PublicKey     string `json:"publicKey"`
}

type VerifiableServerCosigningKeyJson struct {
	EphemeralPublicKey       string `json:"ephemeralPublicKey"`
	PaddedServerCosigningKey string `json:"paddedServerCosigningKey"`
	SharedSecretPublicKey    string `json:"sharedSecretPublicKey"`
	Proof                    string `json:"proof"`
}
