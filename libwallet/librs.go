package libwallet

import "github.com/muun/libwallet/librs"

func Plonky2ServerKeyVerify(proof []byte, ephemeral_public_key []byte, recovery_kit_public_key []byte, shared_public_key []byte) []byte {
	return librs.Plonky2ServerKeyVerify(proof, ephemeral_public_key, recovery_kit_public_key, shared_public_key)
}
