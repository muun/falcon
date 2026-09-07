package app_provided_data

type KeyData struct {
	Serialized string
	Path       string
}

// Use keys.KeyProvider instead of KeyProvider to access keys. This is a low-level interface at the
// boundary with native code that should only be used within the keys.KeyProvider wrapper.
type KeyProvider interface {
	FetchUserKey() (*KeyData, error)
	// TODO(#16998): rename to FetchCosignerKey; part of the gomobile contract with the apps.
	FetchMuunKey() (*KeyData, error)
	// TODO(#16998): rename to FetchEncryptedCosignerPrivateKey; gomobile contract with the apps.
	FetchEncryptedMuunPrivateKey() (string, error)
	FetchMaxDerivedIndex() int
}
