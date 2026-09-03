package nfc

import (
	"context"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/domain/nfc"
)

// The paired card's firmware version, recorded under storage.KeySecurityCardPairedVersion
// so a sign flow can re-pair when a different-version card is swapped in. Derived from the
// applet today: V3 pins the exact version ("0300") so a future 3.x is told apart; V2 pins
// only the major ("02XX") since several V2 minors are already deployed.
const (
	pairedVersionV2 = "02XX"
	pairedVersionV3 = "0300"
)

// needsPairing reports whether a sign flow has to pair before it can sign: either nothing
// is paired yet, or the card paired last ran a different protocol version. storedVersion
// comes straight from the key-value store, so a missing key (nil) or an unexpected type
// both mean "not paired with this version".
func needsPairing(storedVersion any, flowVersion string) bool {
	version, ok := storedVersion.(string)
	return !ok || version != flowVersion
}

// SignMessageSecurityCardAction signs with whichever security card the user taps.
// It runs one protocol version's flow and falls back to the other when the card
// carries no applet for it, so the client no longer needs a feature flag to pick
// the protocol. A card with no known muun applet yields UnsupportedCardVersionError
// to be handled by clients.
type SignMessageSecurityCardAction interface {
	// Run signs a challenge with the tapped card, whichever protocol version it runs.
	Run(ctx context.Context) error
}

// signMessageFlow is one protocol version's sign flow as the dispatcher sees it: it either
// signs with the tapped card or reports that the card carries no applet for its version.
type signMessageFlow interface {
	Run(ctx context.Context) error
}

type signMessageSecurityCardAction struct {
	signMessageSecurityCardV2 signMessageFlow
	signMessageSecurityCardV3 signMessageFlow
}

func NewSignMessageSecurityCardAction(
	signMessageSecurityCardV2 signMessageFlow,
	signMessageSecurityCardV3 signMessageFlow,
) SignMessageSecurityCardAction {
	return &signMessageSecurityCardAction{
		signMessageSecurityCardV2: signMessageSecurityCardV2,
		signMessageSecurityCardV3: signMessageSecurityCardV3,
	}
}

func (ac *signMessageSecurityCardAction) Run(ctx context.Context) error {
	// The applet SELECT inside each flow is the version probe: run one protocol
	// version and fall back to the other when the card carries no applet for it.
	//
	// The idea is to try the newest protocol version first, so a card on the latest
	// firmware signs in a single tap. For now the order is reversed: the newest flow
	// isn't ready yet and its cards are the minority, so putting it first would add a
	// failed-SELECT round-trip to every sign by the current majority. TODO: try the
	// newest version first once its flow is finished.
	err := ac.signMessageSecurityCardV2.Run(ctx)
	if !isMuunAppletNotFound(err) {
		return err
	}

	err = ac.signMessageSecurityCardV3.Run(ctx)
	if isMuunAppletNotFound(err) {
		return &UnsupportedCardVersionError{
			Message: "card carries no known muun applet",
			Cause:   err,
		}
	}
	return err
}

// isMuunAppletNotFound reports whether err was caused by the tapped card lacking
// the muun applet the flow selected — the signal to try the other protocol. It
// unwraps to the card-level SELECT failure, so it holds whether the flow failed
// while signing or while auto-pairing.
func isMuunAppletNotFound(err error) bool {
	var cardErr *nfc.CardError
	return errors.As(err, &cardErr) && cardErr.Code == nfc.ErrAppletIDNotFound
}
