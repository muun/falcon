package addresses

import (
	"crypto/sha256"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/go-errors/errors"
)

// CreateAddressV4 returns a P2WSH WalletAddress from a user HD-pubkey and a cosigner HD-pubkey.
func CreateAddressV4(
	userKey, cosignerKey *hdkeychain.ExtendedKey,
	path string,
	network *chaincfg.Params,
) (*WalletAddress, error) {

	witnessScript, err := CreateWitnessScriptV4(userKey, cosignerKey, network)
	if err != nil {
		return nil, errors.Errorf("failed to generate witness script v4: %w", err)
	}
	witnessScript256 := sha256.Sum256(witnessScript)

	address, err := btcutil.NewAddressWitnessScriptHash(witnessScript256[:], network)
	if err != nil {
		return nil, err
	}

	return &WalletAddress{
		address:        address.EncodeAddress(),
		version:        V4,
		derivationPath: path,
	}, nil
}

func CreateWitnessScriptV4(
	userKey, cosignerKey *hdkeychain.ExtendedKey,
	network *chaincfg.Params,
) ([]byte, error) {
	// createMultisigRedeemScript creates a valid script for V2, V3 and V4 schemes
	return createMultisigRedeemScript(userKey, cosignerKey, network)
}
