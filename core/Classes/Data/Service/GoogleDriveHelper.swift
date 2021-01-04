//
//  GoogleDriveHelper.swift
//  core.root-all-notifications
//
//  Created by Manu Herrera on 13/11/2020.
//

import GoogleSignIn
import GoogleAPIClientForREST
import GTMSessionFetcher

public enum GoogleDriveHelper {

    enum Errors: Error {
        case noFolder
    }

    public static func uploadEK(
        user: GIDGoogleUser,
        emergencyKitUrl: URL,
        fileName: String,
        completion: @escaping (String?, Error?) -> Void) {

        let cloudStorageFolderName = "Muun"
        let service = GTLRDriveService()

        service.authorizer = user.authentication.fetcherAuthorizer()

        getOrCreateFolderID(name: cloudStorageFolderName,
                            service: service,
                            user: user) { (folderId, folderLink, err) in

            if err != nil {
                Logger.log(.info, err.debugDescription)
                completion(nil, err)
            }

            guard let id = folderId else {
                completion(nil, MuunError(Errors.noFolder))
                return
            }

            uploadFile(
                name: fileName,
                folderID: id,
                folderWebViewLink: folderLink ?? "",
                fileURL: emergencyKitUrl,
                mimeType: "application/pdf",
                service: service,
                completion: completion
            )
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
            }

            if folderID == nil {
                self.createFolder(name: name, service: service, completion: completion)
            } else {
                // Folder already exists
                completion(folderID, folderLink, nil)
            }
        }
    }

    private static func uploadFile(
        name: String,
        folderID: String,
        folderWebViewLink: String,
        fileURL: URL,
        mimeType: String,
        service: GTLRDriveService,
        completion: @escaping (String?, Error?) -> Void) {

        let file = GTLRDrive_File()
        file.name = name
        file.parents = [folderID]

        // Optionally, GTLRUploadParameters can also be created with a Data object.
        let uploadParameters = GTLRUploadParameters(fileURL: fileURL, mimeType: mimeType)

        let query = GTLRDriveQuery_FilesCreate.query(withObject: file, uploadParameters: uploadParameters)

        service.uploadProgressBlock = { _, totalBytesUploaded, totalBytesExpectedToUpload in
            // This block is called multiple times during upload and can
            // be used to update a progress indicator visible to the user.
        }

        service.executeQuery(query) { (_, _, error) in
            // Successful upload if no error is returned.
            completion(folderWebViewLink, error)
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
        let ownedByUser = "'\(user.profile!.email!)' in owners"
        query.q = "\(withName) and \(foldersOnly) and \(ownedByUser)"

        service.executeQuery(query) { (ticket, result, error) in
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
