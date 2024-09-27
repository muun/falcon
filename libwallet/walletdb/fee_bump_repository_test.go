package walletdb

import (
	"math"
	"path"
	"reflect"
	"testing"

	"github.com/muun/libwallet/operation"
)

func TestCreateFeeBumpFunctions(t *testing.T) {
	db, err := setupTestDb(t)
	if err != nil {
		t.Fatalf("failed to set up test db: %v", err)
	}
	defer db.Close()

	repository := db.NewFeeBumpRepository()

	expectedFeeBumpFunctions := []*operation.FeeBumpFunction{
		{
			PartialLinearFunctions: []*operation.PartialLinearFunction{
				{
					LeftClosedEndpoint: 0,
					RightOpenEndpoint:  300,
					Slope:              2,
					Intercept:          300,
				},
				{
					LeftClosedEndpoint: 300,
					RightOpenEndpoint:  math.Inf(1),
					Slope:              3,
					Intercept:          200,
				},
			},
		},
		{
			PartialLinearFunctions: []*operation.PartialLinearFunction{
				{
					LeftClosedEndpoint: 0,
					RightOpenEndpoint:  100,
					Slope:              2,
					Intercept:          100,
				},
				{
					LeftClosedEndpoint: 100,
					RightOpenEndpoint:  math.Inf(1),
					Slope:              3,
					Intercept:          500,
				},
			},
		},
		{
			PartialLinearFunctions: []*operation.PartialLinearFunction{
				{
					LeftClosedEndpoint: 0,
					RightOpenEndpoint:  1000,
					Slope:              2,
					Intercept:          1000,
				},
				{
					LeftClosedEndpoint: 1000,
					RightOpenEndpoint:  math.Inf(1),
					Slope:              3,
					Intercept:          1500,
				},
			},
		},
	}

	err = repository.Store(expectedFeeBumpFunctions)
	if err != nil {
		t.Fatalf("failed to save fee bump functions: %v", err)
	}

	loadedFeeBumpFunctions, err := repository.GetAll()
	if err != nil {
		t.Fatalf("failed to load fee bump functions: %v", err)
	}

	if len(loadedFeeBumpFunctions) != len(expectedFeeBumpFunctions) {
		t.Errorf("expected %d fee bump functions, got %d", len(expectedFeeBumpFunctions), len(loadedFeeBumpFunctions))
	}

	for i, loadedFeeBumpFunction := range loadedFeeBumpFunctions {
		if len(loadedFeeBumpFunction.PartialLinearFunctions) != len(expectedFeeBumpFunctions[i].PartialLinearFunctions) {
			t.Errorf(
				"expected %d intervals, got %d",
				len(expectedFeeBumpFunctions[i].PartialLinearFunctions),
				len(loadedFeeBumpFunction.PartialLinearFunctions),
			)
		}

		for j, loadedpartialLinearFunction := range loadedFeeBumpFunction.PartialLinearFunctions {
			expectedPartialLinearFunction := expectedFeeBumpFunctions[i].PartialLinearFunctions[j]

			if !reflect.DeepEqual(loadedpartialLinearFunction, expectedPartialLinearFunction) {
				t.Errorf("loaded and expected partial linear functions are not equal")
			}
		}
	}

	err = repository.RemoveAll()
	if err != nil {
		t.Fatalf("failed removing all fee bump functions: %v", err)
	}

	loadedFeeBumpFunctions, err = repository.GetAll()
	if err != nil {
		t.Fatalf("failed to load fee bump functions: %v", err)
	}

	if len(loadedFeeBumpFunctions) != 0 {
		t.Fatalf("fee bump functions were not removed")
	}

	var dbPartialLinearFunctions []PartialLinearFunction
	db.db.Find(&dbPartialLinearFunctions)
	if len(dbPartialLinearFunctions) != 0 {
		t.Fatalf("partial linear functions were not removed")
	}
}

func setupTestDb(t *testing.T) (*DB, error) {
	dir := t.TempDir()

	db, err := Open(path.Join(dir, "test.db"))
	if err != nil {
		return nil, err
	}

	return db, err
}
