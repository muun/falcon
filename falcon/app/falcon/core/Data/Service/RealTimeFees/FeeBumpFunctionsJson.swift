//
//  FeeBumpFunctionsJson.swift
//  Muun
//
//  Created by Daniel Mankowski on 07/01/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

struct FeeBumpFunctionsJson: Codable {

    let uuid: String
    // Each fee bump functions is codified as a base64 string.
    let functions: [String]
}
