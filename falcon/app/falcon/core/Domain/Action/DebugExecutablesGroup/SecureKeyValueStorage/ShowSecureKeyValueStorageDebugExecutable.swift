//
//  ShowSecureKeyValueStorageDebugExecutable.swift
//  Muun
//

import Foundation

class ShowSecureKeyValueStorageDebugExecutable: DebugExecutable {
    func execute(context: DebugMenuExecutableContext, completion: @escaping () -> Void) {
        context.showSecureKeyValueStorage()
        completion()
    }

    func getTitleForCell() -> String {
        return "Open SecureKeyValueStorage debug screen"
    }
}
