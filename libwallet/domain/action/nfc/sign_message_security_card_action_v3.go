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

// SignMessageSecurityCardActionV3 drives the full V3 challenge-response
// flow end to end: it asks Houston for a challenge (server ephemeral key,
// reason, per-card MAC + replay counter), taps the card to sign it, and
// submits the card's response (ephemeral pubkey + MAC) back to Houston.
// It pairs first whenever the stored paired version is not V3.
//
// PROVISIONAL: it runs against the local MockHoustonService and signs an
// empty-reason challenge, since reason generation is future Houston work.
// Replace it with the real V3 sign flow once Houston supports one.
type SignMessageSecurityCardActionV3 interface {
	// Run signs a challenge with the tapped card, pairing first when needed.
	Run(ctx context.Context) error
}

type signMessageSecurityCardActionV3 struct {
	muunCard                 *nfc.MuunCardV3
	houstonService           service.HoustonService
	keyValueStorage          *storage.KeyValueStorage
	pairSecurityCardActionV3 PairSecurityCardActionV3
}

func NewSignMessageSecurityCardActionV3(
	muunCard *nfc.MuunCardV3,
	houstonService service.HoustonService,
	keyValueStorage *storage.KeyValueStorage,
	pairSecurityCardActionV3 PairSecurityCardActionV3,
) SignMessageSecurityCardActionV3 {
	return &signMessageSecurityCardActionV3{
		muunCard:                 muunCard,
		houstonService:           houstonService,
		keyValueStorage:          keyValueStorage,
		pairSecurityCardActionV3: pairSecurityCardActionV3,
	}
}

func (ac *signMessageSecurityCardActionV3) Run(ctx context.Context) error {
	// Re-pair when the paired version isn't this flow's: nothing paired yet, or a
	// card of a different version was swapped in. See the pairedVersion constants.
	pairedVersion, err := ac.keyValueStorage.Get(storage.KeySecurityCardPairedVersion)
	if err != nil {
		return errors.Errorf("error loading security card info: %w", err)
	}
	if needsPairing(pairedVersion, pairedVersionV3) {
		slog.Info("Pairing security card automatically", "cardVersion", "V3")
		if _, err := ac.pairSecurityCardActionV3.Run(ctx); err != nil {
			var noSlotsAvailableErr *NoSlotsAvailableError
			if errors.As(err, &noSlotsAvailableErr) {
				return err
			}
			return &PairInternalError{
				Message: "automating V3 pairing failed",
				Cause:   err,
			}
		}
		err = ac.keyValueStorage.Save(storage.KeySecurityCardPairedVersion, pairedVersionV3)
		if err != nil {
			return errors.Errorf("error saving paired card version: %w", err)
		}
	}

	// Empty reason: the mock ignores the action and generates no reason
	// yet (real action/reason generation is future Houston work).
	request := model.SignRequestChallengeJSON{}

	slog.Info("Requesting security card sign challenge", "cardVersion", "V3")
	signRequestChallengeResponseJSON, err := ac.houstonService.SignRequestChallenge(request)
	if err != nil {
		return errors.Errorf("error requesting a challenge from houston: %w", err)
	}

	if len(signRequestChallengeResponseJSON.PerCardPayloads) == 0 {
		return errors.New("sign challenge response carried no per-card payloads")
	}
	// Single-slot today: the card the user taps matches the only payload.
	payload := signRequestChallengeResponseJSON.PerCardPayloads[0]

	challenge, err := service.MapSecurityCardSignChallengeV3(
		signRequestChallengeResponseJSON,
		payload,
	)
	if err != nil {
		return err
	}

	slog.Info(
		"Tapping security card to sign",
		"cardVersion", "V3",
		"counter", challenge.Counter,
		"index", challenge.Index,
		"reasonLength", len(challenge.Reason),
	)
	session, err := ac.muunCard.Connect(ctx)
	if err != nil {
		return mapCardSignError(err)
	}

	signChallengeResponse, err := session.SignChallenge(ctx, challenge)
	if err != nil {
		return mapCardSignError(err)
	}
	slog.Info("Submitting security card sign response", "cardVersion", "V3")

	submitJSON := model.SignSubmitSignedChallengeJSON{
		// Empty while the mock is single-slot; see the model TODO.
		AttestationPubKeyInHex: "",
		CardPubKeyInHex:        hex.EncodeToString(signChallengeResponse.CardPublicKey),
		MacInHex:               hex.EncodeToString(signChallengeResponse.MAC),
	}

	err = ac.houstonService.SignSubmitSignedChallenge(submitJSON)
	if err != nil {
		if mapped := mapHoustonCardError(err); mapped != nil {
			return mapped
		}
		return errors.Errorf("error submitting signed challenge: %w", err)
	}

	return nil
}

// mapCardSignError translates card-transport/protocol errors from the
// sign flow into the action-level error types the presentation layer
// discriminates on.
func mapCardSignError(err error) error {
	var cardError *nfc.CardError
	if errors.As(err, &cardError) && cardError.Code == nfc.ErrAppletIDNotFound {
		return &MuunAppletNotFoundError{
			Message: "muun applet not found",
			Cause:   err,
		}
	}
	return errors.Errorf("error signing challenge with card: %w", err)
}
