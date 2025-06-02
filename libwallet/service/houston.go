package service

import (
	"github.com/muun/libwallet/app_provided_data"
)

type HoustonService struct {
	client client
}

func NewHoustonService(configurator app_provided_data.HttpClientSessionProvider) *HoustonService {
	return &HoustonService{client: client{configurator: configurator}}
}

func (service *HoustonService) ChallengeKeySetupStart(req ChallengeSetupJson) error {
	r := request[any]{
		Method: MethodPost,
		Path:   "/user/challenge/setup/start",
		Body:   req,
	}
	_, err := r.do(&service.client)
	return err
}

func (service *HoustonService) ChallengeKeySetupFinish(req ChallengeSetupVerifyJson) error {
	r := request[any]{
		Method: MethodPost,
		Path:   "/user/challenge/setup/finish",
		Body:   req,
	}

	_, err := r.do(&service.client)
	return err
}

func (service *HoustonService) VerifiableServerCosginingKey() (VerifiableServerCosigningKeyJson, error) {
	r := request[VerifiableServerCosigningKeyJson]{
		Method: MethodGet,
		Path:   "/user/verifiable-server-cosigning-key",
	}

	return r.do(&service.client)
}

func (h *HoustonService) CreateFirstSession(
	createSessionJson CreateFirstSessionJson,
) (CreateFirstSessionOkJson, error) {

	r := request[CreateFirstSessionOkJson]{
		Method: MethodPost,
		Path:   "sessions-v2/first",
		Body:   createSessionJson,
	}
	return r.do(&h.client)
}

func (h *HoustonService) FetchFeeWindow() (FeeWindowJson, error) {
	r := request[FeeWindowJson]{
		Method: MethodGet,
		Path:   "fees/latest",
	}
	return r.do(&h.client)
}
