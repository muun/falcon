package libwallet

import (
	"reflect"
	"testing"
)

func TestNewChallengePrivateKey(t *testing.T) {
	type args struct {
		input []byte
		salt  []byte
	}
	tests := []struct {
		name string
		args args
		want *ChallengePrivateKey
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := NewChallengePrivateKey(tt.args.input, tt.args.salt); !reflect.DeepEqual(got, tt.want) {
				t.Errorf("NewChallengePrivateKey() = %v, want %v", got, tt.want)
			}
		})
	}
}
