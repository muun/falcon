//
//  Error+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 01/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

extension Error {

    public func isNetworkError() -> Bool {

        if let muunError = self as? MuunError {

            if let error = muunError.kind as? ServiceError {

                return error.isNetworkError()
            }
        }

        return false
    }

    public func isKindOf(_ exactError: ExactDeveloperError) -> Bool {

        if let muunError = self as? MuunError {

            if let error = muunError.kind as? ServiceError {

                switch error {

                case .customError(let devError):
                    switch devError.getKindOfError() {

                    case exactError:
                        return true

                    default:
                        return false
                    }

                default:
                    return false
                }
            }
        }

        return false
    }

    public func isKindOf(_ comparedError: DomainError) -> Bool {
        if let selfAsMuunError = self as? MuunError,
           let selfAsDomainError = selfAsMuunError.kind as? DomainError {
            return comparedError == selfAsDomainError
        }

        return false
    }

    func isKindOf(_ comparedError: KeyStorageError) -> Bool {
        if let selfAsMuunError = self as? MuunError,
           let selfAsKeyStorageError = selfAsMuunError.kind as? KeyStorageError {
            return selfAsKeyStorageError == comparedError
        }
        
        return false
    }

    public func contains<T: Error & Equatable>(_ expected: T) -> Bool {

        if let err = self as? T {
            return err == expected
        } else if let muunError = self as? MuunError {
            if let err = muunError.kind as? T {
                return err == expected
            }
        }

        return false
    }
}
