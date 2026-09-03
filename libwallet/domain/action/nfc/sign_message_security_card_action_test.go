package nfc

import (
	"context"
	"testing"

	"github.com/go-errors/errors"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/muun/libwallet/domain/nfc"
)

// fakeSignMessageFlow stands in for one protocol version's sign flow.
type fakeSignMessageFlow struct {
	err   error
	calls int
}

func (f *fakeSignMessageFlow) Run(_ context.Context) error {
	f.calls++
	return f.err
}

// appletNotFoundError is what the card layer returns when the tapped card carries no
// applet for the version the flow selected.
func appletNotFoundError() error {
	return &nfc.CardError{Message: "applet id not found", Code: nfc.ErrAppletIDNotFound}
}

// autoPairingAppletNotFoundError is the same signal as it reaches the dispatcher when the
// flow failed while auto-pairing instead of while signing: the card error arrives wrapped
// in a MuunAppletNotFoundError, itself wrapped in a PairInternalError.
func autoPairingAppletNotFoundError() error {
	return &PairInternalError{
		Message: "automating V2 pairing failed",
		Cause: &MuunAppletNotFoundError{
			Message: "muun applet not found",
			Cause: errors.Errorf(
				"error during pairing with card: %w",
				appletNotFoundError(),
			),
		},
	}
}

func TestSignMessageSecurityCardSignsWithV2WithoutTryingV3(t *testing.T) {
	v2 := &fakeSignMessageFlow{}
	v3 := &fakeSignMessageFlow{}

	err := NewSignMessageSecurityCardAction(v2, v3).Run(t.Context())

	require.NoError(t, err)
	assert.Equal(t, 1, v2.calls)
	assert.Equal(t, 0, v3.calls, "V3 must not be tried once V2 signed")
}

func TestSignMessageSecurityCardFallsBackToV3WhenTheV2AppletIsMissing(t *testing.T) {
	v2 := &fakeSignMessageFlow{err: appletNotFoundError()}
	v3 := &fakeSignMessageFlow{}

	err := NewSignMessageSecurityCardAction(v2, v3).Run(t.Context())

	require.NoError(t, err)
	assert.Equal(t, 1, v3.calls)
}

func TestSignMessageSecurityCardFallsBackWhenV2FailedWhileAutoPairing(t *testing.T) {
	v2 := &fakeSignMessageFlow{err: autoPairingAppletNotFoundError()}
	v3 := &fakeSignMessageFlow{}

	err := NewSignMessageSecurityCardAction(v2, v3).Run(t.Context())

	require.NoError(t, err)
	assert.Equal(t, 1, v3.calls, "the card error must be found under the pairing wrappers")
}

func TestSignMessageSecurityCardReportsAnUnsupportedVersionWhenNoAppletMatches(t *testing.T) {
	v2 := &fakeSignMessageFlow{err: appletNotFoundError()}
	v3 := &fakeSignMessageFlow{err: autoPairingAppletNotFoundError()}

	err := NewSignMessageSecurityCardAction(v2, v3).Run(t.Context())

	var unsupportedVersionErr *UnsupportedCardVersionError
	require.ErrorAs(t, err, &unsupportedVersionErr)

	var cardErr *nfc.CardError
	require.ErrorAs(t, err, &cardErr, "the card failure must stay reachable on the cause")
	assert.Equal(t, nfc.ErrAppletIDNotFound, cardErr.Code)
}

func TestSignMessageSecurityCardKeepsV2FailuresThatAreNotAMissingApplet(t *testing.T) {
	v2 := &fakeSignMessageFlow{
		err: &NoSlotsAvailableError{Message: "error during pairing with card"},
	}
	v3 := &fakeSignMessageFlow{}

	err := NewSignMessageSecurityCardAction(v2, v3).Run(t.Context())

	var noSlotsAvailableErr *NoSlotsAvailableError
	require.ErrorAs(t, err, &noSlotsAvailableErr)
	assert.Equal(t, 0, v3.calls, "a V2 card that failed for another reason is not a V3 card")
}

func TestSignMessageSecurityCardKeepsV3FailuresThatAreNotAMissingApplet(t *testing.T) {
	v3Err := &InvalidMacError{Message: "error validating card response signature"}
	v2 := &fakeSignMessageFlow{err: appletNotFoundError()}
	v3 := &fakeSignMessageFlow{err: v3Err}

	err := NewSignMessageSecurityCardAction(v2, v3).Run(t.Context())

	var invalidMacErr *InvalidMacError
	require.ErrorAs(t, err, &invalidMacErr)

	var unsupportedVersionErr *UnsupportedCardVersionError
	assert.False(
		t,
		errors.As(err, &unsupportedVersionErr),
		"a V3 card that failed for another reason is not an unknown card",
	)
}

func TestNeedsPairing(t *testing.T) {
	testCases := []struct {
		name          string
		storedVersion any
		flowVersion   string
		expected      bool
	}{
		{
			name:          "nothing paired yet",
			storedVersion: nil,
			flowVersion:   pairedVersionV3,
			expected:      true,
		},
		{
			name:          "this version is already paired",
			storedVersion: pairedVersionV3,
			flowVersion:   pairedVersionV3,
			expected:      false,
		},
		{
			name:          "the other version is paired",
			storedVersion: pairedVersionV2,
			flowVersion:   pairedVersionV3,
			expected:      true,
		},
		{
			name:          "the stored value is not a version string",
			storedVersion: int32(3),
			flowVersion:   pairedVersionV3,
			expected:      true,
		},
	}

	for _, testCase := range testCases {
		t.Run(testCase.name, func(t *testing.T) {
			assert.Equal(
				t,
				testCase.expected,
				needsPairing(testCase.storedVersion, testCase.flowVersion),
			)
		})
	}
}
