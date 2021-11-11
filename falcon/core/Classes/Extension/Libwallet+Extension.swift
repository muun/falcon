//
//  Libwallet+Extension.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 21/10/2021.
//

import Foundation
import Libwallet

extension Array where Element == String {

    func toLibwallet() -> LibwalletStringList {

        let list = LibwalletStringList()!
        for s in self {
            list.add(s)
        }

        return list
    }

}

extension Array where Element == Int {

    func toLibwallet() -> LibwalletIntList {

        let list = LibwalletIntList()!
        for v in self {
            list.add(v)
        }

        return list
    }
}
