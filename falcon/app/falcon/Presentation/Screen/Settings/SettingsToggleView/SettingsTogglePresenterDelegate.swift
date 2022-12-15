//
//  SettingsTogglePresenterDelegate.swift
//  Muun
//
//  Created by Lucas Serruya on 13/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

protocol SettingsTogglePresenterDelegate: BasePresenterDelegate {
    func showAlert(data: SettingsToggleAlertData)

    var enabled: Bool { get set }
    var loading: Bool { get set }
}
