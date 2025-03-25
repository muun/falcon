package libwallet

import (
	"context"
	"github.com/muun/libwallet/api"
)

type WalletServer struct {
	api.UnimplementedWalletServiceServer
}

func (WalletServer) DeleteWallet(context.Context, *api.EmptyMessage) (*api.OperationStatus, error) {
	// For now, do nothing. This will probably change in the future.
	return api.OperationStatus_builder{
		Status: "ok",
	}.Build(), nil
}
