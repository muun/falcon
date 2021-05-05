package lnurl

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
	"time"

	"github.com/fiatjaf/go-lnurl"
)

const (
	StatusOK    = "OK"
	StatusError = "Error"
)

type Response struct {
	Status string `json:"status,omitempty"`
	Reason string `json:"reason,omitempty"`
}

type WithdrawResponse struct {
	Response
	Tag                string `json:"tag"`
	K1                 string `json:"k1"`
	Callback           string `json:"callback"`
	MaxWithdrawable    int64  `json:"maxWithdrawable"`
	MinWithdrawable    int64  `json:"minWithdrawable"`
	DefaultDescription string `json:"defaultDescription"`
}

// After adding new codes here, remember to export them in the root libwallet
// module so that the apps can consume them.
const (
	ErrDecode            int = 1
	ErrUnsafeURL         int = 2
	ErrUnreachable       int = 3
	ErrInvalidResponse   int = 4
	ErrResponse          int = 5
	ErrUnknown           int = 6
	ErrNotWithdraw       int = 7
	StatusContacting     int = 100
	StatusInvoiceCreated int = 101
	StatusReceiving      int = 102
	StatusSuccess        int = 103
)

type Event struct {
	Code     int
	Message  string
	Metadata string
}

var httpClient = http.Client{Timeout: 15 * time.Second}

type CreateInvoiceFunction func(amt int64, desc string, host string) (string, error)

func Validate(qr string) bool {
	// remove lightning prefix
	if strings.HasPrefix(strings.ToLower(qr), "lightning:") {
		qr = qr[len("lightning:"):]
	}
	// decode the qr
	_, err := decode(qr)
	return err == nil
}

// Withdraw will parse an LNURL withdraw QR and begin a withdraw process.
// Caller must wait for the actual payment after this function has notified success.
func Withdraw(qr string, createInvoiceFunc CreateInvoiceFunction, allowUnsafe bool, notify func(e *Event)) {
	// remove lightning prefix
	if strings.HasPrefix(strings.ToLower(qr), "lightning:") {
		qr = qr[len("lightning:"):]
	}
	// decode the qr
	qrUrl, err := decode(qr)
	if err != nil {
		notify(&Event{Code: ErrDecode, Message: err.Error()})
		return
	}
	if !allowUnsafe && qrUrl.Scheme != "https" {
		notify(&Event{Code: ErrUnsafeURL, Message: "URL from QR is not secure"})
		return
	}
	host := qrUrl.Hostname()
	// update contacting
	notify(&Event{Code: StatusContacting, Metadata: host})
	// start withdraw with service
	resp, err := httpClient.Get(qrUrl.String())
	if err != nil {
		notify(&Event{Code: ErrInvalidResponse, Message: err.Error()})
		return
	}
	// parse response
	var wr WithdrawResponse
	err = json.NewDecoder(resp.Body).Decode(&wr)
	if err != nil {
		msg := fmt.Sprintf("failed to parse response: %s", err.Error())
		notify(&Event{Code: ErrInvalidResponse, Message: msg})
		return
	}
	if wr.Status == StatusError {
		notify(&Event{Code: ErrResponse, Message: wr.Reason})
		return
	}
	if wr.Tag != "withdrawRequest" {
		notify(&Event{Code: ErrNotWithdraw, Message: "qr is not a LNURL withdraw request"})
		return
	}
	if wr.MaxWithdrawable <= 0 {
		msg := fmt.Sprintf("invalid maxWithdrawable amount: %d", wr.MaxWithdrawable)
		notify(&Event{Code: ErrInvalidResponse, Message: msg})
		return
	}
	callbackURL, err := url.Parse(wr.Callback)
	if err != nil {
		msg := fmt.Sprintf("invalid callback URL: %v", err)
		notify(&Event{Code: ErrInvalidResponse, Message: msg})
		return
	}
	if !allowUnsafe && callbackURL.Scheme != "https" {
		notify(&Event{Code: ErrUnsafeURL, Message: "callback URL is not secure"})
		return
	}
	if callbackURL.Host != qrUrl.Host {
		notify(&Event{Code: ErrInvalidResponse, Message: "callback URL does not match QR host"})
		return
	}

	// generate invoice
	invoice, err := createInvoiceFunc(wr.MaxWithdrawable, wr.DefaultDescription, host)
	if err != nil {
		notify(&Event{Code: ErrUnknown, Message: err.Error()})
		return
	}
	notify(&Event{Code: StatusInvoiceCreated, Metadata: invoice})

	query := url.Values{}
	query.Add("k1", wr.K1)
	query.Add("pr", invoice)

	callbackURL.RawQuery = query.Encode()
	// confirm withdraw with service
	notify(&Event{Code: StatusReceiving, Metadata: host})
	resp, err = httpClient.Get(callbackURL.String())
	if err != nil {
		msg := fmt.Sprintf("failed to get response from callback URL: %v", err)
		notify(&Event{Code: ErrUnreachable, Message: msg})
		return
	}
	// parse response
	var fr Response
	err = json.NewDecoder(resp.Body).Decode(&fr)
	if err != nil {
		msg := fmt.Sprintf("failed to parse response: %s", err.Error())
		notify(&Event{Code: ErrInvalidResponse, Message: msg})
		return
	}
	if fr.Status == StatusError {
		notify(&Event{Code: ErrResponse, Message: fr.Reason})
		return
	}
	notify(&Event{Code: StatusSuccess})
}

func decode(qr string) (*url.URL, error) {
	u, err := lnurl.LNURLDecode(qr)
	if err != nil {
		return nil, err
	}
	return url.Parse(string(u))
}
