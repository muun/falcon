package walletdb

import (
	"fmt"

	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/sqlite"
	"github.com/muun/libwallet/operation"
)

type FeeBumpRepository interface {
	Store(feeBumpFunctions []*operation.FeeBumpFunction) error
	GetAll() ([]*operation.FeeBumpFunction, error)
	RemoveAll() error
}

type FeeBumpFunction struct {
	gorm.Model
	Position uint
	// PartialLinearFunctions establishes a foreign key relationship with the PartialLinearFunction table,
	// where 'FunctionPosition' in PartialLinearFunction references 'Position' in FeeBumpFunction.
	PartialLinearFunctions []PartialLinearFunction `gorm:"foreignKey:FunctionPosition;references:Position;"`
}

type PartialLinearFunction struct {
	gorm.Model
	LeftClosedEndpoint float64
	RightOpenEndpoint  float64
	Slope              float64
	Intercept          float64
	FunctionPosition   uint
}

type GORMFeeBumpRepository struct {
	db *gorm.DB
}

func (r *GORMFeeBumpRepository) Store(feeBumpFunctions []*operation.FeeBumpFunction) error {
	dbFeeBumpFunctions := mapToDBFeeBumpFunctions(feeBumpFunctions)

	tx := r.db.Begin()
	for _, feeBumpFunction := range dbFeeBumpFunctions {
		if err := tx.Create(&feeBumpFunction).Error; err != nil {
			tx.Rollback()
			return err
		}
	}

	if err := tx.Commit().Error; err != nil {
		return fmt.Errorf("failed to save fee bump functions: %w", err)
	}
	return nil
}

func (r *GORMFeeBumpRepository) GetAll() ([]*operation.FeeBumpFunction, error) {
	var dbFeeBumpFunctions []FeeBumpFunction

	result := r.db.Preload("PartialLinearFunctions").Order("position asc").Find(&dbFeeBumpFunctions)

	if result.Error != nil {
		return nil, result.Error
	}

	feeBumpFunctions := mapToOperationFeeBumpFunctions(dbFeeBumpFunctions)

	return feeBumpFunctions, nil
}

func (r *GORMFeeBumpRepository) RemoveAll() error {
	result := r.db.Delete(FeeBumpFunction{})
	if result.Error != nil {
		return result.Error
	}

	result = r.db.Delete(PartialLinearFunction{})

	return result.Error
}

func mapToDBFeeBumpFunctions(feeBumpFunctions []*operation.FeeBumpFunction) []FeeBumpFunction {
	var dbFeeBumpFunctions []FeeBumpFunction
	for i, feeBumpFunction := range feeBumpFunctions {
		var dbPartialLinearFunctions []PartialLinearFunction
		for _, partialLinearFunction := range feeBumpFunction.PartialLinearFunctions {
			dbPartialLinearFunctions = append(dbPartialLinearFunctions, PartialLinearFunction{
				LeftClosedEndpoint: partialLinearFunction.LeftClosedEndpoint,
				RightOpenEndpoint:  partialLinearFunction.RightOpenEndpoint,
				Slope:              partialLinearFunction.Slope,
				Intercept:          partialLinearFunction.Intercept,
				FunctionPosition:   uint(i),
			})
		}
		dbFeeBumpFunctions = append(dbFeeBumpFunctions, FeeBumpFunction{
			Position:               uint(i),
			PartialLinearFunctions: dbPartialLinearFunctions,
		})
	}

	return dbFeeBumpFunctions
}

func mapToOperationFeeBumpFunctions(dbFeeBumpFunctions []FeeBumpFunction) []*operation.FeeBumpFunction {
	var feeBumpFunctions []*operation.FeeBumpFunction
	for _, dbFeeBumpFunction := range dbFeeBumpFunctions {
		var partialLinearFunctions []*operation.PartialLinearFunction
		for _, dbPartialLinearFunction := range dbFeeBumpFunction.PartialLinearFunctions {
			partialLinearFunctions = append(partialLinearFunctions, &operation.PartialLinearFunction{
				LeftClosedEndpoint: dbPartialLinearFunction.LeftClosedEndpoint,
				RightOpenEndpoint:  dbPartialLinearFunction.RightOpenEndpoint,
				Slope:              dbPartialLinearFunction.Slope,
				Intercept:          dbPartialLinearFunction.Intercept,
			})
		}

		feeBumpFunctions = append(
			feeBumpFunctions,
			&operation.FeeBumpFunction{
				PartialLinearFunctions: partialLinearFunctions,
			},
		)
	}
	return feeBumpFunctions
}
