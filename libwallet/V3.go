package libwallet

import (
	"github.com/btcsuite/btcutil"

	"github.com/pkg/errors"

	"github.com/btcsuite/btcd/wire"
)

func CreateAddressV3(userKey, muunKey *HDPublicKey) (MuunAddress, error) {

	redeemScript, err := createRedeemScriptV3(userKey, muunKey)
	if err != nil {
		return nil, err
	}

	address, err := btcutil.NewAddressScriptHash(redeemScript, userKey.Network.network)
	if err != nil {
		return nil, err
	}

	return &muunAddress{address: address.EncodeAddress(), version: addressV3, derivationPath: userKey.Path}, nil
}

func createRedeemScriptV3(userKey, muunKey *HDPublicKey) ([]byte, error) {
	witnessScript, err := createWitnessScriptV3(userKey, muunKey)
	if err != nil {
		return nil, errors.Wrapf(err, "failed to generate redeem script v3")
	}

	return createNonNativeSegwitRedeemScript(witnessScript)
}

func createWitnessScriptV3(userKey, muunKey *HDPublicKey) ([]byte, error) {
	// createRedeemScriptV2 creates a valid script for both V2 and V3 schemes
	return createRedeemScriptV2(userKey, muunKey)
}

func signInputV3(input Input, index int, tx *wire.MsgTx, privateKey *HDPrivateKey,
	muunKey *HDPublicKey) (*wire.TxIn, error) {

	if len(input.MuunSignature()) == 0 {
		return nil, errors.Errorf("muun signature must be present")
	}

	redeemScript, err := createRedeemScriptV3(privateKey.PublicKey(), muunKey)
	if err != nil {
		return nil, errors.Wrapf(err, "failed to build reedem script for signing")
	}

	witnessScript, err := createWitnessScriptV3(privateKey.PublicKey(), muunKey)
	if err != nil {
		return nil, err
	}

	sig, err := signNonNativeSegwitInput(input, index, tx, privateKey, redeemScript, witnessScript)
	if err != nil {
		return nil, err
	}

	zeroByteArray := []byte{}

	txInput := tx.TxIn[index]
	txInput.Witness = wire.TxWitness{zeroByteArray, sig, input.MuunSignature(), witnessScript}

	return txInput, nil
}
