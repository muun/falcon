//
//  String+Extension.swift
//  core
//
//  Created by Juan Pablo Civile on 30/05/2019.
//

import Foundation

extension String {

    public var stringBytes: [UInt8] {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }

}
