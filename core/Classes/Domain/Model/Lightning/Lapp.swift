//
//  Lapp.swift
//  falcon
//
//  Created by Manu Herrera on 25/04/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

public struct Lapp: Codable {
    public let name: String
    public let description: String
    public let image: String
    public let link: String

    public init(name: String, description: String, image: String, link: String) {
        self.name = name
        self.description = description
        self.image = image
        self.link = link
    }
}
