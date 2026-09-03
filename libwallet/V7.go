package libwallet

import (
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/go-errors/errors"

	"github.com/muun/libwallet/addresses"
)

func CreateAddressV7(
	userKey, cosignerKey, lightningServerKey *HDPublicKey,
	blocksForExpiration int64,
) (MuunAddress, error) {
	return addresses.CreateAddressV7(
		&userKey.key,
		&cosignerKey.key,
		&lightningServerKey.key,
		blocksForExpiration,
		userKey.Path,
		userKey.Network.network,
	)
}

// coinV7 signs a V7 (M3) P2SH-P2WSH input.
type coinV7 struct {
	Network                  *chaincfg.Params
	OutPoint                 wire.OutPoint
	KeyPath                  string
	Amount                   btcutil.Amount
	BlocksForExpiration      int64
	LightningServerKey       *HDPublicKey
	CosignerSignature        []byte
	LightningServerSignature []byte
}

// SignInput adds the user signature and assembles the collaborative (3-of-3) witness.
// The cosigner and lightning server signatures must already be present.
func (c *coinV7) SignInput(
	index int,
	tx *wire.MsgTx,
	userKey *HDPrivateKey,
	cosignerKey *HDPublicKey,
) error {
	derivedUserKey, err := userKey.DeriveTo(c.KeyPath)
	if err != nil {
		return err
	}

	derivedCosignerKey, err := cosignerKey.DeriveTo(c.KeyPath)
	if err != nil {
		return err
	}

	derivedLightningServerKey, err := c.LightningServerKey.DeriveTo(c.KeyPath)
	if err != nil {
		return err
	}

	if len(c.CosignerSignature) == 0 {
		return errors.New("cosigner signature must be present")
	}
	if len(c.LightningServerSignature) == 0 {
		return errors.New("lightning server signature must be present")
	}

	userPubKey, err := derivedUserKey.PublicKey().ECPubKey()
	if err != nil {
		return err
	}
	cosignerPubKey, err := derivedCosignerKey.ECPubKey()
	if err != nil {
		return err
	}
	lightningServerPubKey, err := derivedLightningServerKey.ECPubKey()
	if err != nil {
		return err
	}

	witnessScript, err := addresses.CreateWitnessScriptV7(
		userPubKey,
		cosignerPubKey,
		lightningServerPubKey,
		c.BlocksForExpiration,
	)
	if err != nil {
		return err
	}

	userSignature, err := c.signature(
		index,
		tx,
		derivedUserKey,
		witnessScript,
	)
	if err != nil {
		return err
	}

	// Stack top -> bottom: witnessScript, userSig, cosignerSig, lightningServerSig.
	tx.TxIn[index].Witness = wire.TxWitness{
		c.LightningServerSignature,
		c.CosignerSignature,
		userSignature,
		witnessScript,
	}

	return nil
}

// FullySignInput signs the non-collaborative (2-of-2 + timelock) path with the user and cosigner
// private keys, for recovery contexts. The caller must build a version-2 tx whose input nSequence
// encodes the relative timelock, since nSequence is committed to by the signature.
func (c *coinV7) FullySignInput(
	index int,
	tx *wire.MsgTx,
	userKey, cosignerKey *HDPrivateKey,
) error {
	derivedUserKey, err := userKey.DeriveTo(c.KeyPath)
	if err != nil {
		return err
	}

	derivedCosignerKey, err := cosignerKey.DeriveTo(c.KeyPath)
	if err != nil {
		return err
	}

	derivedLightningServerKey, err := c.LightningServerKey.DeriveTo(c.KeyPath)
	if err != nil {
		return err
	}

	userPubKey, err := derivedUserKey.PublicKey().ECPubKey()
	if err != nil {
		return err
	}
	cosignerPubKey, err := derivedCosignerKey.PublicKey().ECPubKey()
	if err != nil {
		return err
	}
	lightningServerPubKey, err := derivedLightningServerKey.ECPubKey()
	if err != nil {
		return err
	}

	witnessScript, err := addresses.CreateWitnessScriptV7(
		userPubKey,
		cosignerPubKey,
		lightningServerPubKey,
		c.BlocksForExpiration,
	)
	if err != nil {
		return err
	}

	userSignature, err := c.signature(
		index,
		tx,
		derivedUserKey,
		witnessScript,
	)
	if err != nil {
		return err
	}

	cosignerSignature, err := c.signature(
		index,
		tx,
		derivedCosignerKey,
		witnessScript,
	)
	if err != nil {
		return err
	}

	// Stack top -> bottom: witnessScript, userSig, cosignerSig, <empty>.
	tx.TxIn[index].Witness = wire.TxWitness{
		[]byte{},
		cosignerSignature,
		userSignature,
		witnessScript,
	}

	return nil
}

func (c *coinV7) signature(
	index int,
	tx *wire.MsgTx,
	signingKey *HDPrivateKey,
	witnessScript []byte,
) ([]byte, error) {

	redeemScript, err := addresses.CreateRedeemScriptV7(witnessScript)
	if err != nil {
		return nil, err
	}

	return signNonNativeSegwitInputV0(
		index, tx, signingKey, redeemScript, witnessScript, c.Amount)
}
