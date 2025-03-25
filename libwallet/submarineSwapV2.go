package libwallet

import (
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/muun/libwallet/swaps"
)

type coinSubmarineSwapV2 struct {
	Network             *chaincfg.Params
	OutPoint            wire.OutPoint
	Amount              btcutil.Amount
	KeyPath             string
	PaymentHash256      []byte
	UserPublicKey       []byte
	MuunPublicKey       []byte
	ServerPublicKey     []byte
	BlocksForExpiration int64
	ServerSignature     []byte
}

func (c *coinSubmarineSwapV2) SignInput(index int, tx *wire.MsgTx, userKey *HDPrivateKey,
	_ *HDPublicKey) error {

	userKey, err := userKey.DeriveTo(c.KeyPath)
	if err != nil {
		return fmt.Errorf("failed to derive user key: %w", err)
	}

	if len(c.ServerSignature) == 0 {
		return errors.New("swap server must provide signature")
	}

	witnessScript, err := swaps.CreateWitnessScriptSubmarineSwapV2(
		c.PaymentHash256,
		c.UserPublicKey,
		c.MuunPublicKey,
		c.ServerPublicKey,
		c.BlocksForExpiration)
	if err != nil {
		return err
	}

	sig, err := signNativeSegwitInputV0(
		index, tx, userKey, witnessScript, c.Amount)
	if err != nil {
		return err
	}

	txInput := tx.TxIn[index]
	txInput.Witness = wire.TxWitness{
		sig,
		c.ServerSignature,
		witnessScript,
	}

	return nil
}

func (c *coinSubmarineSwapV2) FullySignInput(index int, tx *wire.MsgTx, userKey, muunKey *HDPrivateKey) error {
	return errors.New("cannot fully sign submarine swap transactions")
}
