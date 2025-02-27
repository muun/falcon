//
//  CopyRandomAddressDebugExecutable.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit

class CopyRandomAddressDebugExecutable: DebugExecutable {

    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        let address = TestLapp.getBech32Address()
        UIPasteboard.general.string = address
        completion()
    }

    func getTitleForCell() -> String {
        return "Save random address on clipboard"
    }
}
