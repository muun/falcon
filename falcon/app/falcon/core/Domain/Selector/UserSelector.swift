//
//  UserSelector.swift
//  falcon
//
//  Created by Juan Pablo Civile on 19/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

public class UserSelector: BaseOptionalSelector<User> {

    init(userRepository: UserRepository) {
        super.init(userRepository.watchUser)
    }

}
