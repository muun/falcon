package libwallet

import (
	"crypto/sha256"
	"encoding/hex"

	"github.com/btcsuite/btcd/btcec"
	"github.com/pkg/errors"
)

type ChallengePrivateKey struct {
	key *btcec.PrivateKey
}

func NewChallengePrivateKey(input, salt []byte) *ChallengePrivateKey {

	key := Scrypt256(input, salt)

	// 2nd return value is the pub key which we don't need right now
	priv, _ := btcec.PrivKeyFromBytes(btcec.S256(), key)

	return &ChallengePrivateKey{key: priv}
}

func (k *ChallengePrivateKey) SignSha(payload []byte) ([]byte, error) {

	hash := sha256.Sum256(payload)
	sig, err := k.key.Sign(hash[:])

	if err != nil {
		return nil, errors.Wrapf(err, "failed to sign payload")
	}

	return sig.Serialize(), nil
}

func (k *ChallengePrivateKey) PubKeyHex() string {
	rawKey := k.key.PubKey().SerializeCompressed()
	return hex.EncodeToString(rawKey)
}
