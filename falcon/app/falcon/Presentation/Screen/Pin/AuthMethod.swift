//
//  AuthMethod.swift
//  Muun
//
//  Created by Lucas Serruya on 13/09/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import Foundation

enum AuthMethod: String {
    case biometrics
    case pin

    func getName() -> String {
        return self.rawValue
    }
}
