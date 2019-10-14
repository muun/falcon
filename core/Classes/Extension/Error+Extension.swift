//
//  Error+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 01/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

extension Error {

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

}
