//
// Simple Bitcoin Payment Protocol messages
//
// Use fields 1000+ for extensions;
// to avoid conflicts, register extensions via pull-req at
// https://github.com/bitcoin/bips/blob/master/bip-0070/extensions.mediawiki
//

// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.36.4
// 	protoc        v5.29.3
// source: bip70.proto

package libwallet

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
	unsafe "unsafe"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

// Generalized form of "send payment to this/these bitcoin addresses"
type Output struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Amount        uint64                 `protobuf:"varint,1,opt,name=amount,proto3" json:"amount,omitempty"` // amount is integer-number-of-satoshis
	Script        []byte                 `protobuf:"bytes,2,opt,name=script,proto3" json:"script,omitempty"`  // usually one of the standard Script forms
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Output) Reset() {
	*x = Output{}
	mi := &file_bip70_proto_msgTypes[0]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Output) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Output) ProtoMessage() {}

func (x *Output) ProtoReflect() protoreflect.Message {
	mi := &file_bip70_proto_msgTypes[0]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Output.ProtoReflect.Descriptor instead.
func (*Output) Descriptor() ([]byte, []int) {
	return file_bip70_proto_rawDescGZIP(), []int{0}
}

func (x *Output) GetAmount() uint64 {
	if x != nil {
		return x.Amount
	}
	return 0
}

type PaymentDetails struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Network       string                 `protobuf:"bytes,1,opt,name=network,proto3" json:"network,omitempty"`                               // "main" or "test"
	Outputs       []*Output              `protobuf:"bytes,2,rep,name=outputs,proto3" json:"outputs,omitempty"`                               // Where payment should be sent
	Time          uint64                 `protobuf:"varint,3,opt,name=time,proto3" json:"time,omitempty"`                                    // Timestamp; when payment request created
	Expires       uint64                 `protobuf:"varint,4,opt,name=expires,proto3" json:"expires,omitempty"`                              // Timestamp; when this request should be considered invalid
	Memo          string                 `protobuf:"bytes,5,opt,name=memo,proto3" json:"memo,omitempty"`                                     // Human-readable description of request for the customer
	PaymentUrl    string                 `protobuf:"bytes,6,opt,name=payment_url,json=paymentUrl,proto3" json:"payment_url,omitempty"`       // URL to send Payment and get PaymentACK
	MerchantData  []byte                 `protobuf:"bytes,7,opt,name=merchant_data,json=merchantData,proto3" json:"merchant_data,omitempty"` // Arbitrary data to include in the Payment message
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *PaymentDetails) Reset() {
	*x = PaymentDetails{}
	mi := &file_bip70_proto_msgTypes[1]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *PaymentDetails) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*PaymentDetails) ProtoMessage() {}

func (x *PaymentDetails) ProtoReflect() protoreflect.Message {
	mi := &file_bip70_proto_msgTypes[1]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use PaymentDetails.ProtoReflect.Descriptor instead.
func (*PaymentDetails) Descriptor() ([]byte, []int) {
	return file_bip70_proto_rawDescGZIP(), []int{1}
}

func (x *PaymentDetails) GetOutputs() []*Output {
	if x != nil {
		return x.Outputs
	}
	return nil
}

func (x *PaymentDetails) GetTime() uint64 {
	if x != nil {
		return x.Time
	}
	return 0
}

func (x *PaymentDetails) GetExpires() uint64 {
	if x != nil {
		return x.Expires
	}
	return 0
}

type PaymentRequest struct {
	state                    protoimpl.MessageState `protogen:"open.v1"`
	PaymentDetailsVersion    uint32                 `protobuf:"varint,1,opt,name=payment_details_version,json=paymentDetailsVersion,proto3" json:"payment_details_version,omitempty"`
	PkiType                  string                 `protobuf:"bytes,2,opt,name=pki_type,json=pkiType,proto3" json:"pki_type,omitempty"`                                                      // none / x509+sha256 / x509+sha1
	PkiData                  []byte                 `protobuf:"bytes,3,opt,name=pki_data,json=pkiData,proto3" json:"pki_data,omitempty"`                                                      // depends on pki_type
	SerializedPaymentDetails []byte                 `protobuf:"bytes,4,opt,name=serialized_payment_details,json=serializedPaymentDetails,proto3" json:"serialized_payment_details,omitempty"` // PaymentDetails
	Signature                []byte                 `protobuf:"bytes,5,opt,name=signature,proto3" json:"signature,omitempty"`                                                                 // pki-dependent signature
	unknownFields            protoimpl.UnknownFields
	sizeCache                protoimpl.SizeCache
}

func (x *PaymentRequest) Reset() {
	*x = PaymentRequest{}
	mi := &file_bip70_proto_msgTypes[2]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *PaymentRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*PaymentRequest) ProtoMessage() {}

func (x *PaymentRequest) ProtoReflect() protoreflect.Message {
	mi := &file_bip70_proto_msgTypes[2]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use PaymentRequest.ProtoReflect.Descriptor instead.
func (*PaymentRequest) Descriptor() ([]byte, []int) {
	return file_bip70_proto_rawDescGZIP(), []int{2}
}

func (x *PaymentRequest) GetPaymentDetailsVersion() uint32 {
	if x != nil {
		return x.PaymentDetailsVersion
	}
	return 0
}

type X509Certificates struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Certificate   [][]byte               `protobuf:"bytes,1,rep,name=certificate,proto3" json:"certificate,omitempty"` // DER-encoded X.509 certificate chain
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *X509Certificates) Reset() {
	*x = X509Certificates{}
	mi := &file_bip70_proto_msgTypes[3]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *X509Certificates) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*X509Certificates) ProtoMessage() {}

func (x *X509Certificates) ProtoReflect() protoreflect.Message {
	mi := &file_bip70_proto_msgTypes[3]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use X509Certificates.ProtoReflect.Descriptor instead.
func (*X509Certificates) Descriptor() ([]byte, []int) {
	return file_bip70_proto_rawDescGZIP(), []int{3}
}

func (x *X509Certificates) GetCertificate() [][]byte {
	if x != nil {
		return x.Certificate
	}
	return nil
}

type Payment struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	MerchantData  []byte                 `protobuf:"bytes,1,opt,name=merchant_data,json=merchantData,proto3" json:"merchant_data,omitempty"` // From PaymentDetails.merchant_data
	Transactions  [][]byte               `protobuf:"bytes,2,rep,name=transactions,proto3" json:"transactions,omitempty"`                     // Signed transactions that satisfy PaymentDetails.outputs
	RefundTo      []*Output              `protobuf:"bytes,3,rep,name=refund_to,json=refundTo,proto3" json:"refund_to,omitempty"`             // Where to send refunds, if a refund is necessary
	Memo          string                 `protobuf:"bytes,4,opt,name=memo,proto3" json:"memo,omitempty"`                                     // Human-readable message for the merchant
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *Payment) Reset() {
	*x = Payment{}
	mi := &file_bip70_proto_msgTypes[4]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *Payment) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Payment) ProtoMessage() {}

func (x *Payment) ProtoReflect() protoreflect.Message {
	mi := &file_bip70_proto_msgTypes[4]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Payment.ProtoReflect.Descriptor instead.
func (*Payment) Descriptor() ([]byte, []int) {
	return file_bip70_proto_rawDescGZIP(), []int{4}
}

func (x *Payment) GetTransactions() [][]byte {
	if x != nil {
		return x.Transactions
	}
	return nil
}

func (x *Payment) GetRefundTo() []*Output {
	if x != nil {
		return x.RefundTo
	}
	return nil
}

type PaymentACK struct {
	state         protoimpl.MessageState `protogen:"open.v1"`
	Payment       *Payment               `protobuf:"bytes,1,opt,name=payment,proto3" json:"payment,omitempty"` // Payment message that triggered this ACK
	Memo          string                 `protobuf:"bytes,2,opt,name=memo,proto3" json:"memo,omitempty"`       // human-readable message for customer
	unknownFields protoimpl.UnknownFields
	sizeCache     protoimpl.SizeCache
}

func (x *PaymentACK) Reset() {
	*x = PaymentACK{}
	mi := &file_bip70_proto_msgTypes[5]
	ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
	ms.StoreMessageInfo(mi)
}

func (x *PaymentACK) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*PaymentACK) ProtoMessage() {}

func (x *PaymentACK) ProtoReflect() protoreflect.Message {
	mi := &file_bip70_proto_msgTypes[5]
	if x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use PaymentACK.ProtoReflect.Descriptor instead.
func (*PaymentACK) Descriptor() ([]byte, []int) {
	return file_bip70_proto_rawDescGZIP(), []int{5}
}

var File_bip70_proto protoreflect.FileDescriptor

var file_bip70_proto_rawDesc = string([]byte{
	0x0a, 0x0b, 0x62, 0x69, 0x70, 0x37, 0x30, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x12, 0x09, 0x6c,
	0x69, 0x62, 0x77, 0x61, 0x6c, 0x6c, 0x65, 0x74, 0x22, 0x38, 0x0a, 0x06, 0x4f, 0x75, 0x74, 0x70,
	0x75, 0x74, 0x12, 0x16, 0x0a, 0x06, 0x61, 0x6d, 0x6f, 0x75, 0x6e, 0x74, 0x18, 0x01, 0x20, 0x01,
	0x28, 0x04, 0x52, 0x06, 0x61, 0x6d, 0x6f, 0x75, 0x6e, 0x74, 0x12, 0x16, 0x0a, 0x06, 0x73, 0x63,
	0x72, 0x69, 0x70, 0x74, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x06, 0x73, 0x63, 0x72, 0x69,
	0x70, 0x74, 0x22, 0xdf, 0x01, 0x0a, 0x0e, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x44, 0x65,
	0x74, 0x61, 0x69, 0x6c, 0x73, 0x12, 0x18, 0x0a, 0x07, 0x6e, 0x65, 0x74, 0x77, 0x6f, 0x72, 0x6b,
	0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x6e, 0x65, 0x74, 0x77, 0x6f, 0x72, 0x6b, 0x12,
	0x2b, 0x0a, 0x07, 0x6f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x73, 0x18, 0x02, 0x20, 0x03, 0x28, 0x0b,
	0x32, 0x11, 0x2e, 0x6c, 0x69, 0x62, 0x77, 0x61, 0x6c, 0x6c, 0x65, 0x74, 0x2e, 0x4f, 0x75, 0x74,
	0x70, 0x75, 0x74, 0x52, 0x07, 0x6f, 0x75, 0x74, 0x70, 0x75, 0x74, 0x73, 0x12, 0x12, 0x0a, 0x04,
	0x74, 0x69, 0x6d, 0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x04, 0x52, 0x04, 0x74, 0x69, 0x6d, 0x65,
	0x12, 0x18, 0x0a, 0x07, 0x65, 0x78, 0x70, 0x69, 0x72, 0x65, 0x73, 0x18, 0x04, 0x20, 0x01, 0x28,
	0x04, 0x52, 0x07, 0x65, 0x78, 0x70, 0x69, 0x72, 0x65, 0x73, 0x12, 0x12, 0x0a, 0x04, 0x6d, 0x65,
	0x6d, 0x6f, 0x18, 0x05, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6d, 0x65, 0x6d, 0x6f, 0x12, 0x1f,
	0x0a, 0x0b, 0x70, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x5f, 0x75, 0x72, 0x6c, 0x18, 0x06, 0x20,
	0x01, 0x28, 0x09, 0x52, 0x0a, 0x70, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x55, 0x72, 0x6c, 0x12,
	0x23, 0x0a, 0x0d, 0x6d, 0x65, 0x72, 0x63, 0x68, 0x61, 0x6e, 0x74, 0x5f, 0x64, 0x61, 0x74, 0x61,
	0x18, 0x07, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x0c, 0x6d, 0x65, 0x72, 0x63, 0x68, 0x61, 0x6e, 0x74,
	0x44, 0x61, 0x74, 0x61, 0x22, 0xda, 0x01, 0x0a, 0x0e, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74,
	0x52, 0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x36, 0x0a, 0x17, 0x70, 0x61, 0x79, 0x6d, 0x65,
	0x6e, 0x74, 0x5f, 0x64, 0x65, 0x74, 0x61, 0x69, 0x6c, 0x73, 0x5f, 0x76, 0x65, 0x72, 0x73, 0x69,
	0x6f, 0x6e, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0d, 0x52, 0x15, 0x70, 0x61, 0x79, 0x6d, 0x65, 0x6e,
	0x74, 0x44, 0x65, 0x74, 0x61, 0x69, 0x6c, 0x73, 0x56, 0x65, 0x72, 0x73, 0x69, 0x6f, 0x6e, 0x12,
	0x19, 0x0a, 0x08, 0x70, 0x6b, 0x69, 0x5f, 0x74, 0x79, 0x70, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28,
	0x09, 0x52, 0x07, 0x70, 0x6b, 0x69, 0x54, 0x79, 0x70, 0x65, 0x12, 0x19, 0x0a, 0x08, 0x70, 0x6b,
	0x69, 0x5f, 0x64, 0x61, 0x74, 0x61, 0x18, 0x03, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x07, 0x70, 0x6b,
	0x69, 0x44, 0x61, 0x74, 0x61, 0x12, 0x3c, 0x0a, 0x1a, 0x73, 0x65, 0x72, 0x69, 0x61, 0x6c, 0x69,
	0x7a, 0x65, 0x64, 0x5f, 0x70, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x5f, 0x64, 0x65, 0x74, 0x61,
	0x69, 0x6c, 0x73, 0x18, 0x04, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x18, 0x73, 0x65, 0x72, 0x69, 0x61,
	0x6c, 0x69, 0x7a, 0x65, 0x64, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x44, 0x65, 0x74, 0x61,
	0x69, 0x6c, 0x73, 0x12, 0x1c, 0x0a, 0x09, 0x73, 0x69, 0x67, 0x6e, 0x61, 0x74, 0x75, 0x72, 0x65,
	0x18, 0x05, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x09, 0x73, 0x69, 0x67, 0x6e, 0x61, 0x74, 0x75, 0x72,
	0x65, 0x22, 0x34, 0x0a, 0x10, 0x58, 0x35, 0x30, 0x39, 0x43, 0x65, 0x72, 0x74, 0x69, 0x66, 0x69,
	0x63, 0x61, 0x74, 0x65, 0x73, 0x12, 0x20, 0x0a, 0x0b, 0x63, 0x65, 0x72, 0x74, 0x69, 0x66, 0x69,
	0x63, 0x61, 0x74, 0x65, 0x18, 0x01, 0x20, 0x03, 0x28, 0x0c, 0x52, 0x0b, 0x63, 0x65, 0x72, 0x74,
	0x69, 0x66, 0x69, 0x63, 0x61, 0x74, 0x65, 0x22, 0x96, 0x01, 0x0a, 0x07, 0x50, 0x61, 0x79, 0x6d,
	0x65, 0x6e, 0x74, 0x12, 0x23, 0x0a, 0x0d, 0x6d, 0x65, 0x72, 0x63, 0x68, 0x61, 0x6e, 0x74, 0x5f,
	0x64, 0x61, 0x74, 0x61, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0c, 0x52, 0x0c, 0x6d, 0x65, 0x72, 0x63,
	0x68, 0x61, 0x6e, 0x74, 0x44, 0x61, 0x74, 0x61, 0x12, 0x22, 0x0a, 0x0c, 0x74, 0x72, 0x61, 0x6e,
	0x73, 0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x73, 0x18, 0x02, 0x20, 0x03, 0x28, 0x0c, 0x52, 0x0c,
	0x74, 0x72, 0x61, 0x6e, 0x73, 0x61, 0x63, 0x74, 0x69, 0x6f, 0x6e, 0x73, 0x12, 0x2e, 0x0a, 0x09,
	0x72, 0x65, 0x66, 0x75, 0x6e, 0x64, 0x5f, 0x74, 0x6f, 0x18, 0x03, 0x20, 0x03, 0x28, 0x0b, 0x32,
	0x11, 0x2e, 0x6c, 0x69, 0x62, 0x77, 0x61, 0x6c, 0x6c, 0x65, 0x74, 0x2e, 0x4f, 0x75, 0x74, 0x70,
	0x75, 0x74, 0x52, 0x08, 0x72, 0x65, 0x66, 0x75, 0x6e, 0x64, 0x54, 0x6f, 0x12, 0x12, 0x0a, 0x04,
	0x6d, 0x65, 0x6d, 0x6f, 0x18, 0x04, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6d, 0x65, 0x6d, 0x6f,
	0x22, 0x4e, 0x0a, 0x0a, 0x50, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x41, 0x43, 0x4b, 0x12, 0x2c,
	0x0a, 0x07, 0x70, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x18, 0x01, 0x20, 0x01, 0x28, 0x0b, 0x32,
	0x12, 0x2e, 0x6c, 0x69, 0x62, 0x77, 0x61, 0x6c, 0x6c, 0x65, 0x74, 0x2e, 0x50, 0x61, 0x79, 0x6d,
	0x65, 0x6e, 0x74, 0x52, 0x07, 0x70, 0x61, 0x79, 0x6d, 0x65, 0x6e, 0x74, 0x12, 0x12, 0x0a, 0x04,
	0x6d, 0x65, 0x6d, 0x6f, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6d, 0x65, 0x6d, 0x6f,
	0x42, 0x08, 0x5a, 0x06, 0x2f, 0x62, 0x69, 0x70, 0x37, 0x30, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x33,
})

var (
	file_bip70_proto_rawDescOnce sync.Once
	file_bip70_proto_rawDescData []byte
)

func file_bip70_proto_rawDescGZIP() []byte {
	file_bip70_proto_rawDescOnce.Do(func() {
		file_bip70_proto_rawDescData = protoimpl.X.CompressGZIP(unsafe.Slice(unsafe.StringData(file_bip70_proto_rawDesc), len(file_bip70_proto_rawDesc)))
	})
	return file_bip70_proto_rawDescData
}

var file_bip70_proto_msgTypes = make([]protoimpl.MessageInfo, 6)
var file_bip70_proto_goTypes = []any{
	(*Output)(nil),           // 0: libwallet.Output
	(*PaymentDetails)(nil),   // 1: libwallet.PaymentDetails
	(*PaymentRequest)(nil),   // 2: libwallet.PaymentRequest
	(*X509Certificates)(nil), // 3: libwallet.X509Certificates
	(*Payment)(nil),          // 4: libwallet.Payment
	(*PaymentACK)(nil),       // 5: libwallet.PaymentACK
}
var file_bip70_proto_depIdxs = []int32{
	0, // 0: libwallet.PaymentDetails.outputs:type_name -> libwallet.Output
	0, // 1: libwallet.Payment.refund_to:type_name -> libwallet.Output
	4, // 2: libwallet.PaymentACK.payment:type_name -> libwallet.Payment
	3, // [3:3] is the sub-list for method output_type
	3, // [3:3] is the sub-list for method input_type
	3, // [3:3] is the sub-list for extension type_name
	3, // [3:3] is the sub-list for extension extendee
	0, // [0:3] is the sub-list for field type_name
}

func init() { file_bip70_proto_init() }
func file_bip70_proto_init() {
	if File_bip70_proto != nil {
		return
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: unsafe.Slice(unsafe.StringData(file_bip70_proto_rawDesc), len(file_bip70_proto_rawDesc)),
			NumEnums:      0,
			NumMessages:   6,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_bip70_proto_goTypes,
		DependencyIndexes: file_bip70_proto_depIdxs,
		MessageInfos:      file_bip70_proto_msgTypes,
	}.Build()
	File_bip70_proto = out.File
	file_bip70_proto_goTypes = nil
	file_bip70_proto_depIdxs = nil
}
