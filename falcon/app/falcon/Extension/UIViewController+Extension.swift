//
//  UIViewController+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 14/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit
import core

// Analytics
extension UIViewController {

    @objc func customLoggingParameters() -> [String: Any]? {
        // Override this variable if you want to log an screen with custom parameters
        return nil
    }

    @objc var screenLoggingName: String {
        // Override this variable if you want to log an screen with custom parameters
        fatalError("This var must be overritten")
    }

    func logScreen() {
        AnalyticsHelper.logScreen(screenLoggingName, parameters: customLoggingParameters())
    }

    func logScreen(_ name: String) {
        AnalyticsHelper.logScreen(name, parameters: customLoggingParameters())
    }

    func logScreen(_ name: String, parameters: [String: Any]?) {
        AnalyticsHelper.logScreen(name, parameters: parameters)
    }

    func logEvent(_ event: String, parameters: [String: Any]? = nil) {
        AnalyticsHelper.logEvent(event, parameters: parameters)
    }

}

// Keyboard
extension UIViewController {

    func getKeyboardSize(_ notification: NSNotification) -> CGRect? {
        return (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

}
