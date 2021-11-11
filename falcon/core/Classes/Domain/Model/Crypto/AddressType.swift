//
//  AddressType.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 22/10/2021.
//

import Foundation

public enum AddressType: String, RawRepresentable, Codable {
    case segwit
    case legacy
    case taproot
}
