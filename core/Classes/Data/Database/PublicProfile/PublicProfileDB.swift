//
//  PublicProfileDB.swift
//  falcon
//
//  Created by Manu Herrera on 07/11/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import GRDB

struct PublicProfileDB: Codable, FetchableRecord, PersistableRecord {

    typealias PrimaryKeyType = Int

    let id: Int
    let firstName: String
    let lastName: String
    let profilePictureUrl: String?

}

extension PublicProfileDB: DatabaseModelConvertible {

    init(from: PublicProfile) {
        self.init(id: from.userId,
                  firstName: from.firstName,
                  lastName: from.lastName,
                  profilePictureUrl: from.profilePictureUrl)
    }

    func to(using db: Database) throws -> PublicProfile {
        return PublicProfile(userId: id,
                             firstName: firstName,
                             lastName: lastName,
                             profilePictureUrl: profilePictureUrl)
    }

}
