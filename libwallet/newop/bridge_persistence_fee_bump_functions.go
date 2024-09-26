package newop

import (
	"encoding/base64"
	"encoding/binary"
	"fmt"
	"math"
	"path"

	"github.com/muun/libwallet"
	"github.com/muun/libwallet/operation"
	"github.com/muun/libwallet/walletdb"
)

// PersistFeeBumpFunctions This is a bridge that stores fee bump functions
// from native apps in the device's local database.
func PersistFeeBumpFunctions(encodedBase64Functions []string) error {
	decodedFunctions, err := decodeFunctions(encodedBase64Functions)
	if err != nil {
		return err
	}

	feeBumpFunctions := convertToLibwalletFeeBumpFunctions(decodedFunctions)

	db, err := walletdb.Open(path.Join(libwallet.Cfg.DataDir, "wallet.db"))
	if err != nil {
		return err
	}
	defer db.Close()

	repository := db.NewFeeBumpRepository()
	return repository.Store(feeBumpFunctions)
}

func decodeFunctions(encodedFunctions []string) ([][][]float64, error) {
	var decodedFunctions [][][]float64
	for i := range encodedFunctions {
		decodedFunctionValues, err := decodeFromBase64(encodedFunctions[i])
		if err != nil {
			return nil, err
		}
		decodedFunctions = append(decodedFunctions, decodedFunctionValues)
	}
	return decodedFunctions, nil
}

func decodeFromBase64(base64Function string) ([][]float64, error) {
	decodedBytes, err := base64.StdEncoding.DecodeString(base64Function)
	if err != nil {
		return nil, err
	}

	const bytesPerFloat = 4
	if len(decodedBytes)%bytesPerFloat != 0 {
		return nil, fmt.Errorf(
			"decoded bytes length: %d is invalid. It should by multiple of %d",
			len(decodedBytes),
			bytesPerFloat,
		)
	}

	var listOfFloats []float64
	for i := 0; i < len(decodedBytes); i += bytesPerFloat {
		bits := binary.BigEndian.Uint32(decodedBytes[i : i+bytesPerFloat])
		decodedFloat := math.Float32frombits(bits)
		listOfFloats = append(listOfFloats, float64(decodedFloat))
	}

	// Each function consists 3 float values: Right Endpoint, Slope and Intercept.
	// Left Endpoint starts at 0 for the first interval, and then each subsequent
	// interval uses the previous Right Endpoint.
	const floatsPerTuple = 3
	var result [][]float64
	for i := 0; i < len(listOfFloats); i += floatsPerTuple {
		end := i + floatsPerTuple
		if end > len(listOfFloats) {
			return nil, fmt.Errorf(
				"fee bump function was incorrectly encoded; it should be a multiply of %d float numbers, got: %d",
				floatsPerTuple,
				len(listOfFloats),
			)
		}
		result = append(result, listOfFloats[i:end])
	}
	return result, nil
}

func convertToLibwalletFeeBumpFunctions(decodedFunctions [][][]float64) []*operation.FeeBumpFunction {
	// Convert to libwallet data types
	var feeBumpFunctions []*operation.FeeBumpFunction
	const rightOpenEndpointPosition = 0
	const slopePosition = 1
	const interceptPosition = 2
	for i := range decodedFunctions {
		lastLeftClosedEndpoint := 0.0
		var partialLinearFunctions []*operation.PartialLinearFunction
		for j := range decodedFunctions[i] {
			partialLinearFunction := &operation.PartialLinearFunction{
				LeftClosedEndpoint: lastLeftClosedEndpoint,
				RightOpenEndpoint:  decodedFunctions[i][j][rightOpenEndpointPosition],
				Slope:              decodedFunctions[i][j][slopePosition],
				Intercept:          decodedFunctions[i][j][interceptPosition],
			}
			partialLinearFunctions = append(
				partialLinearFunctions,
				partialLinearFunction,
			)
			lastLeftClosedEndpoint = decodedFunctions[i][j][rightOpenEndpointPosition]
		}
		feeBumpFunctions = append(
			feeBumpFunctions,
			&operation.FeeBumpFunction{PartialLinearFunctions: partialLinearFunctions},
		)
	}
	return feeBumpFunctions
}
