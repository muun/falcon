package addresses

import (
	"crypto/sha256"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/go-errors/errors"
)

// CreateAddressV8 returns a native-segwit (P2WSH) address for `to_client`
// (user AND cosigner AND lightningServer)                     // collaborative spend
// OR (user AND cosigner AND older(blocksForExpiration))       // non-collaborative spend
func CreateAddressV8(
	userKey, cosignerKey, lightningServerKey *hdkeychain.ExtendedKey,
	blocksForExpiration int64,
	path string,
	network *chaincfg.Params,
) (*WalletAddress, error) {
	userEcPubKey, err := userKey.ECPubKey()
	if err != nil {
		return nil, errors.Errorf("get user public key: %w", err)
	}

	cosignerEcPubKey, err := cosignerKey.ECPubKey()
	if err != nil {
		return nil, errors.Errorf("get cosigner public key: %w", err)
	}

	lightningServerEcPubKey, err := lightningServerKey.ECPubKey()
	if err != nil {
		return nil, errors.Errorf("get lightning server public key: %w", err)
	}

	// Reuse the V7 witness script: the spending policy is identical for both schemes.
	witnessScript, err := CreateWitnessScriptV7(
		userEcPubKey,
		cosignerEcPubKey,
		lightningServerEcPubKey,
		blocksForExpiration,
	)
	if err != nil {
		return nil, err
	}

	witnessScript256 := sha256.Sum256(witnessScript)

	address, err := btcutil.NewAddressWitnessScriptHash(witnessScript256[:], network)
	if err != nil {
		return nil, err
	}

	return &WalletAddress{
		address:        address.EncodeAddress(),
		version:        V8,
		derivationPath: path,
	}, nil
}
