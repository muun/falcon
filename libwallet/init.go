package libwallet

import (
	"github.com/muun/libwallet/api"
	"google.golang.org/grpc"
	"log/slog"
	"net"
	"runtime/debug"
)

// BackendActivatedFeatureStatusProvider is an interface implemented by the
// apps to provide us with information about the state of some backend side
// feature flags until we can implement a libwallet-side solution for this.
type BackendActivatedFeatureStatusProvider interface {
	IsBackendFlagEnabled(flag string) bool
}

// Config defines the global libwallet configuration.
type Config struct {
	DataDir               string
	SocketPath            string
	FeatureStatusProvider BackendActivatedFeatureStatusProvider
	AppLogSink            AppLogSink
}

var Cfg *Config

var listener net.Listener
var server *grpc.Server

// Init configures the libwallet
func Init(c *Config) {
	debug.SetTraceback("crash")
	Cfg = c

	if Cfg.AppLogSink != nil {
		logger := slog.New(NewBridgeLogHandler(Cfg.AppLogSink, slog.LevelInfo))
		slog.SetDefault(logger)
	}

	opts := []grpc.ServerOption{
		grpc.ReadBufferSize(0),
		grpc.WriteBufferSize(0),
		grpc.NumStreamWorkers(8),
	}

	server = grpc.NewServer(opts...)
	api.RegisterWalletServiceServer(server, WalletServer{})
}

func StartServer() error {
	if listener != nil {
		slog.Warn("tried to start server when it is already running")
		return nil
	}

	var err error
	listener, err = net.Listen("unix", Cfg.SocketPath)
	if err != nil {
		slog.Error("socket creation failure", "error", err)
		return err
	}

	go func() {
		if err = server.Serve(listener); err != nil {
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
	err := listener.Close()
	if err != nil {
		slog.Error("failed to close socket", "error", err)
		return
	}
}
