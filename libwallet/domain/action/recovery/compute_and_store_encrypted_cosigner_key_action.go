package recovery

import (
	"log/slog"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/go-errors/errors"

	"github.com/muun/libwallet/data/keys"
	"github.com/muun/libwallet/domain/model/verifiable_cosigner_key"
	"github.com/muun/libwallet/service/model"
	"github.com/muun/libwallet/storage"
)

type ComputeAndStoreEncryptedCosignerKeyAction struct {
	keyValueStorage *storage.KeyValueStorage
	keyProvider     keys.KeyProvider
}

func NewComputeAndStoreEncryptedCosignerKeyAction(
	keyValueStorage *storage.KeyValueStorage,
	keyProvider keys.KeyProvider,
) *ComputeAndStoreEncryptedCosignerKeyAction {
	return &ComputeAndStoreEncryptedCosignerKeyAction{
		keyValueStorage: keyValueStorage,
		keyProvider:     keyProvider,
	}
}

// Verify and store the resulting encrypted cosigner key. This action overwrites existing keys.
func (a *ComputeAndStoreEncryptedCosignerKeyAction) Run(
	recoveryCodePublicKey *btcec.PublicKey,
	verifiableCosignerKeyJSON *model.VerifiableCosignerKeyJSON,
) error {
	slog.Warn("ComputeAndStoreEncryptedCosignerKeyAction.Run: start")

	userHDPrivateKey, err := a.keyProvider.UserPrivateKey()
	if err != nil {
		return errors.Errorf("error getting user key from KeyProvider: %w", err)
	}

	userEcPrivateKey, err := userHDPrivateKey.ECPrivateKey()
	if err != nil {
		return errors.Errorf("error obtaining user ec private key: %w", err)
	}

	cosignerHDPublicKey, err := a.keyProvider.CosignerPublicKey()
	if err != nil {
		return errors.Errorf("error obtaining cosigner key from KeyProvider: %w", err)
	}

	verifiableCosignerKey, err := verifiable_cosigner_key.VerifiableCosignerKeyFromJSON(
		verifiableCosignerKeyJSON,
	)
	if err != nil {
		return err
	}

	encryptedCosignerKeyWithVerificationFlag, err := verifiableCosignerKey.Verify(
		cosignerHDPublicKey,
		userEcPrivateKey,
		recoveryCodePublicKey,
	)
	if err != nil {
		return err
	}

	if encryptedCosignerKeyWithVerificationFlag.Verified {
		slog.Warn("ComputeAndStoreEncryptedCosignerKeyAction.Run: store verified key")

		return a.keyValueStorage.Save(
			storage.VerifiedEncryptedCosignerKey,
			encryptedCosignerKeyWithVerificationFlag.EncryptedCosignerKey)
	}

	slog.Warn("ComputeAndStoreEncryptedCosignerKeyAction.Run: store unverified key")

	return a.keyValueStorage.Save(
		storage.UnverifiedEncryptedCosignerKey,
		encryptedCosignerKeyWithVerificationFlag.EncryptedCosignerKey,
	)
}
