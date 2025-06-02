package libwallet_init

import (
	"errors"
	"github.com/muun/libwallet/storage"
	"log/slog"
	"net"
	"path"
	"runtime/debug"

	"github.com/muun/libwallet"
	"github.com/muun/libwallet/app_provided_data"
	"github.com/muun/libwallet/log"
	"github.com/muun/libwallet/presentation"
	"github.com/muun/libwallet/presentation/api"
	"github.com/muun/libwallet/service"
	"google.golang.org/grpc"
)

var server *grpc.Server
var cfg *app_provided_data.Config
var keyValueStorage *storage.KeyValueStorage
var network *libwallet.Network

//lint:ignore U1000 will be used in the future
var houstonService *service.HoustonService

// Init configures libwallet
func Init(c *app_provided_data.Config) {
	cfg = c

	debug.SetTraceback("crash")
	libwallet.Init(c)

	if c.AppLogSink != nil {
		logger := slog.New(log.NewBridgeLogHandler(c.AppLogSink, slog.LevelInfo))
		slog.SetDefault(logger)
	}

	if cfg.HttpClientSessionProvider != nil {
		houstonService = service.NewHoustonService(c.HttpClientSessionProvider)
	}

	var storageSchema = storage.BuildStorageSchema()
	keyValueStorage = storage.NewKeyValueStorage(path.Join(cfg.DataDir, "wallet.db"), storageSchema)

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
}

func StartServer() error {
	if server != nil {
		return errors.New("server is already running")
	}

	opts := []grpc.ServerOption{
		grpc.ReadBufferSize(0),
		grpc.WriteBufferSize(0),
		grpc.NumStreamWorkers(8),
	}

	server = grpc.NewServer(opts...)
	api.RegisterWalletServiceServer(server, presentation.WalletServer{
		NfcBridge:    cfg.NfcBridge,
		KeysProvider: cfg.KeyProvider,
		Network:      network,
	})
	api.RegisterStorageServiceServer(server, presentation.NewStorageServer(keyValueStorage))

	listener, err := net.Listen("unix", cfg.SocketPath)
	if err != nil {
		slog.Error("socket creation failure", "error", err)
		return err
	}

	go func() {
		if err := server.Serve(listener); err != nil {
			slog.Error("error when starting server goroutine", "error", err)
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
}
