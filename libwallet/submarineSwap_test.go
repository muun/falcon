package libwallet

import "testing"

func TestValidateSubmarineSwap(t *testing.T) {
	type args struct {
		rawInvoice    string
		userPublicKey *HDPublicKey
		muunPublicKey *HDPublicKey
		swap          SubmarineSwap
		network       *Network
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if err := ValidateSubmarineSwap(tt.args.rawInvoice, tt.args.userPublicKey, tt.args.muunPublicKey, tt.args.swap, tt.args.network); (err != nil) != tt.wantErr {
				t.Errorf("ValidateSubmarineSwap() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
