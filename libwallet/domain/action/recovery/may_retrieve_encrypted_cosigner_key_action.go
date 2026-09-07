package recovery

import (
	"github.com/muun/libwallet/storage"
)

type EncryptedCosignerKeyStatus int

const (
	HasVerifiedEncryptedCosignerKey EncryptedCosignerKeyStatus = iota
	OnlyHasUnverifiedEncryptedCosignerKey
	HasNoEncryptedCosignerKey
)

type MayRetrieveEncryptedCosignerKeyAction struct {
	keyValueStorage *storage.KeyValueStorage
}

type EncryptedCosignerKeyWithStatus struct {
	EncryptedCosignerKey *string
	Status               EncryptedCosignerKeyStatus
}

func NewMayRetrieveEncryptedCosignerKeyAction(
	keyValueStorage *storage.KeyValueStorage,
) *MayRetrieveEncryptedCosignerKeyAction {
	return &MayRetrieveEncryptedCosignerKeyAction{keyValueStorage: keyValueStorage}
}

// Try to retrieve the encrypted cosigner key from the key value storage,
// without incurring a Houston API call if it is not found in storage.
func (a *MayRetrieveEncryptedCosignerKeyAction) Run() (*EncryptedCosignerKeyWithStatus, error) {
	keys, err := a.keyValueStorage.GetBatch([]string{
		storage.UnverifiedEncryptedCosignerKey,
		storage.VerifiedEncryptedCosignerKey,
	})

	if err != nil {
		return nil, err
	}

	if key, ok := keys[storage.VerifiedEncryptedCosignerKey]; ok && key != nil {
		encryptedCosignerKey := key.(string)
		return &EncryptedCosignerKeyWithStatus{
			EncryptedCosignerKey: &encryptedCosignerKey,
			Status:               HasVerifiedEncryptedCosignerKey,
		}, nil
	} else if key, ok := keys[storage.UnverifiedEncryptedCosignerKey]; ok && key != nil {
		encryptedCosignerKey := key.(string)
		return &EncryptedCosignerKeyWithStatus{
			EncryptedCosignerKey: &encryptedCosignerKey,
			Status:               OnlyHasUnverifiedEncryptedCosignerKey,
		}, nil
	} else {
		return &EncryptedCosignerKeyWithStatus{
			EncryptedCosignerKey: nil,
			Status:               HasNoEncryptedCosignerKey,
		}, nil
	}
}
