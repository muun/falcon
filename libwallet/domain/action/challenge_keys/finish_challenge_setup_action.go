package challenge_keys

import (
	"encoding/hex"
	"log/slog"

	"github.com/btcsuite/btcd/btcec/v2"

	"github.com/muun/libwallet/domain/action/recovery"
	"github.com/muun/libwallet/service"
	"github.com/muun/libwallet/service/model"
	"github.com/muun/libwallet/storage"
)

type FinishChallengeSetupAction struct {
	houstonService                      service.HoustonService
	keyValueStorage                     *storage.KeyValueStorage
	computeAndStoreEncryptedCosignerKey *recovery.ComputeAndStoreEncryptedCosignerKeyAction
}

func NewFinishChallengeSetupAction(
	houstonService service.HoustonService,
	keyValueStorage *storage.KeyValueStorage,
	computeAndStoreEncryptedCosignerKey *recovery.ComputeAndStoreEncryptedCosignerKeyAction,
) *FinishChallengeSetupAction {
	return &FinishChallengeSetupAction{
		houstonService,
		keyValueStorage,
		computeAndStoreEncryptedCosignerKey,
	}
}

func (action *FinishChallengeSetupAction) Run(recoveryCodePublicKey *btcec.PublicKey) error {

	challengeSetupVerifyJSON := model.ChallengeSetupVerifyJSON{
		ChallengeType: "RECOVERY_CODE",
		PublicKey:     hex.EncodeToString(recoveryCodePublicKey.SerializeCompressed()),
	}

	verifiableCosignerKeyJSON, err :=
		action.houstonService.ChallengeSetupFinishWithVerifiableCosignerKey(
			challengeSetupVerifyJSON,
		)
	if err != nil {
		return err
	}

	// If an error occurs during verification we log it, but we do not return it.
	err = action.computeAndStoreEncryptedCosignerKey.Run(
		recoveryCodePublicKey,
		&verifiableCosignerKeyJSON,
	)
	if err != nil {
		slog.Error(
			"An error occurred during encrypted cosigner key verification",
			slog.Any("error", err),
		)
	}
	return nil
}
