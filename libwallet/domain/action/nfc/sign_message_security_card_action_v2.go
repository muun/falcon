package nfc

import (
	"context"
	"encoding/hex"
	"log/slog"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/domain/nfc"
	"github.com/muun/libwallet/service"
	"github.com/muun/libwallet/service/model"
	"github.com/muun/libwallet/storage"
)

type SignMessageSecurityCardActionV2 struct {
	muunCard                 *nfc.MuunCardV2
	houstonService           service.HoustonService
	keyValueStorage          *storage.KeyValueStorage
	pairSecurityCardActionV2 *PairSecurityCardActionV2
}

func NewSignMessageSecurityCardActionV2(
	muunCard *nfc.MuunCardV2,
	houstonService service.HoustonService,
	keyValueStorage *storage.KeyValueStorage,
	pairSecurityCardActionV2 *PairSecurityCardActionV2,
) *SignMessageSecurityCardActionV2 {
	return &SignMessageSecurityCardActionV2{
		muunCard:                 muunCard,
		houstonService:           houstonService,
		keyValueStorage:          keyValueStorage,
		pairSecurityCardActionV2: pairSecurityCardActionV2,
	}
}

// The context is unused: neither the V2 card transport nor its Houston calls take one.
func (ac *SignMessageSecurityCardActionV2) Run(_ context.Context) error {

	// Re-pair when the paired version isn't this flow's: nothing paired yet, or a
	// card of a different version was swapped in. See the pairedVersion constants.
	pairedVersion, err := ac.keyValueStorage.Get(storage.KeySecurityCardPairedVersion)
	if err != nil {
		return errors.Errorf("error loading security card info: %w", err)
	}
	if needsPairing(pairedVersion, pairedVersionV2) {
		slog.Debug("doing automatic V2 pairing")
		_, err = ac.pairSecurityCardActionV2.Run()
		if err != nil {
			var noSlotsAvailableErr *NoSlotsAvailableError
			if errors.As(err, &noSlotsAvailableErr) {
				return err
			}
			return &PairInternalError{
				Message: "automating V2 pairing failed",
				Cause:   err,
			}
		}
		err = ac.keyValueStorage.Save(storage.KeySecurityCardPairedVersion, pairedVersionV2)
		if err != nil {
			return errors.Errorf("error saving paired card version: %w", err)
		}
	}

	// For this version, just hardcode a little reason.
	// It is needed for card firmware compatibility
	reasonBytes := []byte("A")
	reasonInHex := hex.EncodeToString(reasonBytes)
	request := model.ChallengeSecurityCardSignJSON{
		ReasonInHex: reasonInHex,
	}
	challengeResponse, err := ac.houstonService.ChallengeSecurityCardSign(request)
	if err != nil {
		return errors.Errorf("error requesting a challenge from houston: %w", err)
	}

	challenge, err := service.MapSecurityCardSignChallengeResponse(challengeResponse)
	if err != nil {
		return errors.Errorf("fail to parse sign challenge response from houston: %w", err)
	}

	signChallengeResponse, err := ac.muunCard.SignChallenge(challenge, reasonBytes)
	if err != nil {
		return errors.Errorf("error signing challenge: %w", err)
	}

	cardPublicKeyInHex := hex.EncodeToString(signChallengeResponse.CardPublicKey)
	macInHex := hex.EncodeToString(signChallengeResponse.MAC)
	securityCardChallengeJSON := model.SolveSecurityCardChallengeJSON{
		PublicKeyInHex: cardPublicKeyInHex,
		MacInHex:       macInHex,
	}

	err = ac.houstonService.SolveSecurityCardChallenge(securityCardChallengeJSON)
	if err != nil {
		var houstonError *service.HoustonResponseError
		if errors.As(err, &houstonError) {
			switch {
			case houstonError.ErrorCode == service.ErrInvalidSignature:
				return &InvalidMacError{
					Message: "error validating signature",
					Cause:   houstonError,
				}
			case houstonError.ErrorCode == service.ErrChallengeExpired:
				return &ChallengeExpiredError{
					Message: "challenge has expired",
					Cause:   houstonError,
				}
			}
		}
		return errors.Errorf("error signing challenge: %w", err)
	}

	return nil
}
