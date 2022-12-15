//
//  SettingsTogglePresenter.swift
//  Muun
//
//  Created by Lucas Serruya on 13/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

import Foundation

protocol SettingsTogglePresenter: AnyObject {
    func onToggleTapped()
    func setUp()
    func tearDown()
}
