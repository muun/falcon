package libwallet

import (
	"bytes"
	"crypto/rand"
	"html/template"
	"io"
	"time"

	"github.com/pkg/errors"
)

// EKInput input struct to fill the PDF
type EKInput struct {
	FirstEncryptedKey  string
	SecondEncryptedKey string
}

// EKTemplate full struct to fill the PDF
type EKTemplate struct {
	FirstEncryptedKey  string
	SecondEncryptedKey string
	VerificationCode   string
	CurrentDate        string
}

// EKOutput with the html as string and the verification code
type EKOutput struct {
	HTML             string
	VerificationCode string
}

// GenerateEmergencyKitHTML returns the html as a string along with the verification code
func GenerateEmergencyKitHTML(ekParams *EKInput) (*EKOutput, error) {

	html := getEmergencyKitHTML()
	htmlBuf := new(bytes.Buffer)

	tmpl, err := template.New("EmergencyKit").Parse(html)
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to create new template from html")
	}

	verificationCode := getRandomVerificationCode()
	currentDate := time.Now()

	fullTemplate := EKTemplate{
		FirstEncryptedKey:  ekParams.FirstEncryptedKey,
		SecondEncryptedKey: ekParams.SecondEncryptedKey,
		VerificationCode:   verificationCode,
		// Careful: do not change these format values. See the doc more info: https://golang.org/pkg/time/#pkg-constants
		CurrentDate: currentDate.Format("2006/01/02"), // Format date to YYYY/MM/DD
	}

	err = tmpl.Execute(htmlBuf, fullTemplate)
	if err != nil {
		return nil, errors.Wrapf(err, "Failed to fill PDF with custom data")
	}

	return &EKOutput{
		htmlBuf.String(),
		verificationCode,
	}, nil
}

func getRandomVerificationCode() string {
	const length = 6

	charset := [...]byte{'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'}
	result := make([]byte, length)

	n, err := io.ReadAtLeast(rand.Reader, result, length)
	if n != length {
		panic(err)
	}

	for i := 0; i < len(result); i++ {
		result[i] = charset[int(result[i])%len(charset)]
	}

	return string(result)
}
