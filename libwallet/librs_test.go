package libwallet_test

import (
	"encoding/hex"
	"strings"
	"testing"

	_ "embed"

	"github.com/muun/libwallet/librs"
)

//go:embed librs/test_proof.bin
var proof []byte

func decode(s string) []byte {
	val, _ := hex.DecodeString(s)
	return val
}

func TestVerifierOk(t *testing.T) {
	SERVER_EPHEMERAL_PUBLIC_KEY := "0383dade688e5b3c3c1417bf3087657c5411c22b0a4a727ebab45861be308bee8e"
	RECOVERY_CODE_PUBLIC_KEY := "0239243353aeeaf542bcf339bc82a5c0fbd50e7aca9be0c3651509d857373ebc33"
	SHARED_SECRET_PUBLIC_KEY := "02b1f67530fd1b5c2d2019b7f38f022d6e968237806c437c216f961612788c3ede"

	res := string(librs.Plonky2ServerKeyVerify(proof, decode(SERVER_EPHEMERAL_PUBLIC_KEY), decode(RECOVERY_CODE_PUBLIC_KEY), decode(SHARED_SECRET_PUBLIC_KEY)))
	if res != "ok" {
		t.Fatalf("%s", res)
	}
}

func TestVerifierPanic(t *testing.T) {
	SERVER_EPHEMERAL_PUBLIC_KEY := "0383dade688e5b3c3c1417bf3087657c5411c22b0a4a727ebab45861be308bee8e"
	RECOVERY_CODE_PUBLIC_KEY := "0239243353aeeaf542bcf339bc82a5c0fbd50e7aca9be0c3651509d857373ebc33"
	SHARED_SECRET_PUBLIC_KEY := "02b1f67530fd1b5c2d2019b7f38f022d6e968237806c437c216f961612788c3ede"

	modifiedProof := append([]byte{}, proof...)
	modifiedProof[100] = 7

	res := string(librs.Plonky2ServerKeyVerify(modifiedProof, decode(SERVER_EPHEMERAL_PUBLIC_KEY), decode(RECOVERY_CODE_PUBLIC_KEY), decode(SHARED_SECRET_PUBLIC_KEY)))
	if !strings.HasPrefix(res, "panic:") {
		t.Fatalf("%s", res)
	}
}

func TestVerifierError(t *testing.T) {
	SERVER_EPHEMERAL_PUBLIC_KEY := "0383dade688e5b3c3c1417bf3087657c5411c22b0a4a727ebab45861be308bee8e"
	RECOVERY_CODE_PUBLIC_KEY := "0239243353aeeaf542bcf339bc82a5c0fbd50e7aca9be0c3651509d857373ebc33"
	SHARED_SECRET_PUBLIC_KEY := "02b1f67530fd1b5c2d2019b7f38f022d6e968237806c437c216f961612788c3edf" // modified last char

	res := string(librs.Plonky2ServerKeyVerify(proof, decode(SERVER_EPHEMERAL_PUBLIC_KEY), decode(RECOVERY_CODE_PUBLIC_KEY), decode(SHARED_SECRET_PUBLIC_KEY)))
	if !strings.HasPrefix(res, "error:") {
		t.Fatalf("%s", res)
	}
}
