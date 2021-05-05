package libwallet

import (
	"github.com/muun/libwallet/lnurl"
)

type LNURLEvent struct {
	Code     int
	Message  string
	Metadata string
}

const (
	LNURLErrDecode            = lnurl.ErrDecode
	LNURLErrUnsafeURL         = lnurl.ErrUnsafeURL
	LNURLErrUnreachable       = lnurl.ErrUnreachable
	LNURLErrInvalidResponse   = lnurl.ErrInvalidResponse
	LNURLErrResponse          = lnurl.ErrResponse
	LNURLErrUnknown           = lnurl.ErrUnknown
	LNURLStatusContacting     = lnurl.StatusContacting
	LNURLStatusInvoiceCreated = lnurl.StatusInvoiceCreated
	LNURLStatusReceiving      = lnurl.StatusReceiving
	LNURLStatusSuccess        = lnurl.StatusSuccess
)

type LNURLListener interface {
	OnUpdate(e *LNURLEvent)
	OnError(e *LNURLEvent)
}

func LNURLValidate(qr string) bool {
	return lnurl.Validate(qr)
}

// Withdraw will parse an LNURL withdraw QR and begin a withdraw process.
// Caller must wait for the actual payment after this function has notified success.
func LNURLWithdraw(net *Network, userKey *HDPrivateKey, routeHints *RouteHints, qr string, listener LNURLListener) {
	// TODO: consider making a struct out of the (net, userKey, routeHints) data
	// that can be used for creating invoices
	createInvoiceFunc := func(amt int64, desc string, host string) (string, error) {
		opts := &InvoiceOptions{
			AmountSat:   amt,
			Description: desc,
			Metadata: &OperationMetadata{
				LnurlSender: host,
			},
		}
		return CreateInvoice(net, userKey, routeHints, opts)
	}

	allowUnsafe := net != Mainnet()

	lnurl.Withdraw(qr, createInvoiceFunc, allowUnsafe, func(e *lnurl.Event) {
		event := &LNURLEvent{
			Code:     e.Code,
			Message:  e.Message,
			Metadata: e.Metadata,
		}
		if event.Code < 100 {
			listener.OnError(event)
		} else {
			listener.OnUpdate(event)
		}
	})
}
