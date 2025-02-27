//
//  DebugModeDisplayer.swift
//  Muun
//
//  Created by Lucas Serruya on 16/08/2023.
//  Copyright © 2023 muun. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications

class DebugModeDisplayer {
    private weak var lastKeyWindow: UIWindow?
    private let debugWindow = UIWindow(frame: UIScreen.main.bounds)
    static let deviceShakedNotification = Foundation.Notification.Name(rawValue: "device_shaked_notification")

    func startDebugDisplayerIfDebugBuild() {
        #if !DEBUG
        return
        #endif
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(startListeningKeyWindowChanged),
                                               name: UIWindow.didBecomeKeyNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(launchDebugMenu),
                                               name: DebugModeDisplayer.deviceShakedNotification,
                                               object: nil)

        if let window = UIApplication.shared.keyWindow {
            setEdgePanGestureOn(window: window)
        }
    }

    func onCloseDebugMenuTapped() {
        lastKeyWindow?.makeKeyAndVisible()
    }

    @objc private func startListeningKeyWindowChanged(_ notification: NSNotification) {
        guard let window = notification.object as? UIWindow else {
            return
        }

        setEdgePanGestureOn(window: window)
    }
}

private extension DebugModeDisplayer {
    @objc func onEdgePanDetected() {
        launchDebugMenu()
    }

    @objc func launchDebugMenu() {
        // Many windows can trigger this if they are initialized.
        guard !debugWindow.isKeyWindow else {
            return
        }

        lastKeyWindow = UIApplication.shared.keyWindow

        let debugViewController = DebugMenuViewController(debugModeDisplayer: self)

        let wrapperNavController = UINavigationController(rootViewController: debugViewController)
        debugWindow.rootViewController = wrapperNavController
        debugWindow.makeKeyAndVisible()
    }

    func setEdgePanGestureOn(window: UIWindow) {
        let debugGesture = UIScreenEdgePanGestureRecognizer(target: self,
                                                            action: #selector(onEdgePanDetected))
        debugGesture.edges = .right

        window.addGestureRecognizer(debugGesture)
    }
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        #if DEBUG
        if motion == .motionShake {
            NotificationCenter.default.post(name: DebugModeDisplayer.deviceShakedNotification,
                                            object: nil)
        }
        #endif
     }
}
