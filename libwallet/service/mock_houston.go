package service

import (
	"crypto/ecdh"
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"log/slog"
	"math/big"
	"reflect"
	"time"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/cryptography"
	"github.com/muun/libwallet/domain/nfc"
	"github.com/muun/libwallet/service/model"
	"github.com/muun/libwallet/storage"
)

type RandomPrivateKeyMetadata struct {
	privateKey *ecdh.PrivateKey
	timeStamp  time.Time
}

type MockHoustonService struct {
	keyValueStorage              *storage.KeyValueStorage
	lastRandomPrivateKeyMetadata *RandomPrivateKeyMetadata
	secretCardBytes              [32]byte
	securityCardUsageCount       uint16
	replayCounter                uint16
	pairingSlot                  uint16
}

var _ HoustonService = (*MockHoustonService)(nil)

const challengeTimeoutInSeconds = 90

const (
	ErrChallengeExpired = 2090
	ErrInvalidSignature = 2091
	ErrInvalidMac       = 2092
	ErrUnknown          = 100_000
)

const (
	StatusClientFailure = 400
	StatusServerFailure = 500
)

func NewMockHoustonService(storage *storage.KeyValueStorage) *MockHoustonService {
	return &MockHoustonService{keyValueStorage: storage}
}

func (m *MockHoustonService) HealthCheck() error {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) ChallengeKeySetupStart(
	req model.ChallengeSetupJSON,
) (model.SetupChallengeResponseJSON, error) {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) ChallengeKeySetupFinish(req model.ChallengeSetupVerifyJSON) error {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) ChallengeSetupFinishWithVerifiableCosignerKey(
	req model.ChallengeSetupVerifyJSON,
) (model.VerifiableCosignerKeyJSON, error) {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) VerifiableCosignerKey() (model.VerifiableCosignerKeyJSON, error) {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) CreateFirstSession(
	createSessionJson model.CreateFirstSessionJSON,
) (model.CreateFirstSessionOkJSON, error) {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) FetchFeeWindow() (model.FeeWindowJSON, error) {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) SubmitDiagnosticsScanData(req model.DiagnosticScanDataJSON) error {
	//TODO implement me
	panic("implement me")
}

func (m *MockHoustonService) PairRequestChallenge() (model.PairRequestChallengeResponseJSON, error) {
	err := m.loadCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error loading houston data", err)
		return model.PairRequestChallengeResponseJSON{}, houstonError
	}

	randomPrivateKey, err := ecdh.P256().GenerateKey(rand.Reader)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error generating private key", err)
		return model.PairRequestChallengeResponseJSON{}, houstonError
	}

	m.lastRandomPrivateKeyMetadata = &RandomPrivateKeyMetadata{
		privateKey: randomPrivateKey,
		timeStamp:  time.Now(),
	}

	// Persists the fresh challenge so the upcoming submit loads it.
	err = m.persistCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error persisting houston data", err)
		return model.PairRequestChallengeResponseJSON{}, houstonError
	}

	randomPubKey := randomPrivateKey.PublicKey().Bytes()

	return model.PairRequestChallengeResponseJSON{
		ServerPubKeyInHex: hex.EncodeToString(randomPubKey),
	}, nil
}

// Deprecated: V2 firmware only, will be removed once V3 is fully released.
func (m *MockHoustonService) RegisterSecurityCard(
	req model.RegisterSecurityCardJSON,
) (model.RegisterSecurityCardOkJSON, error) {
	timeSinceLastChallenge := time.Since(m.lastRandomPrivateKeyMetadata.timeStamp).Seconds()
	if timeSinceLastChallenge > challengeTimeoutInSeconds {
		houstonError := &HoustonResponseError{
			DeveloperMessage: "challenge has expired",
			ErrorCode:        ErrChallengeExpired,
			Message:          "challenge has expired",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	cardPublicKeyBytes, err := hex.DecodeString(req.CardPublicKeyInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding card pub key", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	clientPublicKeyBytes, err := hex.DecodeString(req.ClientPublicKeyInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding client pub key", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	sharedPoint, err := cryptography.ECDH(
		m.lastRandomPrivateKeyMetadata.privateKey.Bytes(),
		cardPublicKeyBytes,
	)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("ecdh error", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	// Compute secret_card = sha256(shared_point)
	secretCard := sha256.Sum256(sharedPoint)
	macSecretCard := secretCard[:16]
	encSecretCard := secretCard[16:]

	slog.Debug("macSecretCard", slog.String("secret", hex.EncodeToString(macSecretCard)))
	slog.Debug("encSecretCard", slog.String("secret", hex.EncodeToString(encSecretCard)))

	metadataBytes, err := SecurityCardMetadataToBytes(req.Metadata)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding card metadata", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	receivedMacBytes, err := hex.DecodeString(req.MacInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding mac", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	// Verify MAC: mac = hmac(mac_secret_card, C || P || index || metadata || pub_client)
	err = verifyPairingMAC(
		cardPublicKeyBytes,
		nfc.IntTo2Bytes(req.PairingSlot),
		metadataBytes,
		m.lastRandomPrivateKeyMetadata.privateKey.PublicKey().Bytes(),
		clientPublicKeyBytes,
		macSecretCard,
		receivedMacBytes,
	)
	if err != nil {
		return model.RegisterSecurityCardOkJSON{}, &HoustonResponseError{
			DeveloperMessage: err.Error(),
			ErrorCode:        ErrInvalidMac,
			Message:          "invalid mac: the message data has been tampered with or corrupted.",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	globalSignCardBytes, err := hex.DecodeString(req.GlobalSignCardInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding global sign card", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	globalPublicKeyBytes, err := hex.DecodeString(req.Metadata.GlobalPublicKeyInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding global public card", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	// Verify signed MAC with global public key
	isValidated, err := m.verifySignature(
		globalPublicKeyBytes,
		receivedMacBytes,
		globalSignCardBytes,
	)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error with mac sig verification", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	if !isValidated {
		houstonError := &HoustonResponseError{
			DeveloperMessage: "signature could not be verified. Signed content was altered or signed with invalid/incorrect key",
			ErrorCode:        ErrInvalidSignature,
			Message:          "invalid signature",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	// Store card and secret data
	m.securityCardUsageCount = req.Metadata.UsageCount
	m.secretCardBytes = secretCard
	m.pairingSlot = req.PairingSlot

	err = m.persistCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error persisting houston data", err)
		return model.RegisterSecurityCardOkJSON{}, houstonError
	}

	// TODO: Check if something should change on metadata returned
	enrichedMetadata := req.Metadata

	return model.RegisterSecurityCardOkJSON{
		Metadata:          enrichedMetadata,
		IsKnownProvider:   true,
		IsCardAlreadyUsed: false,
	}, nil
}

// PairSubmitSignedChallenge completes the V3 pairing flow.
func (m *MockHoustonService) PairSubmitSignedChallenge(
	req model.PairSubmitSignedChallengeJSON,
) (model.PairSubmitSignedChallengeResponseJSON, error) {
	err := m.loadCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error loading houston data", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	if m.lastRandomPrivateKeyMetadata == nil {
		return model.PairSubmitSignedChallengeResponseJSON{}, &HoustonResponseError{
			DeveloperMessage: "no pending pair challenge",
			ErrorCode:        ErrChallengeExpired,
			Message:          "no pending pair challenge",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	// Validates the challenge timeout (90s since PairRequestChallenge).
	timeSinceLastChallenge := time.Since(m.lastRandomPrivateKeyMetadata.timeStamp).Seconds()
	if timeSinceLastChallenge > challengeTimeoutInSeconds {
		return model.PairSubmitSignedChallengeResponseJSON{}, &HoustonResponseError{
			DeveloperMessage: "challenge has expired",
			ErrorCode:        ErrChallengeExpired,
			Message:          "challenge has expired",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	metadataBytes, err := hex.DecodeString(req.MetadataInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding metadata", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	// Parses the metadata; ParseMetadataV3 also validates that
	// attestationPub lies on secp256r1.
	metadata, err := nfc.ParseMetadataV3(metadataBytes)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("invalid metadata", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	// TODO (Houston): validate action_pub lies on secp256r1.

	// Validates P lies on secp256r1.
	cardPubKeyBytes, err := hex.DecodeString(req.CardPubKeyInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding card pub key", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}
	if err := cryptography.ValidateSecp256r1PublicKey(cardPubKeyBytes); err != nil {
		houstonError := mapToInternalServerHoustonError("invalid card public key", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	// Computes DH1 = c·attestationPubKey and DH2 = cosignerPriv·P, then
	// derives secret_card = HMAC("pairing-secret", DH1||DH2).
	serverPrivKeyBytes := m.lastRandomPrivateKeyMetadata.privateKey.Bytes()
	dh1, err := cryptography.ECDH(serverPrivKeyBytes, metadata.AttestationPub[:])
	if err != nil {
		houstonError := mapToInternalServerHoustonError("DH1 error", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}
	dh2, err := cryptography.ECDH(cosignerPrivDevBytes, cardPubKeyBytes)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("DH2 error", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	ikm := make([]byte, 0, len(dh1)+len(dh2))
	ikm = append(ikm, dh1...)
	ikm = append(ikm, dh2...)
	secretCard := nfc.ComputeHMACSHA256([]byte("pairing-secret"), ikm)

	// Verifies MAC = HMAC(secret_card, "pairing-response"||C||P||index||metadata).
	// Constant-time compare via hmac.Equal.
	receivedMacBytes, err := hex.DecodeString(req.MacInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding mac", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	serverPubKeyBytes := m.lastRandomPrivateKeyMetadata.privateKey.PublicKey().Bytes()
	err = verifyPairingMACV3(
		secretCard,
		serverPubKeyBytes,
		cardPubKeyBytes,
		req.Index,
		metadataBytes,
		receivedMacBytes,
	)
	if err != nil {
		return model.PairSubmitSignedChallengeResponseJSON{}, &HoustonResponseError{
			DeveloperMessage: err.Error(),
			ErrorCode:        ErrInvalidMac,
			Message:          "invalid mac: the message data has been tampered with or corrupted.",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	// TODO Houston: verify the attestation certificate chain. The metadata
	// carries providerPubKey + providerSig where providerSig is an ECDSA
	// signature over attestationPubKey. Houston should verify that
	// providerPubKey belongs to a trusted provider allowlist and that
	// providerSig validates attestationPubKey under it. On failure return
	// SECURITY_CARD_INVALID_SIGNATURE; the response's
	// IsKnownProvider flag mirrors whether the chain validated. The mock
	// currently hardcodes IsKnownProvider=true because it has no allowlist.

	// TODO Houston: reject if a card with this attestationPubKey is already
	// paired to this wallet. The attestationPubKey is the card's permanent
	// identity, so collisions imply double-pairing. On failure return
	// SECURITY_CARD_ALREADY_PAIRED_TO_THIS_WALLET. The mock cannot
	// enforce this without a persisted card registry, which is out of
	// scope here.

	// replayCounter starts at 0 for this slot — it tracks per-slot sign
	// challenge usage for replay protection.
	m.replayCounter = 0
	copy(m.secretCardBytes[:], secretCard)
	m.pairingSlot = req.Index

	err = m.persistCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error persisting houston data", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	metadataJSON, err := mapSecurityCardV3MetadataJSON(metadata)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error mapping metadata", err)
		return model.PairSubmitSignedChallengeResponseJSON{}, houstonError
	}

	return model.PairSubmitSignedChallengeResponseJSON{
		SecurityCard: model.PairedSecurityCardJSON{
			ID:       1,
			Metadata: *metadataJSON,
			PairedAt: time.Now().UTC().Format(time.RFC3339),
		},
		IsKnownProvider:   true,
		IsCardAlreadyUsed: false,
	}, nil
}

// SignRequestChallenge issues a V3 sign challenge to approve a sensitive
// action (e.g. a new on-chain operation). The card MAC-verifies the
// challenge and emits a response after the user taps to approve.
func (m *MockHoustonService) SignRequestChallenge(
	_ model.SignRequestChallengeJSON,
) (model.SignRequestChallengeResponseJSON, error) {

	// Loads the paired card state (secret_card, counter).
	err := m.loadCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error loading houston data", err)
		return model.SignRequestChallengeResponseJSON{}, houstonError
	}

	// Generates ephemeral (c, C), increments replayCounter.
	randomPrivateKey, err := ecdh.P256().GenerateKey(rand.Reader)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error generating private key", err)
		return model.SignRequestChallengeResponseJSON{}, houstonError
	}

	// NOTE (Houston): issuing a new challenge should expire any open
	// challenge already outstanding for this wallet. The mock holds a
	// single in-flight challenge, so overwriting lastRandomPrivateKeyMetadata
	// implicitly drops the previous one; real Houston must expire them
	// explicitly so stale challenges can't be replayed.
	m.lastRandomPrivateKeyMetadata = &RandomPrivateKeyMetadata{
		privateKey: randomPrivateKey,
		timeStamp:  time.Now(),
	}

	m.replayCounter++
	serverPubKeyBytes := randomPrivateKey.PublicKey().Bytes()

	// Empty reason: the card displays this text on its screen during
	// approval, so only screen-capable cards need it populated. The
	// mock doesn't persist capabilities yet, so it defaults to the
	// non-screen behavior (empty).
	// TODO (Houston): generate the reason text for screen-capable cards.
	var reasonBytes []byte

	// index is the pairing slot persisted at pair time.
	// V3 firmware is single-slot today (so it is 0).
	macBytes := computeSignChallengeMACV3(
		m.secretCardBytes[:],
		serverPubKeyBytes,
		m.replayCounter,
		m.pairingSlot,
		reasonBytes,
	)

	// Persists the advanced counter and new ephemeral so the upcoming
	// submit can verify the card's response.
	err = m.persistCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error persisting houston data", err)
		return model.SignRequestChallengeResponseJSON{}, houstonError
	}

	return model.SignRequestChallengeResponseJSON{
		ServerPubKeyInHex: hex.EncodeToString(serverPubKeyBytes),
		ReasonInHex:       hex.EncodeToString(reasonBytes),
		PerCardPayloads: []model.SignChallengePerCardPayloadJSON{
			{
				// TODO multi-pairing: leave empty until firmware + V3
				// client + Houston track attestationPubKey end-to-end.
				AttestationPubKeyInHex: "",
				Index:                  m.pairingSlot,
				MacInHex:               hex.EncodeToString(macBytes),
				ReplayCounter:          m.replayCounter,
			},
		},
	}, nil
}

// SignSubmitSignedChallenge completes the V3 sign flow. The client
// forwards the card's response (P, MAC) from the sign challenge.
func (m *MockHoustonService) SignSubmitSignedChallenge(
	req model.SignSubmitSignedChallengeJSON,
) error {
	// Loads the in-flight ephemeral c and the current secret_card.
	err := m.loadCardData()
	if err != nil {
		return mapToInternalServerHoustonError("error loading houston data", err)
	}

	if m.lastRandomPrivateKeyMetadata == nil {
		return &HoustonResponseError{
			DeveloperMessage: "no pending sign challenge",
			ErrorCode:        ErrChallengeExpired,
			Message:          "no pending sign challenge",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	// Validates the challenge timeout (90s since SignRequestChallenge).
	timeSinceLastChallenge := time.Since(m.lastRandomPrivateKeyMetadata.timeStamp).Seconds()
	if timeSinceLastChallenge > challengeTimeoutInSeconds {
		return &HoustonResponseError{
			DeveloperMessage: "challenge has expired",
			ErrorCode:        ErrChallengeExpired,
			Message:          "challenge has expired",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	// Decodes and validates P on secp256r1.
	cardPubKeyBytes, err := hex.DecodeString(req.CardPubKeyInHex)
	if err != nil {
		return mapToInternalServerHoustonError("error decoding card pub key", err)
	}
	if err := cryptography.ValidateSecp256r1PublicKey(cardPubKeyBytes); err != nil {
		return mapToInternalServerHoustonError("invalid card public key", err)
	}

	// Verifies MAC = HMAC(secret_card, "challenge-response"||C||P).
	receivedMacBytes, err := hex.DecodeString(req.MacInHex)
	if err != nil {
		return mapToInternalServerHoustonError("error decoding mac", err)
	}

	serverPubKeyBytes := m.lastRandomPrivateKeyMetadata.privateKey.PublicKey().Bytes()
	err = verifySignChallengeResponseMACV3(
		m.secretCardBytes[:],
		serverPubKeyBytes,
		cardPubKeyBytes,
		receivedMacBytes,
	)
	if err != nil {
		return &HoustonResponseError{
			DeveloperMessage: err.Error(),
			ErrorCode:        ErrInvalidMac,
			Message:          "invalid mac: the message data has been tampered with or corrupted.",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	// TODO (Houston): verify action_sig — the card's signature over the
	// approved action — to prove the tap authorized this specific action.

	// Ratchet secret_card := HMAC(secret_card, "challenge-ratchet"||DH)
	// where DH = ECDH(c, P). The card computes the same ratchet on its
	// side from (p, C), so the next sign challenge uses a fresh secret
	// on both ends.
	dh, err := cryptography.ECDH(
		m.lastRandomPrivateKeyMetadata.privateKey.Bytes(),
		cardPubKeyBytes,
	)
	if err != nil {
		return mapToInternalServerHoustonError("ECDH error", err)
	}

	ratchetIKM := append([]byte("challenge-ratchet"), dh...)
	newSecretCard := nfc.ComputeHMACSHA256(m.secretCardBytes[:], ratchetIKM)
	copy(m.secretCardBytes[:], newSecretCard)

	// Persists the new secret_card.
	err = m.persistCardData()
	if err != nil {
		return mapToInternalServerHoustonError("error persisting houston data", err)
	}

	return nil
}

// Deprecated: V2 firmware only, will be removed once V3 is fully released.
func (m *MockHoustonService) ChallengeSecurityCardSign(
	req model.ChallengeSecurityCardSignJSON,
) (model.ChallengeSecurityCardSignResponseJSON, error) {
	err := m.loadCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error loading houston data", err)
		return model.ChallengeSecurityCardSignResponseJSON{}, houstonError
	}

	randomPrivateKey, err := ecdh.P256().GenerateKey(rand.Reader)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error generating private key", err)
		return model.ChallengeSecurityCardSignResponseJSON{}, houstonError
	}

	m.lastRandomPrivateKeyMetadata = &RandomPrivateKeyMetadata{
		privateKey: randomPrivateKey,
		timeStamp:  time.Now(),
	}

	m.securityCardUsageCount += 1

	randomPublicKey := randomPrivateKey.PublicKey().Bytes()

	reasonBytes, err := hex.DecodeString(req.ReasonInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding reason", err)
		return model.ChallengeSecurityCardSignResponseJSON{}, houstonError
	}

	err = m.persistCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error persisting houston data", err)
		return model.ChallengeSecurityCardSignResponseJSON{}, houstonError
	}

	challengeMac := nfc.MakeChallengeSignMac(
		m.secretCardBytes[:16],
		randomPublicKey,
		reasonBytes,
		m.securityCardUsageCount,
		m.pairingSlot,
	)

	return model.ChallengeSecurityCardSignResponseJSON{
		ServerPublicKeyInHex: hex.EncodeToString(randomPublicKey),
		CardUsageCount:       m.securityCardUsageCount,
		MacInHex:             hex.EncodeToString(challengeMac),
		PairingSlot:          m.pairingSlot,
	}, nil
}

// Deprecated: V2 firmware only, will be removed once V3 is fully released.
func (m *MockHoustonService) SolveSecurityCardChallenge(
	req model.SolveSecurityCardChallengeJSON,
) error {
	timeSinceLastChallenge := time.Since(m.lastRandomPrivateKeyMetadata.timeStamp).Seconds()
	if timeSinceLastChallenge > challengeTimeoutInSeconds {
		return &HoustonResponseError{
			DeveloperMessage: "challenge has expired",
			ErrorCode:        ErrChallengeExpired,
			Message:          "challenge has expired",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	serverPublicKeyBytes := m.lastRandomPrivateKeyMetadata.privateKey.PublicKey().Bytes()
	cardPublicKeyBytes, err := hex.DecodeString(req.PublicKeyInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding card pub key", err)
		return houstonError
	}

	receivedMac, err := hex.DecodeString(req.MacInHex)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error decoding received mac", err)
		return houstonError
	}

	err = m.verifySolveChallengeMac(receivedMac, serverPublicKeyBytes, cardPublicKeyBytes)
	if err != nil {
		return &HoustonResponseError{
			DeveloperMessage: err.Error(),
			ErrorCode:        ErrInvalidMac,
			Message:          "invalid mac: the message data has been tampered with or corrupted.",
			RequestID:        0,
			Status:           StatusClientFailure,
		}
	}

	// Calculate and store new secret card
	sharedPoint, err := cryptography.ECDH(
		m.lastRandomPrivateKeyMetadata.privateKey.Bytes(),
		cardPublicKeyBytes,
	)
	if err != nil {
		houstonError := mapToInternalServerHoustonError("ecdh error", err)
		return houstonError
	}

	// Update secret for forward secrecy: new_secret = HMAC(currentSecretCardBytes, sharedPoint)
	newSecretCardBytes := nfc.ComputeHMACSHA256(m.secretCardBytes[:], sharedPoint)
	copy(m.secretCardBytes[:], newSecretCardBytes)

	err = m.persistCardData()
	if err != nil {
		houstonError := mapToInternalServerHoustonError("error persisting houston data", err)
		return houstonError
	}

	return nil
}

func (m *MockHoustonService) FetchSecurityCardsAvailableCountries() (model.SecurityCardsAvailableCountriesJSON, error) {
	return model.SecurityCardsAvailableCountriesJSON{
		Countries: []model.CountryInfoJSON{
			{Code: "AU", Name: "Australia", Flag: "🇦🇺"},
			{Code: "AT", Name: "Austria", Flag: "🇦🇹"},
			{Code: "BE", Name: "Belgium", Flag: "🇧🇪"},
			{Code: "BR", Name: "Brazil", Flag: "🇧🇷"},
			{Code: "CA", Name: "Canada", Flag: "🇨🇦"},
			{Code: "CO", Name: "Colombia", Flag: "🇨🇴"},
			{Code: "CZ", Name: "Czech Republic", Flag: "🇨🇿"},
			{Code: "FR", Name: "France", Flag: "🇫🇷"},
			{Code: "DE", Name: "Germany", Flag: "🇩🇪"},
			{Code: "HU", Name: "Hungary", Flag: "🇭🇺"},
			{Code: "IT", Name: "Italy", Flag: "🇮🇹"},
			{Code: "MX", Name: "Mexico", Flag: "🇲🇽"},
			{Code: "NL", Name: "Netherlands", Flag: "🇳🇱"},
			{Code: "ES", Name: "Spain", Flag: "🇪🇸"},
			{Code: "CH", Name: "Switzerland", Flag: "🇨🇭"},
			{Code: "GB", Name: "United Kingdom", Flag: "🇬🇧"},
			{Code: "US", Name: "United States", Flag: "🇺🇸"},
		},
	}, nil
}

func (m *MockHoustonService) FetchSecurityCardsMarketplace() (model.SecurityCardsMarketplaceJSON, error) {
	brazil := model.CountryInfoJSON{Code: "BR", Name: "Brazil", Flag: "🇧🇷"}
	canada := model.CountryInfoJSON{Code: "CA", Name: "Canada", Flag: "🇨🇦"}
	france := model.CountryInfoJSON{Code: "FR", Name: "France", Flag: "🇫🇷"}
	germany := model.CountryInfoJSON{Code: "DE", Name: "Germany", Flag: "🇩🇪"}
	italy := model.CountryInfoJSON{Code: "IT", Name: "Italy", Flag: "🇮🇹"}
	mexico := model.CountryInfoJSON{Code: "MX", Name: "Mexico", Flag: "🇲🇽"}
	netherlands := model.CountryInfoJSON{Code: "NL", Name: "Netherlands", Flag: "🇳🇱"}
	spain := model.CountryInfoJSON{Code: "ES", Name: "Spain", Flag: "🇪🇸"}
	unitedKingdom := model.CountryInfoJSON{Code: "GB", Name: "United Kingdom", Flag: "🇬🇧"}
	unitedStates := model.CountryInfoJSON{Code: "US", Name: "United States", Flag: "🇺🇸"}

	return model.SecurityCardsMarketplaceJSON{
		Providers: []model.SecurityCardsProviderJSON{
			{
				ID:          "constellations",
				UUID:        "4b2f8a1d-7e3c-490b-a1f5-62d83e9c7b14",
				Name:        "Constellations",
				CardPrice:   model.PriceInfoJSON{CurrencyCode: "EUR", Amount: "20000"},
				Description: "Constellations are officially recognized patterns of stars in the night sky that form recognizable shapes, figures, or outlines.",
				SiteURL:     "https://en.wikipedia.org/wiki/Constellation",
				LightTheme: model.SecurityCardProviderThemeJSON{
					PrimaryColor: "#B19B6A",
					SurfaceColor: "#0DB19B6A",
				},
				DarkTheme: model.SecurityCardProviderThemeJSON{
					PrimaryColor: "#B19B6A",
					SurfaceColor: "#0DB19B6A",
				},
				MinShippingTimeDays: 5,
				MaxShippingTimeDays: 10,
				SecurityCards: []model.SecurityCardJSON{
					{
						ID:            "constellations_scorpius",
						UUID:          "a1b2c3d4-1111-4000-8000-000000000001",
						ImageURL:      "https://placehold.co/2594x1632/FFF8E7/AFC9FF/png?text=SCORPIUS",
						SpecID:        "constellations_spec",
						Sku:           "CONST-SCORP-01",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "constellations_gemini",
						UUID:          "a1b2c3d4-1111-4000-8000-000000000002",
						ImageURL:      "https://placehold.co/2594x1632/FFF8E7/AFC9FF/png?text=GEMINI",
						SpecID:        "constellations_spec",
						Sku:           "CONST-GEMI-01",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "constellations_sagitarius",
						UUID:          "a1b2c3d4-1111-4000-8000-000000000003",
						ImageURL:      "https://placehold.co/2594x1632/FFF8E7/AFC9FF/png?text=SAGITARIUS",
						SpecID:        "constellations_spec",
						Sku:           "CONST-SAGI-01",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "constellations_virgo",
						UUID:          "a1b2c3d4-1111-4000-8000-000000000004",
						ImageURL:      "https://placehold.co/2594x1632/FFF8E7/AFC9FF/png?text=VIRGO",
						SpecID:        "constellations_spec",
						Sku:           "CONST-VIRG-01",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      false,
					},
				},
				EstimatedShippingPrices: []model.ShippingPriceInfoJSON{
					{
						Price:     model.PriceInfoJSON{CurrencyCode: "EUR", Amount: "1500"},
						Countries: []model.CountryInfoJSON{unitedStates, germany, spain},
					},
					{
						Price:     model.PriceInfoJSON{CurrencyCode: "EUR", Amount: "3000"},
						Countries: []model.CountryInfoJSON{unitedKingdom, brazil},
					},
				},
			},
			{
				ID:          "numbers",
				UUID:        "9e2c6b4a-1f8d-473e-b9a5-c3d2e1f4a7b8",
				Name:        "Numbers",
				CardPrice:   model.PriceInfoJSON{CurrencyCode: "ARS", Amount: "50000"},
				Description: "Numbers are mathematical objects used for counting, measuring, and labeling, with primary types including natural numbers (1, 2, 3...), whole numbers, and integers",
				SiteURL:     "https://en.wikipedia.org/wiki/Number",
				LightTheme: model.SecurityCardProviderThemeJSON{
					PrimaryColor: "#D9DBDD",
					SurfaceColor: "#0DD9DBDD",
				},
				DarkTheme: model.SecurityCardProviderThemeJSON{
					PrimaryColor: "#D9DBDD",
					SurfaceColor: "#0DD9DBDD",
				},
				MinShippingTimeDays: 7,
				MaxShippingTimeDays: 14,
				SecurityCards: []model.SecurityCardJSON{
					{
						ID:            "numbers_1",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000001",
						ImageURL:      "https://placehold.co/2594x1632/8B1A1A/4A0D0D/png?text=1",
						SpecID:        "numbers_spec",
						Sku:           "NUM-01",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_2",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000002",
						ImageURL:      "https://placehold.co/2594x1632/C9A227/7A5C10/png?text=2",
						SpecID:        "numbers_spec",
						Sku:           "NUM-02",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_3",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000003",
						ImageURL:      "https://placehold.co/2594x1632/1A4E8C/0C2E5E/png?text=3",
						SpecID:        "numbers_spec",
						Sku:           "NUM-03",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_4",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000004",
						ImageURL:      "https://placehold.co/2594x1632/C45A1A/6E2E08/png?text=4",
						SpecID:        "numbers_spec",
						Sku:           "NUM-04",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_5",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000005",
						ImageURL:      "https://placehold.co/2594x1632/1A6E3A/0B3D1F/png?text=5",
						SpecID:        "numbers_spec",
						Sku:           "NUM-05",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_6",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000006",
						ImageURL:      "https://placehold.co/2594x1632/5E2A7A/2E1240/png?text=6",
						SpecID:        "numbers_spec",
						Sku:           "NUM-06",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_7",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000007",
						ImageURL:      "https://placehold.co/2594x1632/0E5E6E/04323E/png?text=7",
						SpecID:        "numbers_spec",
						Sku:           "NUM-07",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      false,
					},
					{
						ID:            "numbers_8",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000008",
						ImageURL:      "https://placehold.co/2594x1632/19A0B0/0A5E6A/png?text=8",
						SpecID:        "numbers_spec",
						Sku:           "NUM-08",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "numbers_9",
						UUID:          "b2c3d4e5-2222-4000-8000-000000000009",
						ImageURL:      "https://placehold.co/2594x1632/B02A8E/5C1149/png?text=9",
						Tag:           "OUT_OF_STOCK",
						SpecID:        "numbers_spec",
						Sku:           "NUM-09",
						Material:      "PLASTIC",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_5_PLUS",
						WeightGrams:   5,
						HasStock:      false,
					},
				},
				EstimatedShippingPrices: []model.ShippingPriceInfoJSON{
					{
						Price:     model.PriceInfoJSON{CurrencyCode: "USD", Amount: "1000"},
						Countries: []model.CountryInfoJSON{unitedStates, france},
					},
					{
						Price:     model.PriceInfoJSON{CurrencyCode: "USD", Amount: "2000"},
						Countries: []model.CountryInfoJSON{canada, mexico},
					},
				},
			},
			{
				ID:          "planets",
				UUID:        "b3f5c1d8-4a72-4e9b-8c61-d3a9e2f4b7c0",
				Name:        "Planets",
				CardPrice:   model.PriceInfoJSON{CurrencyCode: "USD", Amount: "10000"},
				Description: "There are eight officially recognized planets in our solar system, orbiting the Sun in this order: Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, and Neptune.",
				SiteURL:     "https://en.wikipedia.org/wiki/Planet",
				LightTheme: model.SecurityCardProviderThemeJSON{
					PrimaryColor: "#158E5A",
					SurfaceColor: "#0D158E5A",
				},
				DarkTheme: model.SecurityCardProviderThemeJSON{
					PrimaryColor: "#158E5A",
					SurfaceColor: "#0D158E5A",
				},
				MinShippingTimeDays: 10,
				MaxShippingTimeDays: 21,
				SecurityCards: []model.SecurityCardJSON{
					{
						ID:            "planets_earth",
						UUID:          "c3d4e5f6-3333-4000-8000-000000000001",
						ImageURL:      "https://placehold.co/2594x1632/081448/3B5D38/png?text=EARTH",
						Tag:           "METAL",
						SpecID:        "planets_spec",
						Sku:           "PLAN-EARTH-01",
						Material:      "METAL",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_6_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
					{
						ID:            "planets_mars",
						UUID:          "c3d4e5f6-3333-4000-8000-000000000002",
						ImageURL:      "https://placehold.co/2594x1632/081448/C1440E/png?text=MARS",
						Tag:           "METAL",
						SpecID:        "planets_spec",
						Sku:           "PLAN-MARS-01",
						Material:      "METAL",
						ThicknessMm:   0.8,
						WidthMm:       86.6,
						HeightMm:      54,
						SecureElement: "EAL_6_PLUS",
						WeightGrams:   5,
						HasStock:      true,
					},
				},
				EstimatedShippingPrices: []model.ShippingPriceInfoJSON{
					{
						Price:     model.PriceInfoJSON{CurrencyCode: "USD", Amount: "1000"},
						Countries: []model.CountryInfoJSON{germany, italy},
					},
					{
						Price:     model.PriceInfoJSON{CurrencyCode: "USD", Amount: "2000"},
						Countries: []model.CountryInfoJSON{netherlands},
					},
				},
			},
		},
		Specs: []model.SecurityCardSpecJSON{
			{
				SpecID: "constellations_spec",
				Items: map[string][]model.SecurityCardSpecItemJSON{
					"primary": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Material", Value: "Plastic"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "From", Value: "Sky"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Arrives in", Value: "Already there"},
					},
					"specifications": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Material", Value: "Plastic"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Thickness", Value: "0.8mm"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Weight", Value: "5g"},
					},
					"security": {
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Secure Element",
							Value:          "EAL 5+",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Firmware",
							Value:          "Designed by Muun",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Packaging", Value: "Tamper resistant"},
					},
					"delivery": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Shipped by", Value: "Sky"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "From", Value: "Sky"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Arrives in", Value: "Already there"},
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Shipping data",
							Value:          "Under GDPR",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
					},
				},
			},
			{
				SpecID: "numbers_spec",
				Items: map[string][]model.SecurityCardSpecItemJSON{
					"primary": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Material", Value: "Plastic"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "From", Value: "Math"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Arrives in", Value: "Already here"},
					},
					"specifications": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Material", Value: "Plastic"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Thickness", Value: "0.8mm"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Weight", Value: "5g"},
					},
					"security": {
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Secure Element",
							Value:          "EAL 5+",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Firmware",
							Value:          "Designed by Muun",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Packaging", Value: "Tamper resistant"},
					},
					"delivery": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Shipped by", Value: "Math"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "From", Value: "Math"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Arrives in", Value: "Already here"},
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Shipping data",
							Value:          "Under GDPR",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
					},
				},
			},
			{
				SpecID: "planets_spec",
				Items: map[string][]model.SecurityCardSpecItemJSON{
					"primary": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Material", Value: "Metal"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "From", Value: "Space"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Arrives in", Value: "Now"},
					},
					"specifications": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Material", Value: "Metal"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Thickness", Value: "1.2mm"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Weight", Value: "10g"},
					},
					"security": {
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Secure Element",
							Value:          "EAL 6+",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Firmware",
							Value:          "Designed by Muun",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Packaging", Value: "Tamper resistant"},
					},
					"delivery": {
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Shipped by", Value: "BigBang"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "From", Value: "Space"},
						{IconURL: "https://placehold.co/16x16/FF0000/000000/png?text=ic", Label: "Arrives in", Value: "Now"},
						{
							IconURL:        "https://placehold.co/16x16/FF0000/000000/png?text=ic",
							Label:          "Shipping data",
							Value:          "Under GDPR",
							AdditionalData: "Lorem Ipsum Lorem Ipsum Lorem Ipsum",
						},
					},
				},
			},
		},
	}, nil
}

func (m *MockHoustonService) verifySolveChallengeMac(
	receivedMac,
	serverPublicKeyBytes,
	cardPublicKeyBytes []byte,
) error {
	// Construct MAC input with: C || P
	macInput := make([]byte, 0, 130)
	macInput = append(macInput, serverPublicKeyBytes...) // C (server ephemeral pub key 65 bytes)
	macInput = append(macInput, cardPublicKeyBytes...)   // P (card ephemeral pub key 65 bytes)

	// Compute expected MAC using mac_secret_card (secret_card[:16])
	expectedMAC := nfc.ComputeHMACSHA256(m.secretCardBytes[:16], macInput)

	// Compare MACs
	if !reflect.DeepEqual(receivedMac, expectedMAC) {
		return fmt.Errorf("MAC mismatch - expected: %x, got: %x", expectedMAC, receivedMac)
	}
	return nil
}

func verifyPairingMAC(cardPublicKey,
	pairingSlot,
	metadata,
	serverRandomPubKey,
	clientPubKey,
	macSecretCard,
	receivedMac []byte,
) error {
	// Construct MAC input with: C || P || index || metadata || pub_client
	macInput := make([]byte, 0, 272)
	macInput = append(macInput, serverRandomPubKey...) // C (server random key, 65 bytes)
	macInput = append(macInput, cardPublicKey...)      // P (card public key, 65 bytes)
	macInput = append(macInput, pairingSlot...)        // index (2 bytes)
	macInput = append(macInput, metadata...)           // metadata (75 bytes)
	macInput = append(macInput, clientPubKey...)       // pub_client (65 bytes)

	// Compute expected MAC using mac_secret_card (secret_card[16:])
	expectedMAC := nfc.ComputeHMACSHA256(macSecretCard, macInput)

	// Compare MACs
	if !reflect.DeepEqual(receivedMac, expectedMAC) {
		return fmt.Errorf("mac mismatch - expected: %x, got: %x", expectedMAC, receivedMac)
	}

	return nil
}

// verifyPairingMACV3 verifies the V3 pair-response MAC:
//
//	MAC = HMAC(secret_card, "pairing-response" || C || P || index || metadata)
//
// metadataBytes is the raw wire input the card signed. Re-serializing
// the struct fields would risk drift and break the MAC.
//
// Uses hmac.Equal for constant-time comparison.
func verifyPairingMACV3(
	secretCard,
	serverPubKey,
	cardPubKey []byte,
	index uint16,
	metadataBytes,
	receivedMac []byte,
) error {
	tag := []byte("pairing-response")
	macInput := make(
		[]byte,
		0,
		len(tag)+len(serverPubKey)+len(cardPubKey)+2+len(metadataBytes),
	)
	macInput = append(macInput, tag...)
	macInput = append(macInput, serverPubKey...)
	macInput = append(macInput, cardPubKey...)
	macInput = append(macInput, nfc.IntTo2Bytes(index)...)
	macInput = append(macInput, metadataBytes...)

	expectedMAC := nfc.ComputeHMACSHA256(secretCard, macInput)
	if !hmac.Equal(receivedMac, expectedMAC) {
		return errors.Errorf("v3 pairing MAC mismatch")
	}
	return nil
}

// maxRawReasonSizeV3 is the reason-length boundary for how the MAC
// commits to the reason. It equals what fits raw in a single short APDU
// alongside the fixed request fields
// (255 − C(65) − counter(2) − index(2) − has_more(1) − mac(32) = 153).
// At or below it the MAC commits to the raw reason; above it the MAC
// commits to SHA256(reason). Houston mirrors it so its MAC matches the card's.
const maxRawReasonSizeV3 = 153

// computeSignChallengeMACV3 computes the V3 sign-request MAC:
//
//	MAC = HMAC(secret_card, "challenge-request" || C || counter || index || reasonForMAC)
//
// C is the server's ephemeral pub key, counter is the per-slot monotonic
// count_card, index is the pairing slot, and reason is the human-readable
// action text that the card would display in screen-capable variants.

// reasonForMAC is the raw reason when it fits a short APDU, else
// SHA256(reason), matching how the card computes the MAC.
func computeSignChallengeMACV3(
	secretCard,
	serverPubKey []byte,
	counter,
	index uint16,
	reason []byte,
) []byte {
	// The card commits to the raw reason at or below the short-APDU
	// length, and to SHA256(reason) above it.
	reasonForMAC := reason
	if len(reason) > maxRawReasonSizeV3 {
		h := sha256.Sum256(reason)
		reasonForMAC = h[:]
	}

	tag := []byte("challenge-request")
	macInput := make(
		[]byte,
		0,
		len(tag)+len(serverPubKey)+2+2+len(reasonForMAC),
	)
	macInput = append(macInput, tag...)
	macInput = append(macInput, serverPubKey...)
	macInput = append(macInput, nfc.IntTo2Bytes(counter)...)
	macInput = append(macInput, nfc.IntTo2Bytes(index)...)
	macInput = append(macInput, reasonForMAC...)
	return nfc.ComputeHMACSHA256(secretCard, macInput)
}

// verifySignChallengeResponseMACV3 verifies the V3 sign-response MAC:
//
//	MAC = HMAC(secret_card, "challenge-response" || C || P)
//
// C is the server's ephemeral pub key from the sign-request and P is
// the card's ephemeral pub key from its response.
// No counter binding on the response MAC — that's a deliberate spec choice;
// the request MAC already commits to the counter.
func verifySignChallengeResponseMACV3(
	secretCard,
	serverPubKey,
	cardPubKey,
	receivedMac []byte,
) error {
	tag := []byte("challenge-response")
	macInput := make(
		[]byte,
		0,
		len(tag)+len(serverPubKey)+len(cardPubKey),
	)
	macInput = append(macInput, tag...)
	macInput = append(macInput, serverPubKey...)
	macInput = append(macInput, cardPubKey...)

	expectedMAC := nfc.ComputeHMACSHA256(secretCard, macInput)
	if !hmac.Equal(receivedMac, expectedMAC) {
		return errors.Errorf("v3 sign challenge response MAC mismatch")
	}
	return nil
}

func SecurityCardMetadataToBytes(m model.SecurityCardMetadataJSON) ([]byte, error) {
	handleError := func(err error) error {
		return fmt.Errorf("error decoding metadata: %w", err)
	}
	const MetadataSize = 75
	buf := make([]byte, 0, MetadataSize) // 75 bytes

	// Global public key (65 bytes)
	globalPublicKeyBytes, err := hex.DecodeString(m.GlobalPublicKeyInHex)
	if err != nil {
		return nil, handleError(err)
	}
	buf = append(buf, globalPublicKeyBytes...)

	// Card vendor (2 bytes)
	cardVendorBytes, err := hex.DecodeString(m.CardVendorInHex)
	if err != nil {
		return nil, handleError(err)
	}
	buf = append(buf, cardVendorBytes...)

	// Card model (2 bytes)
	cardModelBytes, err := hex.DecodeString(m.CardModelInHex)
	if err != nil {
		return nil, handleError(err)
	}
	buf = append(buf, cardModelBytes...)

	// Firmware version (2 bytes)
	buf = append(buf, nfc.IntTo2Bytes(m.FirmwareVersion)...)

	// Usage count (2 bytes, big-endian)
	buf = append(buf, nfc.IntTo2Bytes(m.UsageCount)...)

	// Language code (2 bytes)
	languageCodeBytes, err := hex.DecodeString(m.LanguageCodeInHex)
	if err != nil {
		return nil, handleError(err)
	}
	buf = append(buf, languageCodeBytes...)

	return buf, nil
}

// verifySignature verifies a signature from a muuncard.
func (m *MockHoustonService) verifySignature(
	publicKeyBytes, messageBytes, signedMessageBytes []byte,
) (bool, error) {

	// verify expected public key
	if len(publicKeyBytes) != 65 || publicKeyBytes[0] != 0x04 {
		return false, nil
	}

	ecdhPub, err := ecdh.P256().NewPublicKey(publicKeyBytes)
	if err != nil {
		return false, nil
	}

	pub, err := ecdhToECDSAPublicKey(ecdhPub)
	if err != nil {
		return false, nil
	}

	h := sha256.Sum256(messageBytes)

	// Verify the signature
	return ecdsa.VerifyASN1(pub, h[:], signedMessageBytes), nil
}

// ecdhToECDSAPublicKey converts an *ecdh.PublicKey into an *ecdsa.PublicKey.
// Hacky workaround to avoid deprecated elliptic.Unmarshal() and ignoring lint check.
// Only works for P-256 NIST curve, which is what we are using.
// Once we upgrade to Go 1.25 we could use proper support to transform ecdh.PublicKey to
// ecdsa.PublicKey. for now this is what we got.
func ecdhToECDSAPublicKey(key *ecdh.PublicKey) (*ecdsa.PublicKey, error) {
	if key.Curve() != ecdh.P256() {
		return nil, errors.New("public key curve not supported. We work with P256")
	}

	rawKey := key.Bytes()
	return &ecdsa.PublicKey{
		Curve: elliptic.P256(),
		// For
		X: big.NewInt(0).SetBytes(rawKey[1:33]),
		Y: big.NewInt(0).SetBytes(rawKey[33:]),
	}, nil
}

func mapToInternalServerHoustonError(message string, errCause error) *HoustonResponseError {
	return &HoustonResponseError{
		DeveloperMessage: errCause.Error(),
		ErrorCode:        ErrUnknown,
		Message:          message,
		RequestID:        0,
		Status:           StatusServerFailure,
	}
}

func (m *MockHoustonService) persistCardData() error {
	var items = make(map[string]any)

	if m.lastRandomPrivateKeyMetadata != nil {
		privKeyInHex := hex.EncodeToString(m.lastRandomPrivateKeyMetadata.privateKey.Bytes())
		items[storage.KeyLastRandomPrivKeyInHex] = privKeyInHex

		items[storage.KeyTimeSinceLastChallengeUnixMillis] = m.lastRandomPrivateKeyMetadata.timeStamp.Unix()
	}

	// Note: LibwalletStorage IntType maps to int32, so we cast to int32
	items[storage.KeySecurityCardUsageCount] = int32(m.securityCardUsageCount)
	items[storage.KeySecurityCardReplayCounter] = int32(m.replayCounter)
	items[storage.KeySecurityCardPairingSlot] = int32(m.pairingSlot)

	secretCardInHex := hex.EncodeToString(m.secretCardBytes[:])
	items[storage.KeySecretCardBytesInHex] = secretCardInHex

	slog.Debug("mockHouston - stored data", "data", items)

	err := m.keyValueStorage.SaveBatch(items)
	if err != nil {
		return fmt.Errorf("error saving mock houston data: %w", err)
	}

	return nil
}

func (m *MockHoustonService) loadCardData() error {
	var keys = []string{
		storage.KeyLastRandomPrivKeyInHex,
		storage.KeySecurityCardUsageCount,
		storage.KeySecurityCardReplayCounter,
		storage.KeySecurityCardPairingSlot,
		storage.KeySecretCardBytesInHex,
		storage.KeyTimeSinceLastChallengeUnixMillis,
	}

	keyValues, err := m.keyValueStorage.GetBatch(keys)
	if err != nil {
		return fmt.Errorf("error loading mock houston data: %w", err)
	}

	slog.Debug("mock houston - loaded data", "data", keyValues)

	if keyValues[storage.KeyLastRandomPrivKeyInHex] != nil {
		privKeyBytes, err := hex.DecodeString(keyValues[storage.KeyLastRandomPrivKeyInHex].(string))
		if err != nil {
			return fmt.Errorf("error decoding server private key: %w", err)
		}

		privKey, err := ecdh.P256().NewPrivateKey(privKeyBytes)
		if err != nil {
			return fmt.Errorf("error initializing server private key: %w", err)
		}

		timeStamp := time.Unix(keyValues[storage.KeyTimeSinceLastChallengeUnixMillis].(int64), 0)

		m.lastRandomPrivateKeyMetadata = &RandomPrivateKeyMetadata{
			privateKey: privKey,
			timeStamp:  timeStamp,
		}
	}

	// Note: LibwalletStorage IntType maps to int32, so we cast to int32
	if keyValues[storage.KeySecurityCardPairingSlot] != nil {
		m.pairingSlot = uint16(keyValues[storage.KeySecurityCardPairingSlot].(int32))
	}

	if keyValues[storage.KeySecurityCardUsageCount] != nil {
		m.securityCardUsageCount = uint16(keyValues[storage.KeySecurityCardUsageCount].(int32))
	}

	if keyValues[storage.KeySecurityCardReplayCounter] != nil {
		m.replayCounter = uint16(keyValues[storage.KeySecurityCardReplayCounter].(int32))
	}

	if keyValues[storage.KeySecretCardBytesInHex] != nil {
		secretCard, err := hex.DecodeString(keyValues[storage.KeySecretCardBytesInHex].(string))
		if err != nil {
			return fmt.Errorf("error decoding secret card in hex: %w", err)
		}
		copy(m.secretCardBytes[:], secretCard)
	}

	return nil
}
