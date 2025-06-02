package presentation

import (
	"bytes"
	"context"
	"fmt"
	"github.com/google/uuid"
	"github.com/muun/libwallet"
	"github.com/muun/libwallet/domain/diagnostic_mode"
	"github.com/muun/libwallet/electrum"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/types/known/emptypb"
	"log/slog"

	"github.com/muun/libwallet/app_provided_data"
	"github.com/muun/libwallet/presentation/api"
)

type WalletServer struct {
	api.UnsafeWalletServiceServer
	NfcBridge    app_provided_data.NfcBridge
	KeysProvider app_provided_data.KeyProvider
	Network      *libwallet.Network
}

// Check we actually implement the interface
var _ api.WalletServiceServer = (*WalletServer)(nil)

func (WalletServer) DeleteWallet(context.Context, *api.EmptyMessage) (*api.OperationStatus, error) {
	// For now, do nothing. This will probably change in the future.
	return api.OperationStatus_builder{
		Status: "ok",
	}.Build(), nil
}

func (ws WalletServer) NfcTransmit(ctx context.Context, req *api.NfcTransmitRequest) (*api.NfcTransmitResponse, error) {

	fmt.Printf("WalletServer: nfcTransmit")
	slog.Debug("WalletServer: nfcTransmit")

	nfcBridgeResponse, err := ws.NfcBridge.Transmit(req.GetApduCommand())
	if err != nil {
		// TODO error logging
		return nil, err
	}

	return api.NfcTransmitResponse_builder{
		ApduResponse: nfcBridgeResponse.Response,
		StatusCode:   nfcBridgeResponse.StatusCode,
	}.Build(), nil
}

func (ws WalletServer) StartDiagnosticSession(ctx context.Context, empty *emptypb.Empty) (*api.DiagnosticSessionDescriptor, error) {
	sessionId := uuid.NewString()
	err := diagnostic_mode.AddDiagnosticSession(&diagnostic_mode.DiagnosticSessionData{
		Id: sessionId,
	})
	if err != nil {
		return nil, err
	}
	return api.DiagnosticSessionDescriptor_builder{
		SessionId: sessionId,
	}.Build(), nil
}

func (ws WalletServer) PerformDiagnosticScanForUtxos(descriptor *api.DiagnosticSessionDescriptor, g grpc.ServerStreamingServer[api.ScanProgressUpdate]) error {
	sessionId := descriptor.GetSessionId()

	if sessionData, ok := diagnostic_mode.GetDiagnosticSession(sessionId); ok {
		sessionData.DebugLog = bytes.NewBuffer(nil)
		textHandler := slog.NewTextHandler(sessionData.DebugLog, &slog.HandlerOptions{
			Level: slog.LevelInfo,
		})

		var servers []string = electrum.PublicServers
		reports, err := diagnostic_mode.ScanAddresses(ws.KeysProvider, electrum.NewServerProvider(servers), ws.Network, slog.New(textHandler))
		if err != nil {
			return err
		}

		for report := range reports {
			for _, utxo := range report.UtxosFound {
				_ = g.Send(api.ScanProgressUpdate_builder{
					FoundUtxoReport: api.FoundUtxoReport_builder{
						Address: utxo.Address.Address(),
						Amount:  utxo.Amount,
					}.Build(),
				}.Build())
			}
		}

		return g.Send(api.ScanProgressUpdate_builder{
			ScanComplete: api.ScanComplete_builder{
				Status: "DONE",
			}.Build(),
		}.Build())
	} else {
		return fmt.Errorf("invalid sessionId %s", descriptor.GetSessionId())
	}
}

func (ws WalletServer) SubmitDiagnosticLog(ctx context.Context, descriptor *api.DiagnosticSessionDescriptor) (*api.DiagnosticSubmitStatus, error) {
	sessionId := descriptor.GetSessionId()
	if _, ok := diagnostic_mode.GetDiagnosticSession(sessionId); ok {
		// TODO: Upload contents of data.DebugLog before deleting
		diagnostic_mode.DeleteDiagnosticSession(sessionId)
		return api.DiagnosticSubmitStatus_builder{
			StatusCode:    200,
			StatusMessage: "OK",
		}.Build(), nil
	} else {
		return nil, fmt.Errorf("invalid sessionId %s", descriptor.GetSessionId())
	}
}
