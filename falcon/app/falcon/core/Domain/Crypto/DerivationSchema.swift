//
//  DerivationSchema.swift
//  
//
//  Created by Juan Pablo Civile on 04/01/2019.
//

import Foundation

private let basePath = "m/schema:1'/recovery:1'"

enum DerivationSchema {

    case base
    case change
    case external
    case contacts
    case metadata

    var path: String {

        switch self {
        case .base:
            return basePath
        case .change:
            return "\(basePath)/change:0"
        case .external:
            return "\(basePath)/external:1"
        case .contacts:
            return "\(basePath)/contacts:2"
        case .metadata:
            return "\(basePath)/metadata:3"
        }
    }
}
