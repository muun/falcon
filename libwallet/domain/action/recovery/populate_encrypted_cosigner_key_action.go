package recovery

import (
	"log/slog"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/go-errors/errors"

	"github.com/muun/libwallet/data/keys"
	"github.com/muun/libwallet/domain/model/verifiable_cosigner_key"
	"github.com/muun/libwallet/service"
	"github.com/muun/libwallet/storage"
)

type PopulateEncryptedCosignerKeyAction struct {
	houstonService                  service.HoustonService
	keyValueStorage                 *storage.KeyValueStorage
	keyProvider                     keys.KeyProvider
	mayRetrieveEncryptedCosignerKey *MayRetrieveEncryptedCosignerKeyAction
}

func NewPopulateEncryptedCosignerKeyAction(
	houstonService service.HoustonService,
	keyValueStorage *storage.KeyValueStorage,
	keyProvider keys.KeyProvider,
) *PopulateEncryptedCosignerKeyAction {
	return &PopulateEncryptedCosignerKeyAction{
		houstonService:                  houstonService,
		keyValueStorage:                 keyValueStorage,
		keyProvider:                     keyProvider,
		mayRetrieveEncryptedCosignerKey: NewMayRetrieveEncryptedCosignerKeyAction(keyValueStorage),
	}
}

// Populate the encrypted cosigner key in storage. If we already have an unverified cosigner key in
// storage, go to houston and try to get a key that can be verified. This action does not overwrite
// existing keys.
func (a *PopulateEncryptedCosignerKeyAction) Run(recoveryCodePublicKey *btcec.PublicKey) error {
	slog.Warn("PopulateEncryptedCosignerKeyAction.Run: start")

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

	currentStatus, err := a.getCurrentStatus()
	if err != nil {
		return err
	}

	if *currentStatus == HasVerifiedEncryptedCosignerKey {
		// TODO remove this log once it is not necessary anymore
		slog.Warn("PopulateEncryptedCosignerKeyAction.Run: verified key is present, return early")
		return nil
	}

	// we proceed, hoping to obtain a verified key
	verifiableCosignerKeyJSON, err := a.houstonService.VerifiableCosignerKey()
	if err != nil {
		return err
	}

	verifiableCosignerKey, err := verifiable_cosigner_key.VerifiableCosignerKeyFromJSON(
		&verifiableCosignerKeyJSON,
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
		slog.Warn("PopulateEncryptedCosignerKeyAction.Run: store verified key")
		return a.keyValueStorage.Save(
			storage.VerifiedEncryptedCosignerKey,
			encryptedCosignerKeyWithVerificationFlag.EncryptedCosignerKey)
	}

	if *currentStatus == OnlyHasUnverifiedEncryptedCosignerKey {
		// Do not overwrite the existing unverified key
		slog.Warn("PopulateEncryptedCosignerKeyAction.Run: unverified key is present, return")
		return nil
	}

	slog.Warn("PopulateEncryptedCosignerKeyAction.Run: store unverified key")
	return a.keyValueStorage.Save(
		storage.UnverifiedEncryptedCosignerKey,
		encryptedCosignerKeyWithVerificationFlag.EncryptedCosignerKey,
	)
}

func (a *PopulateEncryptedCosignerKeyAction) getCurrentStatus() (
	*EncryptedCosignerKeyStatus, error,
) {
	encryptedCosignerKeyWithStatus, err := a.mayRetrieveEncryptedCosignerKey.Run()
	if err != nil {
		return nil, err
	}

	return &encryptedCosignerKeyWithStatus.Status, nil
}
