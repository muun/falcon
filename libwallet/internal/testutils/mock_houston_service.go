package testutils

import (
	"github.com/muun/libwallet/service"
	"github.com/muun/libwallet/service/model"
)

// Compile-time check.
var _ service.HoustonService = (*MockHoustonService)(nil)

// MockHoustonService is a configurable test double for service.HoustonService.
// Set the fields you need for your test; all unconfigured methods panic.
type MockHoustonService struct {
	VerifiableCosignerKeyResult model.VerifiableCosignerKeyJSON
	VerifiableCosignerKeyErr    error
	FinishWithVerifiableResult  model.VerifiableCosignerKeyJSON
	FinishWithVerifiableErr     error

	// Captured requests for assertions
	CapturedChallengeSetupVerify *model.ChallengeSetupVerifyJSON
}

func (m *MockHoustonService) VerifiableCosignerKey() (model.VerifiableCosignerKeyJSON, error) {
	return m.VerifiableCosignerKeyResult, m.VerifiableCosignerKeyErr
}

func (m *MockHoustonService) ChallengeSetupFinishWithVerifiableCosignerKey(
	req model.ChallengeSetupVerifyJSON,
) (model.VerifiableCosignerKeyJSON, error) {
	m.CapturedChallengeSetupVerify = &req
	return m.FinishWithVerifiableResult, m.FinishWithVerifiableErr
}

// Methods below are not used in the actions under test — they panic if called.

func (m *MockHoustonService) HealthCheck() error {
	panic("MockHoustonService: unexpected call to HealthCheck")
}

func (m *MockHoustonService) ChallengeKeySetupStart(
	model.ChallengeSetupJSON,
) (model.SetupChallengeResponseJSON, error) {
	panic("MockHoustonService: unexpected call to ChallengeKeySetupStart")
}

func (m *MockHoustonService) ChallengeKeySetupFinish(model.ChallengeSetupVerifyJSON) error {
	panic("MockHoustonService: unexpected call to ChallengeKeySetupFinish")
}

func (m *MockHoustonService) CreateFirstSession(
	model.CreateFirstSessionJSON,
) (model.CreateFirstSessionOkJSON, error) {
	panic("MockHoustonService: unexpected call to CreateFirstSession")
}

func (m *MockHoustonService) FetchFeeWindow() (model.FeeWindowJSON, error) {
	panic("MockHoustonService: unexpected call to FetchFeeWindow")
}

func (m *MockHoustonService) SubmitDiagnosticsScanData(model.DiagnosticScanDataJSON) error {
	panic("MockHoustonService: unexpected call to SubmitDiagnosticsScanData")
}

func (m *MockHoustonService) PairRequestChallenge() (model.PairRequestChallengeResponseJSON, error) {
	panic("MockHoustonService: unexpected call to PairRequestChallenge")
}

func (m *MockHoustonService) PairSubmitSignedChallenge(
	model.PairSubmitSignedChallengeJSON,
) (model.PairSubmitSignedChallengeResponseJSON, error) {
	panic("MockHoustonService: unexpected call to PairSubmitSignedChallenge")
}

func (m *MockHoustonService) SignRequestChallenge(
	model.SignRequestChallengeJSON,
) (model.SignRequestChallengeResponseJSON, error) {
	panic("MockHoustonService: unexpected call to SignRequestChallenge")
}

func (m *MockHoustonService) SignSubmitSignedChallenge(
	model.SignSubmitSignedChallengeJSON,
) error {
	panic("MockHoustonService: unexpected call to SignSubmitSignedChallenge")
}

func (m *MockHoustonService) RegisterSecurityCard(
	model.RegisterSecurityCardJSON,
) (model.RegisterSecurityCardOkJSON, error) {
	panic("MockHoustonService: unexpected call to RegisterSecurityCard")
}

func (m *MockHoustonService) ChallengeSecurityCardSign(
	model.ChallengeSecurityCardSignJSON,
) (model.ChallengeSecurityCardSignResponseJSON, error) {
	panic("MockHoustonService: unexpected call to ChallengeSecurityCardSign")
}

func (m *MockHoustonService) SolveSecurityCardChallenge(
	model.SolveSecurityCardChallengeJSON,
) error {
	panic("MockHoustonService: unexpected call to SolveSecurityCardChallenge")
}

func (m *MockHoustonService) FetchSecurityCardsAvailableCountries() (model.SecurityCardsAvailableCountriesJSON, error) {
	panic("MockHoustonService: unexpected call to FetchSecurityCardsCountries")
}

func (m *MockHoustonService) FetchSecurityCardsMarketplace() (model.SecurityCardsMarketplaceJSON, error) {
	panic("MockHoustonService: unexpected call to FetchSecurityCardsMarketplace")
}
