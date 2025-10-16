//
//  LibwalletService.swift
//  Muun
//
//  Created by Daniel Mankowski on 25/10/2024.
//  Copyright © 2024 muun. All rights reserved.
//

import Foundation
import Libwallet

public enum FeeBumpRefreshPolicy: String {
    case foreground
    case periodic
    case newOpBlockingly
    case ntsChanged
}

extension FeeBumpRefreshPolicy: APIConvertible {

    public func toJson() -> FeeBumpRefreshPolicyJson {
        switch self {
        case .foreground: return .foreground
        case .ntsChanged: return .ntsChanged
        case .newOpBlockingly: return .newOpBlockingly
        case .periodic: return .periodic
        }
    }
}

/// LibwalletService is a protocol that abstract interactions with Libwallet library.
public protocol LibwalletService {
    // MARK: Fee Bump Functions 
    func persistFeeBumpFunctions(feeBumpFunctions: FeeBumpFunctions,
                                 refreshPolicy: FeeBumpRefreshPolicy)
    func areFeeBumpFunctionsInvalidated() -> Bool
}

public class GoLibwalletService: LibwalletService {
    public func persistFeeBumpFunctions(feeBumpFunctions: FeeBumpFunctions,
                                        refreshPolicy: FeeBumpRefreshPolicy) {
        let feeBumpFunctionsStringList = LibwalletNewStringList()
        feeBumpFunctions.functions.forEach { feeBumpFunctionsStringList?.add($0) }

        do {
            return try doWithError({ error in
                NewopPersistFeeBumpFunctions(feeBumpFunctionsStringList,
                                             feeBumpFunctions.uuid,
                                             refreshPolicy.rawValue,
                                             error)
            })
        } catch {
            Logger.log(error: error)
        }
    }

    public func areFeeBumpFunctionsInvalidated() -> Bool {
        NewopAreFeeBumpFunctionsInvalidated()
    }
}
