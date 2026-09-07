package security_card

import (
	"bytes"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func validServerPublicKey() []byte {
	return append([]byte{0x04}, bytes.Repeat([]byte{0x11}, serverPublicKeyLengthV3-1)...)
}

func validMac() []byte {
	return bytes.Repeat([]byte{0x22}, macLengthV3)
}

func TestNewSecurityCardSignChallengeV3(t *testing.T) {
	reason := []byte("send 1000 sats")

	challenge, err := NewSecurityCardSignChallengeV3(
		validServerPublicKey(),
		7,
		3,
		reason,
		validMac(),
	)

	require.NoError(t, err)
	assert.Equal(t, validServerPublicKey(), challenge.ServerPublicKey)
	assert.Equal(t, uint16(7), challenge.Counter)
	assert.Equal(t, uint16(3), challenge.Index)
	assert.Equal(t, reason, challenge.Reason)
	assert.Equal(t, validMac(), challenge.MAC)
}

func TestNewSecurityCardSignChallengeV3AcceptsAnEmptyReason(t *testing.T) {
	challenge, err := NewSecurityCardSignChallengeV3(
		validServerPublicKey(),
		1,
		0,
		nil,
		validMac(),
	)

	require.NoError(t, err)
	assert.Empty(t, challenge.Reason)
}

func TestNewSecurityCardSignChallengeV3RejectsAServerKeyOfTheWrongSize(t *testing.T) {
	for _, serverPublicKey := range [][]byte{
		nil,
		validServerPublicKey()[:serverPublicKeyLengthV3-1],
		append(validServerPublicKey(), 0x33),
	} {
		challenge, err := NewSecurityCardSignChallengeV3(
			serverPublicKey,
			1,
			0,
			nil,
			validMac(),
		)

		require.Error(t, err)
		assert.Nil(t, challenge)
	}
}

func TestNewSecurityCardSignChallengeV3RejectsAMacOfTheWrongSize(t *testing.T) {
	for _, mac := range [][]byte{nil, validMac()[:macLengthV3-1], append(validMac(), 0x33)} {
		challenge, err := NewSecurityCardSignChallengeV3(
			validServerPublicKey(),
			1,
			0,
			nil,
			mac,
		)

		require.Error(t, err)
		assert.Nil(t, challenge)
	}
}
