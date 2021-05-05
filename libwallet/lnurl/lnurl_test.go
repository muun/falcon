package lnurl

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/fiatjaf/go-lnurl"
)

func TestWithdraw(t *testing.T) {
	mux := http.NewServeMux()
	mux.HandleFunc("/withdraw/", func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(&WithdrawResponse{
			K1:                 "foobar",
			Callback:           "http://" + r.Host + "/withdraw/complete",
			MaxWithdrawable:    1000,
			DefaultDescription: "Withdraw from Lapp",
			Tag:                "withdrawRequest",
		})
	})
	mux.HandleFunc("/withdraw/complete", func(w http.ResponseWriter, r *http.Request) {
		json.NewEncoder(w).Encode(&Response{
			Status: StatusOK,
		})
	})
	server := httptest.NewServer(mux)
	defer server.Close()

	qr, _ := encode(fmt.Sprintf("%s/withdraw", server.URL))

	createInvoiceFunc := func(amt int64, desc string, host string) (string, error) {
		if amt != 1000 {
			t.Fatalf("unexpected invoice amount: %v", amt)
		}
		if desc != "Withdraw from Lapp" {
			t.Fatalf("unexpected invoice description: %v", desc)
		}
		if host != "127.0.0.1" {
			t.Fatalf("unexpected host: %v", host)
		}
		return "12345", nil
	}

	var err string
	Withdraw(qr, createInvoiceFunc, true, func(e *Event) {
		if e.Code < 100 {
			err = e.Message
		}
	})
	if err != "" {
		t.Fatalf("expected withdraw to succeed, got: %v", err)
	}
}

func TestValidate(t *testing.T) {
	link := "lightning:LNURL1DP68GUP69UHKCMMRV9KXSMMNWSARWVPCXQHKCMN4WFKZ7AMFW35XGUNPWULHXETRWFJHG0F3XGENGDGK59DKV"

	ok := Validate(link)
	if !ok {
		t.Fatal("expected to validate link")
	}
}

func encode(url string) (string, error) {
	return lnurl.LNURLEncode(url)
}
