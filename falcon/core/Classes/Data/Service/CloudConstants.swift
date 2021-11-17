//
// Created by Juan Pablo Civile on 17/11/2021.
//

import Foundation
import Libwallet

enum CloudConstants {
    static let userProperty = "muun_user"
    static let versionProperty = "muuk_ek_version"

    static func userToKitId(user: User) -> String {
        return LibwalletSHA256("\(user.id)".data(using: .utf8))!.toHexString()
    }
}
