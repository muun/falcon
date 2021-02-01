//
//  Profile.swift
//  falcon
//
//  Created by Manu Herrera on 24/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

// This is public for the operation extension
public struct PublicProfileJson: Codable {
    let userId: Int
    public let firstName: String
    let lastName: String
    let profilePictureUrl: String?
}
