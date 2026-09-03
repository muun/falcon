package nfc

import (
	"fmt"

	"github.com/go-errors/errors"

	"github.com/muun/libwallet/service"
)

type MuunAppletNotFoundError struct {
	Message string
	Cause   error
}

func (e MuunAppletNotFoundError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("muun applet id not found: %s: %v", e.Message, e.Cause)
	}
	return "muun applet id not found"
}

func (e MuunAppletNotFoundError) Unwrap() error {
	return e.Cause
}

type InvalidMacError struct {
	Message string
	Cause   error
}

func (e InvalidMacError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("mac is invalid: %s: %v", e.Message, e.Cause)
	}
	return "mac is invalid"
}

func (e InvalidMacError) Unwrap() error {
	return e.Cause
}

type ChallengeExpiredError struct {
	Message string
	Cause   error
}

func (e ChallengeExpiredError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("challenge is expired: %s: %v", e.Message, e.Cause)
	}
	return "challenge is expired"
}

func (e ChallengeExpiredError) Unwrap() error {
	return e.Cause
}

type NoSlotsAvailableError struct {
	Message string
	Cause   error
}

func (e NoSlotsAvailableError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("no slots available: %s: %v", e.Message, e.Cause)
	}
	return "no slots available"
}

func (e NoSlotsAvailableError) Unwrap() error {
	return e.Cause
}

// UnsupportedCardVersionError is returned when the tapped card's version cannot be
// determined or maps to no known protocol flow, meaning this app build doesn't recognize
// the card's firmware and the user should update the app.
type UnsupportedCardVersionError struct {
	Message string
	Cause   error
}

func (e UnsupportedCardVersionError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("unsupported card version: %s: %v", e.Message, e.Cause)
	}
	return fmt.Sprintf("unsupported card version: %s", e.Message)
}

func (e UnsupportedCardVersionError) Unwrap() error {
	return e.Cause
}

// PairInternalError Adding this error to track security cards internal testing
// It will be removed later
type PairInternalError struct {
	Message string
	Cause   error
}

func (e PairInternalError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("error during pairing: %s: %v", e.Message, e.Cause)
	}
	return "error during pairing"
}

func (e PairInternalError) Unwrap() error {
	return e.Cause
}

// mapHoustonCardError returns the action-level error for a security card failure reported
// by Houston, or nil when the failure is not one the presentation layer discriminates on —
// the caller wraps those itself, naming the step that failed.
func mapHoustonCardError(err error) error {
	var houstonError *service.HoustonResponseError
	if !errors.As(err, &houstonError) {
		return nil
	}

	switch houstonError.ErrorCode {
	case service.ErrInvalidMac, service.ErrInvalidSignature:
		return &InvalidMacError{
			Message: "mac verification failed",
			Cause:   houstonError,
		}
	case service.ErrChallengeExpired:
		return &ChallengeExpiredError{
			Message: "challenge has expired",
			Cause:   houstonError,
		}
	}
	return nil
}
