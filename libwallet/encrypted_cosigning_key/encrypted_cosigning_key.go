package encrypted_cosigning_key

import (
	"bytes"
	"encoding/base64"
	"errors"
	"fmt"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/muun/libwallet"
	"github.com/muun/libwallet/recoverycode"
)

const (
	VERSION                         uint8 = 3
	PRIVATE_KEY_LEN_BYTES                 = btcec.PrivKeyBytesLen
	COMPRESSED_PUBLIC_KEY_LEN_BYTES       = btcec.PubKeyBytesLenCompressed
	CHAIN_CODE_LEN_BYTES                  = 32
)

type encryptedKey struct {
	version                     uint8
	paddedPrivateKey            *btcec.PrivateKey
	ephemeralPublicKey          *btcec.PublicKey
	paddedChainCode             []byte
	ephemeralChainCodePublicKey *btcec.PublicKey
}

func (key *encryptedKey) serialize() string {
	result := make(
		[]byte,
		0,
		1+PRIVATE_KEY_LEN_BYTES+COMPRESSED_PUBLIC_KEY_LEN_BYTES+CHAIN_CODE_LEN_BYTES+COMPRESSED_PUBLIC_KEY_LEN_BYTES,
	)

	buf := bytes.NewBuffer(result)

	buf.WriteByte(VERSION)
	buf.Write(key.paddedPrivateKey.Serialize())
	buf.Write(key.ephemeralPublicKey.SerializeCompressed())
	buf.Write(key.paddedChainCode)
	buf.Write(key.ephemeralChainCodePublicKey.SerializeCompressed())

	return base64.StdEncoding.EncodeToString(buf.Bytes())
}

func deserializeEncryptedKey(encryptedCosigningKey string) (*encryptedKey, error) {

	encryptedCosigningKeyBytes, err := base64.StdEncoding.DecodeString(encryptedCosigningKey)
	if err != nil {
		return nil, fmt.Errorf("decrypting key: failed to decode from base64 %w", err)
	}
	reader := bytes.NewReader(encryptedCosigningKeyBytes)

	version, err := reader.ReadByte()

	if err != nil {
		return nil, fmt.Errorf("decrypting key: failed to read version %w", err)
	}

	paddedPrivateKeyBytes := make([]byte, PRIVATE_KEY_LEN_BYTES)
	ephemeralPublicKeyBytes := make([]byte, COMPRESSED_PUBLIC_KEY_LEN_BYTES)
	paddedChainCode := make([]byte, CHAIN_CODE_LEN_BYTES)
	ephemeralChainCodePublicKeyBytes := make([]byte, COMPRESSED_PUBLIC_KEY_LEN_BYTES)

	n, err := reader.Read(paddedPrivateKeyBytes)
	if err != nil || n != PRIVATE_KEY_LEN_BYTES {
		return nil, fmt.Errorf("decrypting key: failed to read paddedPrivateKey %w", err)
	}
	paddedPrivateKey, _ := btcec.PrivKeyFromBytes(paddedPrivateKeyBytes)

	n, err = reader.Read(ephemeralPublicKeyBytes)
	if err != nil || n != COMPRESSED_PUBLIC_KEY_LEN_BYTES {
		return nil, fmt.Errorf("decrypting key: failed to read ephemeralPublicKey %w", err)
	}
	ephemeralPublicKey, err := btcec.ParsePubKey(ephemeralPublicKeyBytes)
	if err != nil {
		return nil, fmt.Errorf("decrypting key: failed to parse ephemeralPublicKey %w", err)
	}

	n, err = reader.Read(paddedChainCode)
	if err != nil || n != CHAIN_CODE_LEN_BYTES {
		return nil, fmt.Errorf("decrypting key: failed to read chainCode %w", err)
	}

	n, err = reader.Read(ephemeralChainCodePublicKeyBytes)
	if err != nil || n != COMPRESSED_PUBLIC_KEY_LEN_BYTES {
		return nil, fmt.Errorf("decrypting key: failed to read ephemeralChainCodePublicKey %w", err)
	}
	ephemeralChainCodePublicKey, err := btcec.ParsePubKey(ephemeralChainCodePublicKeyBytes)
	if err != nil {
		return nil, fmt.Errorf("decrypting key: failed to parse ephemeralChainCodePublicKey %w", err)
	}

	if reader.Len() > 0 {
		return nil, errors.New("decrypting key: key is longer than expected")
	}

	return &encryptedKey{
		version,
		paddedPrivateKey,
		ephemeralPublicKey,
		paddedChainCode,
		ephemeralChainCodePublicKey,
	}, nil
}

func DecryptCosigningKey(recoveryCode string, encryptedCosigningKey string, network *libwallet.Network) (*libwallet.HDPrivateKey, error) {

	key, err := deserializeEncryptedKey(encryptedCosigningKey)
	if err != nil {
		return nil, err
	}

	recoveryCodePrivateKey, err := recoverycode.ConvertToKey(recoveryCode, "")
	if err != nil {
		return nil, err
	}

	cosigningKey, err := paddingDecrypt(key.paddedPrivateKey.Serialize(), recoveryCodePrivateKey, key.ephemeralPublicKey)
	if err != nil {
		return nil, err
	}

	chainCode, err := paddingDecrypt(key.paddedChainCode, recoveryCodePrivateKey, key.ephemeralChainCodePublicKey)
	if err != nil {
		return nil, err
	}

	return libwallet.NewHDPrivateKeyFromBytes(cosigningKey, chainCode, network)
}
