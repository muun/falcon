//
//  SecureKeyValueStorageGroup.swift
//  Muun
//

class SecureKeyValueStorageGroup: BaseDebugExecutablesGroup {
    init() {
        let showSecureKeyValueStorage = ShowSecureKeyValueStorageDebugExecutable()

        super.init(
            category: "SecureKeyValueStorage",
            executables: [
                showSecureKeyValueStorage
            ]
        )
    }
}
