//
//  ICloudHelper.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 13/11/2020.
//

import Foundation

public enum ICloudHelper {

    enum Errors: Error {
        case ubiquityContainerIdentifierNotFound
    }

    fileprivate static func getOrCreateFolder(completion: @escaping (URL?, Error?) -> Void) {
        let manager = FileManager.default

        if let documentUrl = manager.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            do {
                // If the directory already exists, the `withIntermediateDirectories: true` succeeds anyway
                try manager.createDirectory(at: documentUrl, withIntermediateDirectories: true, attributes: nil)
                completion(documentUrl, nil)
            } catch {
                completion(nil, error)
            }
        } else {
            completion(nil, MuunError(Errors.ubiquityContainerIdentifierNotFound))
        }
    }

    public static func uploadEK(
        emergencyKitUrl: URL,
        fileName: String,
        completion: @escaping (URL?, Error?) -> Void) {
        let manager = FileManager.default

        getOrCreateFolder { folder, err in
            guard err == nil, let folder = folder else {
                completion(nil, err)
                return
            }

            let icloudUrl = folder.appendingPathComponent(fileName)
            do {
                if manager.fileExists(atPath: icloudUrl.path) {
                    try manager.removeItem(at: icloudUrl)
                }
                try manager.setUbiquitous(true, itemAt: emergencyKitUrl, destinationURL: icloudUrl)

                completion(icloudUrl, nil)
            } catch {
                completion(nil, error)
            }
        }

    }
}
