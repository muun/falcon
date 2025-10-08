//
//  UserAccountManagementGroup.swift
//  Muun
//
//  Created by Lucas Serruya on 24/04/2025.
//  Copyright © 2025 muun. All rights reserved.
//

import Foundation

class UserAccountManagementGroup: BaseDebugExecutablesGroup {
    init(createVerifiedRcV1Executable: CreateVerifiedRcV1Executable) {
         super.init(category: "User account management", executables:
                     [
                         createVerifiedRcV1Executable
                     ]
         )
     }
}
