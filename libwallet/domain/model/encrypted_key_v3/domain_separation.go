package encrypted_key_v3

const (
	userFirstHalfToRecoveryCode     = "muun.com/cosigning-key/1/1/recovery-code"
	userSecondHalfToRecoveryCode    = "muun.com/cosigning-key/1/2/recovery-code"
	cosignerFirstHalfToRecoveryCode = "muun.com/cosigning-key/2/1/recovery-code"
	// CosignerSecondHalfToRecoveryCode is the HPKE info string Houston uses when encrypting
	// the second half of the cosigner key to the recovery code.
	CosignerSecondHalfToRecoveryCode = "muun.com/cosigning-key/2/2/recovery-code"
	CosignerFirstHalfToClient        = "muun.com/cosigning-key/2/1/client"
)

type keyBearer uint8

const (
	user keyBearer = iota + 1
	cosigner
)
