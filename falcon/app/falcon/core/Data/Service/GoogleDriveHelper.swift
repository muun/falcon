//
//  GoogleDriveHelper.swift
//  Created by Manu Herrera on 13/11/2020.
//

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher
import CryptoKit
import Libwallet

public enum GoogleDriveHelper {

    enum Errors: Error {
        case noFolder
    }

    fileprivate static let mimeTypePdf = "application/pdf"

    public static func uploadEK(
        googleUser: GIDGoogleUser,
        emergencyKitUrl: URL,
        fileName: String,
        user: User,
        kitVersion: Int,
        completion: @escaping (String?, Error?) -> Void
    ) {

        let cloudStorageFolderName = "Muun"
        let service = GTLRDriveService()

        service.authorizer = googleUser.fetcherAuthorizer

        getOrCreateFolderID(
            name: cloudStorageFolderName,
            service: service,
            user: googleUser
        ) { (folderId, folderLink, err) in

            if err != nil {
                Logger.log(.info, err.debugDescription)
                completion(nil, err)
                return
            }

            guard let folderId = folderId else {
                completion(nil, MuunError(Errors.noFolder))
                return
            }

            findExistingKit(
                name: fileName,
                folderId: folderId,
                user: user,
                googleUser: googleUser,
                service: service
            ) { existingKit, error in

                let uploadParameters = GTLRUploadParameters(fileURL: emergencyKitUrl, mimeType: mimeTypePdf)

                let file = GTLRDrive_File()
                let userId = CloudConstants.userToKitId(user: user)

                // Ensure the properties are up to date
                file.appProperties = GTLRDrive_File_AppProperties()
                file.appProperties?.setAdditionalProperty("\(kitVersion)", forName: CloudConstants.versionProperty)
                file.appProperties?.setAdditionalProperty(userId, forName: CloudConstants.userProperty)
                
                let query: GTLRDriveQuery
                if let existingKit = existingKit,
                   let id = existingKit.identifier {

                    // Pin the existing revision just in case we're overwriting another wallet
                    if existingKit.appProperties?.additionalProperty(forName: CloudConstants.userProperty) as? String != userId,
                       let revisionId = existingKit.headRevisionId {

                        let revision = GTLRDrive_Revision()
                        revision.keepForever = true
                        let pinQuery = GTLRDriveQuery_RevisionsUpdate.query(
                            withObject: revision,
                            fileId: id,
                            revisionId: revisionId
                        )

                        service.executeQuery(pinQuery) { _, _, _ in
                        }
                    }

                    query = GTLRDriveQuery_FilesUpdate.query(
                        withObject: file,
                        fileId: id,
                        uploadParameters: uploadParameters
                    )

                } else {

                    file.name = fileName
                    file.parents = [folderId]

                    query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)
                }

                service.executeQuery(query) { (_, _, error) in
                    completion(folderLink ?? "", error)
                }
            }

        }

    }

    private static func getOrCreateFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?, String?, Error?) -> Void) {

        getFolderID(name: name, service: service, user: user) { folderID, folderLink, err in
            if err != nil {
                completion(nil, nil, err)
                return
            }

            if folderID == nil {
                self.createFolder(name: name, service: service, completion: completion)
            } else {
                // Folder already exists
                completion(folderID, folderLink, nil)
            }
        }
    }

    private static func findExistingKit(
        name: String,
        folderId: String,
        user: User,
        googleUser: GIDGoogleUser,
        service: GTLRDriveService,
        completion: @escaping (GTLRDrive_File?, Error?) -> Void
    ) {
        let query = GTLRDriveQuery_FilesList.query()

        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"

        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
        query.fields = "*" // This is important to retreive the link of the document later

        let withName = "name = '\(name)'" // Case insensitive!
        let pdfsOnly = "mimeType = '\(mimeTypePdf)'"
        let ownedByUser = "'\(googleUser.profile!.email)' in owners"
        let insideFolder = "'\(folderId)' in parents"
        query.q = """
                  \(withName) 
                  and \(pdfsOnly) 
                  and \(ownedByUser) 
                  and \(insideFolder)
                  and trashed = false
                  """

        service.executeQuery(query) { (_, result, error) in
            guard error == nil,
                  let result = result as? GTLRDrive_FileList,
                  let files = result.files else {

                completion(nil, error)
                return
            }

            // No files, no kit
            if files.count == 0 {
                completion(nil, nil)
                return
            }

            let kitUserToFind = CloudConstants.userToKitId(user: user)

            // First check for properties matching
            for file in files {
                if let kitUser = file.appProperties?.additionalProperty(forName: CloudConstants.userProperty) as? String {
                    if kitUser == kitUserToFind && file.isAppAuthorized?.boolValue ?? false {
                        completion(file, nil)
                        return
                    }
                }
            }

            // No matches, so we use the 1 file kit heuristic
            // We do however check first that it has no properties. If it has, and it hasn't been selected
            // by the previous for, that means it's not from this wallet.
            if files.count == 1,
               let file = files.first,
               file.appProperties?.additionalProperty(forName: CloudConstants.userProperty) == nil {

                completion(files.first, nil)
                return
            }

            // No exact match
            completion(nil, nil)
        }
    }

    /**
     The method below performs a case-insensitive search for a specified folder by name. If a folder is found, the
     folder’s identifier is passed to the completion handler.
     */
    private static func getFolderID(
        name: String,
        service: GTLRDriveService,
        user: GIDGoogleUser,
        completion: @escaping (String?, String?, Error?) -> Void) {

        let query = GTLRDriveQuery_FilesList.query()

        // Comma-separated list of areas the search applies to. E.g., appDataFolder, photos, drive.
        query.spaces = "drive"

        // Comma-separated list of access levels to search in. Some possible values are "user,allTeamDrives" or "user"
        query.corpora = "user"
        query.fields = "*" // This is important to retreive the link of the document later

        let withName = "name = '\(name)'" // Case insensitive!
        let foldersOnly = "mimeType = 'application/vnd.google-apps.folder'"
        let ownedByUser = "'\(user.profile!.email)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"

        service.executeQuery(query) { (_, result, error) in
            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            if let folderList = result as? GTLRDrive_FileList {
                // For brevity, assumes only one folder is returned.
                completion(folderList.files?.first?.identifier, folderList.files?.first?.webViewLink, nil)
            } else {
                completion(nil, nil, Errors.noFolder)
            }

        }
    }

    // The folder identifier is returned via a completion handler if creation succeeds.
    private static func createFolder(
        name: String,
        service: GTLRDriveService,
        completion: @escaping (String, String?, Error?) -> Void) {

        let folder = GTLRDrive_File()
        folder.mimeType = "application/vnd.google-apps.folder"
        folder.name = name

        // Google Drive folders are files with a special MIME-type.
        let query = GTLRDriveQuery_FilesCreate.query(withObject: folder, uploadParameters: nil)
        query.fields = "*" // This is important to retreive the link of the document later

        service.executeQuery(query) { (ticket, file, error) in
            guard error == nil else {
                completion("", nil, error)
                return
            }

            if let folder = file as? GTLRDrive_File, let id = folder.identifier {
                completion(id, folder.webViewLink, nil)
            } else {
                completion("", nil, MuunError(Errors.noFolder))
            }
        }
    }
}
