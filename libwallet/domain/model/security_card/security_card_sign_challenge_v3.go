package security_card

import (
	"github.com/go-errors/errors"
)

// V3 wire sizes, duplicated from the nfc package to avoid an import
// cycle (domain/nfc imports this package).
const (
	serverPublicKeyLengthV3 = 65
	macLengthV3             = 32
)

// SecurityCardSignChallengeV3 carries everything a card needs to
// verify and sign a challenge: the server's ephemeral key, the
// monotonic counter, the pairing index, the human-readable reason
// (bound into the MAC), and the server-computed MAC.
type SecurityCardSignChallengeV3 struct {
	ServerPublicKey []byte // C (65 bytes) - server's ephemeral public key
	Counter         uint16 // count_card, strictly increasing for anti-replay
	Index           uint16 // pairing index on the card (V3 is always 0x0000)
	Reason          []byte // human-readable action description, bound into the MAC
	MAC             []byte // HMAC over tag || C || counter || index || reason
}

// NewSecurityCardSignChallengeV3 builds a sign challenge, validating the
// wire-fixed field sizes. The fields come from the server, so violations
// return errors rather than panics.
func NewSecurityCardSignChallengeV3(
	serverPublicKey []byte,
	counter uint16,
	index uint16,
	reason []byte,
	mac []byte,
) (*SecurityCardSignChallengeV3, error) {
	if len(serverPublicKey) != serverPublicKeyLengthV3 {
		return nil, errors.Errorf(
			"server public key must be %d bytes, got %d",
			serverPublicKeyLengthV3,
			len(serverPublicKey),
		)
	}
	if len(mac) != macLengthV3 {
		return nil, errors.Errorf("mac must be %d bytes, got %d", macLengthV3, len(mac))
	}

	return &SecurityCardSignChallengeV3{
		ServerPublicKey: serverPublicKey,
		Counter:         counter,
		Index:           index,
		Reason:          reason,
		MAC:             mac,
	}, nil
}
