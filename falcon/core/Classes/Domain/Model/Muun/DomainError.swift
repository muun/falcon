//
//  DomainError.swift
//  core-all
//
//  Created by Lucas Serruya on 13/09/2023.
//

import Foundation

public enum DomainError: Error {
    case sessionExpiredOnNotificationProcessor
    case emergencyKitExportError
}
