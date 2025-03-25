//
//  ReceiveFormatPreference.swift
//
//  Created by Lucas Serruya on 22/11/2022.
//

import Foundation

public enum ReceiveFormatPreference: String, Codable {
    case ONCHAIN
    case LIGHTNING
    case UNIFIED
}
