package presentation

import (
	"context"
	"fmt"
	"log/slog"

	"github.com/muun/libwallet/presentation/api"
	"github.com/muun/libwallet/storage"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/emptypb"
)

type StorageServer struct {
	api.UnsafeStorageServiceServer
	keyValueStorage *storage.KeyValueStorage
}

// Check we actually implement the interface
var _ api.StorageServiceServer = (*StorageServer)(nil)

func NewStorageServer(keyValueStorage *storage.KeyValueStorage) *StorageServer {
	return &StorageServer{keyValueStorage: keyValueStorage}
}

func (s *StorageServer) Save(_ context.Context, req *api.SaveRequest) (*emptypb.Empty, error) {
	if req.GetKey() == "" {
		return nil, status.Error(codes.InvalidArgument, "key is required")
	}
	if req.GetValue() == nil {
		return nil, status.Error(codes.InvalidArgument, "Value is not defined")
	}

	value, err := toAny(req.GetValue())
	if err != nil {
		slog.Error("failed to convert proto Value to internal type", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to convert proto Value to internal type")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	err = s.keyValueStorage.Save(req.GetKey(), value)
	if err != nil {
		slog.Error("failed to save key with given data", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to save key with given data")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	return &emptypb.Empty{}, nil
}

func (s *StorageServer) Get(_ context.Context, req *api.GetRequest) (*api.GetResponse, error) {

	key := req.GetKey()
	if key == "" {
		return nil, status.Error(codes.InvalidArgument, "key is required")
	}

	value, err := s.keyValueStorage.Get(key)
	if err != nil {
		slog.Error("failed to get key", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to get key")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	protoValue, err := toProtoValue(value)
	if err != nil {
		slog.Error("failed to convert data to proto Value", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to convert data to proto Value")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	return api.GetResponse_builder{
		Value: protoValue,
	}.Build(), nil
}

func (s *StorageServer) Delete(_ context.Context, req *api.DeleteRequest) (*emptypb.Empty, error) {
	if req.GetKey() == "" {
		return nil, status.Error(codes.InvalidArgument, "key is required")
	}

	err := s.keyValueStorage.Delete(req.GetKey())
	if err != nil {
		slog.Error("failed to delete key", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to delete key")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	return &emptypb.Empty{}, nil
}

func (s *StorageServer) SaveBatch(_ context.Context, req *api.SaveBatchRequest) (*emptypb.Empty, error) {
	if req.GetItems() == nil {
		return nil, status.Error(codes.InvalidArgument, "Items are required")
	}

	items, err := toAnyMap(req.GetItems())
	if err != nil {
		slog.Error("failed to convert proto Struct to map", slog.Any("error", err))
	}
	err = s.keyValueStorage.SaveBatch(items)
	if err != nil {
		slog.Error("failed to save batch with given data", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to save batch with given data")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	return &emptypb.Empty{}, nil
}

func (s *StorageServer) GetBatch(_ context.Context, req *api.GetBatchRequest) (*api.GetBatchResponse, error) {
	keys := req.GetKeys()
	if len(keys) == 0 {
		return nil, status.Error(codes.InvalidArgument, "keys are required")
	}

	items, err := s.keyValueStorage.GetBatch(keys)
	if err != nil {
		slog.Error("failed to get batch with given keys", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to get batch with given keys")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	if len(items) == 0 {
		return nil, status.Error(codes.Internal, "failed to found values for keys")
	}

	protoItems, err := toProtoValueMap(items)
	if err != nil {
		slog.Error("failed to convert data to proto Struct", slog.Any("error", err))
		errorStatus := status.New(codes.Internal, "failed to convert data to proto Struct")
		return nil, addErrorDetailsToStatus(err, errorStatus)
	}

	return api.GetBatchResponse_builder{
		Items: protoItems,
	}.Build(), nil
}

func toAny(protoValue *api.Value) (any, error) {
	switch protoValue.WhichKind() {
	case api.Value_NullValue_case:
		return nil, nil
	case api.Value_DoubleValue_case:
		return protoValue.GetDoubleValue(), nil
	case api.Value_IntValue_case:
		return protoValue.GetIntValue(), nil
	case api.Value_LongValue_case:
		return protoValue.GetLongValue(), nil
	case api.Value_StringValue_case:
		return protoValue.GetStringValue(), nil
	case api.Value_BoolValue_case:
		return protoValue.GetBoolValue(), nil
	default:
		return nil, fmt.Errorf("invalid value kind: %s", protoValue.WhichKind().String())
	}
}

func toProtoValue(value any) (*api.Value, error) {
	protoValue := &api.Value{}
	switch v := value.(type) {
	case nil:
		protoValue.SetNullValue(api.NullValue_NULL_VALUE)
		return protoValue, nil
	case float64:
		protoValue.SetDoubleValue(v)
		return protoValue, nil
	case int64:
		protoValue.SetLongValue(v)
		return protoValue, nil
	case int32:
		protoValue.SetIntValue(v)
		return protoValue, nil
	case string:
		protoValue.SetStringValue(v)
		return protoValue, nil
	case bool:
		protoValue.SetBoolValue(v)
		return protoValue, nil
	default:
		return nil, fmt.Errorf("unknown type %T", v)
	}
}

func toAnyMap(protoItems *api.Struct) (map[string]any, error) {
	protoValues := protoItems.GetFields()
	if protoValues == nil {
		return nil, fmt.Errorf("proto values are required")
	}
	items := make(map[string]any, len(protoValues))
	for key, value := range protoValues {
		anyValue, err := toAny(value)
		if err != nil {
			return nil, err
		}
		items[key] = anyValue
	}
	return items, nil
}

func toProtoValueMap(items map[string]any) (*api.Struct, error) {
	if items == nil {
		return nil, fmt.Errorf("items are required")
	}
	protoItems := make(map[string]*api.Value, len(items))
	for key, value := range items {
		protoItem, err := toProtoValue(value)
		if err != nil {
			return nil, err
		}
		protoItems[key] = protoItem
	}
	return api.Struct_builder{Fields: protoItems}.Build(), nil
}

func addErrorDetailsToStatus(err error, errorStatus *status.Status) error {
	errorWithDetails, err := errorStatus.WithDetails(&errdetails.DebugInfo{
		Detail: err.Error(),
	})
	if err != nil {
		return errorStatus.Err()
	}
	return errorWithDetails.Err()
}
