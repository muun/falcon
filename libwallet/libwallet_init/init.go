package libwallet_init

import (
	"context"
	"fmt"
	"log/slog"
	"net"
	"path"
	"runtime/debug"
	"time"

	"github.com/go-errors/errors"
	grpc_middleware "github.com/grpc-ecosystem/go-grpc-middleware"
	"google.golang.org/grpc"

	"github.com/muun/libwallet"
	"github.com/muun/libwallet/app_provided_data"
	"github.com/muun/libwallet/data/keys"
	"github.com/muun/libwallet/data/marketplace"
	"github.com/muun/libwallet/data/securekv"
	"github.com/muun/libwallet/data/security_cards"
	"github.com/muun/libwallet/domain/action/challenge_keys"
	debugAction "github.com/muun/libwallet/domain/action/debug"
	"github.com/muun/libwallet/domain/action/diagnostic_mode_reports"
	"github.com/muun/libwallet/domain/action/emergency_kit"
	marketplace_action "github.com/muun/libwallet/domain/action/marketplace"
	nfcActions "github.com/muun/libwallet/domain/action/nfc"
	"github.com/muun/libwallet/domain/action/recovery"
	"github.com/muun/libwallet/domain/action/reset"
	"github.com/muun/libwallet/domain/nfc"
	"github.com/muun/libwallet/electrum"
	"github.com/muun/libwallet/storage"
	"github.com/muun/libwallet/walletdb"

	"github.com/muun/libwallet/log"
	"github.com/muun/libwallet/platform/observability/otel"
	"github.com/muun/libwallet/presentation"
	"github.com/muun/libwallet/presentation/api"
	"github.com/muun/libwallet/service"
)

var server *grpc.Server
var pool *walletdb.Pool
var cfg *app_provided_data.Config
var keyValueStorage *storage.KeyValueStorage
var network *libwallet.Network
var houstonService service.HoustonService
var mockHoustonService service.HoustonService
var keyProvider keys.KeyProvider
var otelSetup *otel.Setup
var startChallengeSetupAction *challenge_keys.StartChallengeSetupAction
var finishChallengeSetupAction *challenge_keys.FinishChallengeSetupAction
var computeAndStoreEncryptedCosignerKeyAction *recovery.ComputeAndStoreEncryptedCosignerKeyAction
var populateEncryptedCosignerKeyAction *recovery.PopulateEncryptedCosignerKeyAction
var scanForFundsAction *recovery.ScanForFundsAction
var submitDiagnosticAction *diagnostic_mode_reports.SubmitDiagnosticAction
var buildSweepTxAction *recovery.BuildSweepTxAction
var signSweepTxAction *recovery.SignSweepTxAction
var pairSecurityCardActionV2 *nfcActions.PairSecurityCardActionV2
var signMessageSecurityCardActionV2 *nfcActions.SignMessageSecurityCardActionV2
var pairSecurityCardActionV3 nfcActions.PairSecurityCardActionV3
var signMessageSecurityCardActionV3 nfcActions.SignMessageSecurityCardActionV3
var signMessageSecurityCardAction nfcActions.SignMessageSecurityCardAction
var pairRequestChallengeAction *nfcActions.PairRequestChallengeAction
var pairLoadPersistedChallengeAction *nfcActions.PairLoadPersistedChallengeAction
var pairSignChallengeAction *nfcActions.PairSignChallengeAction
var pairSubmitSolvedChallengeAction *nfcActions.PairSubmitSolvedChallengeAction
var pairSignAndSubmitChallengeAction *nfcActions.PairSignAndSubmitChallengeAction
var securityCardsProtocolRepository *security_cards.ProtocolRepository
var securityCardsMarketplaceAction *marketplace_action.GetSecurityCardsMarketplaceAction
var fetchAvailableCountriesAction marketplace_action.FetchAvailableCountriesAction
var fetchProviderListingsAction marketplace_action.FetchProviderListingsByCountryAction
var fetchCardOfferAction marketplace_action.FetchCardOfferAction
var generateEmergencyKitPDFAction *emergency_kit.GenerateEmergencyKitPDFAction
var secureKeyValueStorage securekv.SecureKeyValueStorage
var zipDataDirAction *debugAction.ZipDataDirAction
var resetDataAction reset.ResetDataAction

// Init configures libwallet
func Init(c *app_provided_data.Config) {
	cfg = c

	debug.SetTraceback("crash")
	libwallet.Init(c)

	if c.AppLogSink != nil {
		level := c.AppLogSink.GetDefaultLogLevel()
		logger := slog.New(log.NewBridgeLogHandler(c.AppLogSink, slog.Level(level)))
		slog.SetDefault(logger)
	}

	if cfg.HttpClientSessionProvider != nil {
		houstonService = service.NewHoustonService(cfg.HttpClientSessionProvider)
	}

	dbPath := path.Join(cfg.DataDir, "wallet.db")
	var storageSchema map[string]storage.Classification
	var err error
	pool, err = walletdb.NewPool(dbPath, func(db *walletdb.DB) error {
		var migErr error
		storageSchema, migErr = storage.RunKeyValueMigrations(db, storage.BuildKVMigrationPlan())
		return migErr
	})
	if err != nil {
		slog.Error("failed to initialize database", "error", err)
		panic(fmt.Sprintf("failed to initialize database: %v", err))
	}
	libwallet.Pool = pool
	keyValueStorage = storage.NewKeyValueStorage(
		pool.NewKeyValueRepository(),
		storageSchema,
	)

	mockHoustonService = service.NewMockHoustonService(keyValueStorage)

	switch c.Network {
	case libwallet.Mainnet().Name():
		network = libwallet.Mainnet()
	case libwallet.Testnet().Name():
		network = libwallet.Testnet()
	case libwallet.Regtest().Name():
		network = libwallet.Regtest()
	default:
		panic("unknown network: " + c.Network)
	}
	keyProvider = keys.NewKeyProvider(c.KeyProvider, *network)

	otelConfig := otel.NewConfigFromEnv()
	otelConfig.HoneycombAPIKey = "" // Ensure no trace will be exported to Honeycomb
	otelSetup, err = otel.NewSetup(context.Background(), otelConfig)
	if err != nil {
		slog.Error("Failed to setup OpenTelemetry", "error", err)
		otelSetup = nil
	}

	// TODO do this only for debug builds and while making use of FakeNfcSession or equivalent
	// Enables security cards testing in emulators and ui tests.
	//mockMuunCardV2, _ := nfc.NewMockMuunCardV2()
	//cfg.NfcBridge = nfc.NewMockJavaCard(mockMuunCardV2)

	muuncardV2 := nfc.NewCardV2(cfg.NfcBridge)
	muuncardV3 := nfc.NewCardV3(cfg.NfcBridge)
	// Actions
	computeAndStoreEncryptedCosignerKeyAction =
		recovery.NewComputeAndStoreEncryptedCosignerKeyAction(
			keyValueStorage,
			keyProvider,
		)
	populateEncryptedCosignerKeyAction = recovery.NewPopulateEncryptedCosignerKeyAction(
		houstonService,
		keyValueStorage,
		keyProvider,
	)
	startChallengeSetupAction = challenge_keys.NewStartChallengeSetupAction(houstonService)
	finishChallengeSetupAction = challenge_keys.NewFinishChallengeSetupAction(
		houstonService,
		keyValueStorage,
		computeAndStoreEncryptedCosignerKeyAction,
	)
	electrumProvider := electrum.NewServerProvider(electrum.PublicServers)
	scanForFundsAction = recovery.NewScanForFundsAction(keyProvider, electrumProvider, network)
	submitDiagnosticAction = diagnostic_mode_reports.NewSubmitDiagnosticAction(houstonService)
	buildSweepTxAction = recovery.NewBuildSweepTxAction(keyProvider, network)
	signSweepTxAction = recovery.NewSignSweepTxAction(keyProvider, network)
	pairSecurityCardActionV2 = nfcActions.NewPairSecurityCardActionV2(
		keyValueStorage,
		muuncardV2,
		mockHoustonService,
	)
	signMessageSecurityCardActionV2 = nfcActions.NewSignMessageSecurityCardActionV2(
		muuncardV2,
		mockHoustonService,
		keyValueStorage,
		pairSecurityCardActionV2,
	)
	pairSecurityCardActionV3 = nfcActions.NewPairSecurityCardActionV3(
		muuncardV3,
		mockHoustonService,
	)
	signMessageSecurityCardActionV3 = nfcActions.NewSignMessageSecurityCardActionV3(
		muuncardV3,
		mockHoustonService,
		keyValueStorage,
		pairSecurityCardActionV3,
	)
	signMessageSecurityCardAction = nfcActions.NewSignMessageSecurityCardAction(
		signMessageSecurityCardActionV2,
		signMessageSecurityCardActionV3,
	)
	securityCardsProtocolRepository = security_cards.NewProtocolRepository(keyValueStorage)
	pairRequestChallengeAction = nfcActions.NewPairRequestChallengeAction(
		securityCardsProtocolRepository,
		mockHoustonService,
	)
	pairLoadPersistedChallengeAction = nfcActions.NewPairLoadPersistedChallengeAction(
		securityCardsProtocolRepository,
	)
	pairSignChallengeAction = nfcActions.NewPairSignChallengeAction(muuncardV2)
	pairSubmitSolvedChallengeAction = nfcActions.NewPairSubmitSolvedChallengeAction(
		securityCardsProtocolRepository,
		mockHoustonService,
	)
	pairSignAndSubmitChallengeAction = nfcActions.NewPairSignAndSubmitChallengeAction(
		pairLoadPersistedChallengeAction,
		pairRequestChallengeAction,
		pairSignChallengeAction,
		pairSubmitSolvedChallengeAction,
	)
	securityCardsMarketplaceAction = marketplace_action.
		NewGetSecurityCardsMarketplaceAction(mockHoustonService)
	marketplaceRepository := marketplace.NewMarketplaceRepository(
		mockHoustonService,
	)
	fetchAvailableCountriesAction = marketplace_action.
		NewFetchAvailableCountriesAction(marketplaceRepository)
	fetchProviderListingsAction = marketplace_action.
		NewFetchProviderListingsByCountryAction(marketplaceRepository)
	fetchCardOfferAction = marketplace_action.
		NewFetchCardOfferAction(marketplaceRepository)
	generateEmergencyKitPDFAction = emergency_kit.NewGenerateEmergencyKitPDFAction()

	if cfg.SecureKeyValueStorage != nil {
		secureKeyValueStorage = securekv.NewSecureKeyValueStorage(cfg.SecureKeyValueStorage)
	}
	zipDataDirAction = debugAction.NewZipDataDirAction(cfg.DataDir)
	resetDataAction = reset.NewResetDataAction(dbPath, pool, storage.BuildKVMigrationPlan())
}

func StartServer() error {
	if server != nil {
		return errors.New("server is already running")
	}

	opts := []grpc.ServerOption{
		grpc.ReadBufferSize(0),
		grpc.WriteBufferSize(0),
		grpc.NumStreamWorkers(8),
		grpc.UnaryInterceptor(
			grpc_middleware.ChainUnaryServer(
				// Order is important.
				presentation.TracingUnaryInterceptor(otelSetup), // First interceptor
				presentation.RecoverUnknownErrorUnaryInterceptor(),
				presentation.RecoverPanicUnaryInterceptor(), // Last interceptor
			),
		),
		grpc.StreamInterceptor(
			grpc_middleware.ChainStreamServer(
				// Order is important.
				presentation.TracingStreamInterceptor(otelSetup), // First interceptor
				presentation.RecoverUnknownErrorStreamInterceptor(),
				presentation.RecoverPanicStreamInterceptor(), // Last interceptor
			),
		),
	}

	server = grpc.NewServer(opts...)
	api.RegisterWalletServiceServer(server, presentation.NewWalletServer(
		cfg.NfcBridge,
		keyProvider,
		network,
		houstonService,
		keyValueStorage,
		resetDataAction,
		startChallengeSetupAction,
		finishChallengeSetupAction,
		populateEncryptedCosignerKeyAction,
		scanForFundsAction,
		submitDiagnosticAction,
		buildSweepTxAction,
		signSweepTxAction,
		pairSecurityCardActionV2,
		signMessageSecurityCardAction,
		pairRequestChallengeAction,
		pairSignAndSubmitChallengeAction,
		securityCardsMarketplaceAction,
		fetchAvailableCountriesAction,
		fetchProviderListingsAction,
		fetchCardOfferAction,
		generateEmergencyKitPDFAction,
		zipDataDirAction,
		secureKeyValueStorage,
	))

	lc := net.ListenConfig{}
	listener, err := lc.Listen(context.Background(), "unix", cfg.SocketPath)
	if err != nil {
		slog.Error("socket creation failure", "error", err)
		return err
	}

	go func() {
		if err := server.Serve(listener); err != nil {
			slog.Error("error when starting server goroutine", "error", err)
		}

		if otelSetup != nil {
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()

			if err := otelSetup.Shutdown(ctx); err != nil {
				slog.Error("error when shutting down OpenTelemetry", "error", err)
			}
		}
	}()

	return nil
}

func StopServer() {
	if server == nil {
		slog.Warn("tried to stop server when none is running")
		return
	}
	server.Stop()
	if pool != nil {
		pool.Close()
		pool = nil
		libwallet.Pool = nil
	}
}
