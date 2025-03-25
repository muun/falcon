//
//  ICloudHelper.swift
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
        user: User,
        kitVersion: Int,
        completion: @escaping (URL?, Error?) -> Void) {
        let manager = FileManager.default

        getOrCreateFolder { folder, err in
            guard err == nil, let folder = folder else {
                completion(nil, err)
                return
            }

            // Remember: ubiquity container contents can only be manipulated via URL-taking APIs. String based ones
            // fail 100% of the time.
            let icloudUrl = folder.appendingPathComponent(fileName)
            do {
                if manager.isUbiquitousItem(at: icloudUrl) {
                    try manager.replaceItem(at: icloudUrl, withItemAt: emergencyKitUrl, backupItemName: fileName+".bak", resultingItemURL: nil)
                } else {
                    try manager.setUbiquitous(true, itemAt: emergencyKitUrl, destinationURL: icloudUrl)
                }
                try icloudUrl.setExtendedAttribute(
                    data: CloudConstants.userToKitId(user: user).data(using: .utf8)!,
                    forName: toXattrKey(CloudConstants.userProperty)
                )
                try icloudUrl.setExtendedAttribute(
                    data: "\(kitVersion)".data(using: .utf8)!,
                    forName: toXattrKey(CloudConstants.versionProperty)
                )

                completion(icloudUrl, nil)
            } catch {
                completion(nil, error)
            }
        }

    }

    fileprivate static func toXattrKey(_ name: String) -> String {
        // The #S makes the attribute syncable
        // https://eclecticlight.co/2019/07/23/how-to-save-file-metadata-in-icloud-and-new-info-on-extended-attributes/
        "com.muun.falcon.\(name)#S"
    }
}
