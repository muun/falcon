//
//  UserPreferencesSelector.swift
//  Created by Juan Pablo Civile on 11/12/2020.
//

import Foundation
import RxSwift

public class UserPreferencesSelector: BaseSelector<UserPreferences> {

    init(repository: UserPreferencesRepository) {
        super.init(repository.watch)
    }

}
