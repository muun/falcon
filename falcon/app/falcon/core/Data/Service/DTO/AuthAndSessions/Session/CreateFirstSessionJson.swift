//
//  CreateFirstSessionJson.swift
//
//  Created by Manu Herrera on 24/04/2020.
//

import Foundation

struct CreateFirstSessionJson: Codable {

    let client: ClientJson
    // GcmToken is not retrieved until notification permission approval.
    let gcmToken: String?
    let primaryCurrency: String
    let basePublicKey: PublicKeyJson

}

struct CreateFirstSessionOkJson: Codable {

    let user: User
    let cosigningPublicKey: PublicKeyJson
    let swapServerPublicKey: PublicKeyJson

}

struct ClientJson: Codable {
    let type: String
    let buildType: String
    let version: Int
    let versionName: String
    let deviceModel: String
    let timezoneOffsetInSeconds: Int64
    let language: String
    let deviceCheckToken: String
    let fallbackDeviceToken: String
    let iCloudRecordId: String?
}
