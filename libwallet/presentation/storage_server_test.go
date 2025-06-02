package presentation

import (
	"context"
	"github.com/muun/libwallet/storage"
	"google.golang.org/grpc/codes"
	"net"
	"path"
	"testing"

	"github.com/muun/libwallet/presentation/api"
	"google.golang.org/genproto/googleapis/rpc/errdetails"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/resolver"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/test/bufconn"
)

var bufconnListener *bufconn.Listener
var storageServer = &StorageServer{}

func init() {
	// Initialize grpc server of StorageService with bufconn
	bufconnListener = bufconn.Listen(1024 * 1024)
	grpcServer := grpc.NewServer()
	api.RegisterStorageServiceServer(grpcServer, storageServer)

	go func() {
		if err := grpcServer.Serve(bufconnListener); err != nil {
			panic(err)
		}
	}()

}

func dialer() func(context.Context, string) (net.Conn, error) {
	return func(ctx context.Context, s string) (net.Conn, error) {
		return bufconnListener.Dial()
	}
}

func TestSaveAndGetAndDelete(t *testing.T) {

	t.Run("success when saving, reading and deleting a key-value pair", func(t *testing.T) {
		setup(t)

		// Initialize grpc client of StorageService with bufconn
		conn, ctx := newGrpcClient(t)
		defer conn.Close()
		client := api.NewStorageServiceClient(conn)

		// Create Value message for emergencyKitVersion
		emergencyKitVersion := int32(1234)
		value := api.Value_builder{IntValue: &emergencyKitVersion}.Build()

		// Create SaveRequest
		saveReq := api.SaveRequest_builder{
			Key:   "emergencyKitVersion",
			Value: value,
		}.Build()

		// Call grpc client with SaveRequest
		_, err := client.Save(ctx, saveReq)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		// Create GetRequest
		getRequest := api.GetRequest_builder{Key: "emergencyKitVersion"}.Build()

		// Call grpc client with GetRequest
		getResponse, err := client.Get(ctx, getRequest)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		want := int32(1234)
		got := getResponse.GetValue().GetIntValue()
		if got != want {
			t.Errorf("want %v, but got %v", want, got)
		}

		// Create DeleteRequest
		deleteReq := api.DeleteRequest_builder{
			Key: "emergencyKitVersion",
		}.Build()

		// Call grpc client with DeleteRequest
		_, err = client.Delete(ctx, deleteReq)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		// Call grpc client with GetRequest
		getResponse, err = client.Get(ctx, getRequest)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		// Verify response is null after deleting the key-value pair
		if !getResponse.GetValue().HasNullValue() {
			t.Errorf("want null value, but got a non-null value")
		}
	})

	t.Run("return error when SaveRequest does not have a key defined", func(t *testing.T) {

		setup(t)

		// Initialize grpc client of StorageService with bufconn
		conn, ctx := newGrpcClient(t)
		defer conn.Close()
		client := api.NewStorageServiceClient(conn)

		// Create grpc message with NullValue for emergencyKitVersion
		nullValue := api.NullValue_NULL_VALUE
		value := api.Value_builder{NullValue: &nullValue}.Build()

		// Create SaveRequest without defining a key
		saveReq := api.SaveRequest_builder{
			Value: value,
		}.Build()

		// Call grpc client with SaveRequest
		_, err := client.Save(ctx, saveReq)
		if err == nil {
			t.Fatalf("expect error")
		}

		grpcStatus := status.Convert(err)
		if grpcStatus.Code() != codes.InvalidArgument {
			t.Errorf("want %v, but got %v", codes.InvalidArgument, grpcStatus.Code())
		}
		wantErr := "key is required"
		if grpcStatus.Message() != wantErr {
			t.Errorf("want %v, but got %v", wantErr, grpcStatus.Message())
		}

	})

	t.Run("return error when SaveRequest has an invalid key", func(t *testing.T) {

		setup(t)

		// Initialize grpc client of StorageService with bufconn
		conn, ctx := newGrpcClient(t)
		defer conn.Close()
		client := api.NewStorageServiceClient(conn)

		// Create grpc message with NullValue for emergencyKitVersion
		nullValue := api.NullValue_NULL_VALUE
		value := api.Value_builder{NullValue: &nullValue}.Build()

		// Create SaveRequest with an invalid key
		saveReq := api.SaveRequest_builder{
			Key:   "invalid-key",
			Value: value,
		}.Build()

		// Call grpc client with SaveRequest
		_, err := client.Save(ctx, saveReq)
		if err == nil {
			t.Fatalf("expect error")
		}

		// Verify we fail due to the invalid key
		grpcStatus := status.Convert(err)
		if grpcStatus.Code() != codes.Internal {
			t.Errorf("want %v, but got %v", codes.Internal, grpcStatus.Code())
		}
		wantErr := "failed to save key with given data"
		if grpcStatus.Message() != wantErr {
			t.Errorf("want %v, but got %v", wantErr, grpcStatus.Message())
		}
		wantErr = "classification not found for key: invalid-key"
		got := getGrpcStatusDetail(t, grpcStatus)
		if got != wantErr {
			t.Errorf("want %v, but got %v", wantErr, got)
		}

	})

	t.Run("success when saving a key with NullValue", func(t *testing.T) {

		setup(t)

		// Initialize grpc client of StorageService with bufconn
		conn, ctx := newGrpcClient(t)
		defer conn.Close()
		client := api.NewStorageServiceClient(conn)

		// Create grpc message with NullValue for emergencyKitVersion
		apiNull := api.NullValue_NULL_VALUE
		nullValue := api.Value_builder{NullValue: &apiNull}.Build()

		// Create SaveRequest
		saveReq := api.SaveRequest_builder{
			Key:   "emergencyKitVersion",
			Value: nullValue,
		}.Build()

		// Call grpc client with SaveRequest
		_, err := client.Save(ctx, saveReq)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		// Create GetRequest
		getRequest := api.GetRequest_builder{Key: "emergencyKitVersion"}.Build()

		// Call grpc client with GetRequest
		getResponse, err := client.Get(ctx, getRequest)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		// Verify response is null
		if !getResponse.GetValue().HasNullValue() {
			t.Errorf("want null value, but got a non-null value")
		}

	})
}

func getGrpcStatusDetail(t *testing.T, grpcStatus *status.Status) string {
	var grpcStatusDetail string
	for _, d := range grpcStatus.Details() {
		switch detailsInfo := d.(type) {
		case *errdetails.DebugInfo:
			grpcStatusDetail = detailsInfo.GetDetail()
		default:
			t.Errorf("Unexpected type for detailsInfo")
			t.Fatalf("Error details = %s", d)
		}
	}
	return grpcStatusDetail
}

func TestSaveBatchAndGetBatch(t *testing.T) {

	t.Run("success when saving and reading key-value pairs in batches", func(t *testing.T) {
		setup(t)

		// Initialize grpc client of StorageService with bufconn
		conn, ctx := newGrpcClient(t)
		defer conn.Close()
		client := api.NewStorageServiceClient(conn)

		// Create Struct message with a map of key-values
		items := map[string]any{
			"emergencyKitVersion": int32(123),
			"primaryCurrency":     "USD",
			"email":               "pepe@test.com",
			"gcmToken":            nil,
			"isEmailVerified":     true,
		}
		protoItems, err := toProtoValueMap(items)
		if err != nil {
			t.Fatalf("failed to create Struct for items: %v", err)
		}

		// Create SaveBatchRequest
		saveBatchReq := api.SaveBatchRequest_builder{
			Items: protoItems,
		}.Build()

		// Call grpc client with SaveBatchRequest
		_, err = client.SaveBatch(ctx, saveBatchReq)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		// Create GetBatchRequest
		getBatchReq := api.GetBatchRequest_builder{
			Keys: []string{"primaryCurrency", "email", "isEmailVerified", "emergencyKitVersion", "gcmToken"},
		}.Build()

		// Call grpc client with GetBatchRequest
		getBatchResponse, err := client.GetBatch(ctx, getBatchReq)
		if err != nil {
			failWithGrpcErrorDetails(t, err)
		}

		var want any
		var got any

		// Validate returned data
		want = "USD"
		got = getBatchResponse.GetItems().GetFields()["primaryCurrency"].GetStringValue()
		if got != want {
			t.Fatalf("want %v, but got %v", want, got)
		}

		want = "pepe@test.com"
		got = getBatchResponse.GetItems().GetFields()["email"].GetStringValue()
		if got != want {
			t.Fatalf("want %v, but got %v", want, got)
		}

		want = int32(123)
		got = getBatchResponse.GetItems().GetFields()["emergencyKitVersion"].GetIntValue()
		if got != want {
			t.Fatalf("want %v, but got %v", want, got)
		}

		if !getBatchResponse.GetItems().GetFields()["gcmToken"].HasNullValue() {
			t.Fatalf("want null value, but got a non-null value")
		}

		want = true
		got = getBatchResponse.GetItems().GetFields()["isEmailVerified"].GetBoolValue()
		if got != want {
			t.Fatalf("want %v, but got %v", want, got)
		}
	})

}

func setup(t *testing.T) {
	// Create a new empty DB providing a new dataFilePath
	dataFilePath := path.Join(t.TempDir(), "test.db")
	keyValueStorage := storage.NewKeyValueStorage(dataFilePath, buildStorageSchemaForTests())

	// For testing purpose, change reference to this new keyValueStorage in order to have a new empty DB
	storageServer.keyValueStorage = keyValueStorage
}

func newGrpcClient(t *testing.T) (*grpc.ClientConn, context.Context) {
	ctx := context.Background()
	resolver.SetDefaultScheme("passthrough")
	conn, err := grpc.NewClient(
		"bufnet",
		grpc.WithContextDialer(dialer()),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	)
	if err != nil {
		t.Fatalf("failed to dial bufnet: %v", err)
	}
	return conn, ctx
}

func failWithGrpcErrorDetails(t testing.TB, err error) {
	t.Helper()
	t.Errorf("Error = %v", err)
	grpcStatus := status.Convert(err)
	for _, d := range grpcStatus.Details() {
		switch detailsInfo := d.(type) {
		case *errdetails.DebugInfo:
			t.Fatalf("Error details = %s", detailsInfo.GetDetail())
		default:
			t.Errorf("Unexpected type for detailsInfo")
			t.Fatalf("Error details = %s", d)
		}
	}
}

func buildStorageSchemaForTests() map[string]storage.Classification {
	return map[string]storage.Classification{
		"email": {
			BackupType:       storage.NoAutoBackup,
			BackupSecurity:   storage.NotApplicable,
			SecurityCritical: false,
			ValueType:        &storage.StringType{},
		},
		"emergencyKitVersion": {
			BackupType:       storage.NoAutoBackup,
			BackupSecurity:   storage.NotApplicable,
			SecurityCritical: false,
			ValueType:        &storage.IntType{},
		},
		"gcmToken": {
			BackupType:       storage.NoAutoBackup,
			BackupSecurity:   storage.NotApplicable,
			SecurityCritical: false,
			ValueType:        &storage.StringType{},
		},
		"isEmailVerified": {
			BackupType:       storage.NoAutoBackup,
			BackupSecurity:   storage.NotApplicable,
			SecurityCritical: false,
			ValueType:        &storage.BoolType{},
		},
		"primaryCurrency": {
			BackupType:       storage.NoAutoBackup,
			BackupSecurity:   storage.NotApplicable,
			SecurityCritical: false,
			ValueType:        &storage.StringType{},
		},
	}
}
