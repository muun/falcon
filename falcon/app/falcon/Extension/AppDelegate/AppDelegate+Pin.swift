//
//  AppDelegate+Pin.swift
//  falcon
//
//  Created by Manu Herrera on 02/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import UIKit

extension AppDelegate {

    internal func isDisplayingPin() -> Bool {
        if let window = pinWindow, window.isKeyWindow {
            return true
        }
        return navController.viewControllers.contains(where: { return $0 is PinViewController })
    }

    internal func presentLockWindow() {
        let pinController = PinViewController(state: .locked, lockDelegate: self)
        lockNavController = UINavigationController(rootViewController: pinController)

        pinWindow = UIWindow(frame: UIScreen.main.bounds)
        pinWindow!.rootViewController = lockNavController
        pinWindow!.makeKeyAndVisible()
        pinWindow!.accessibilityViewIsModal = true

        lockManager.isShowingLockScreen = true
    }

}

extension AppDelegate: LockDelegate {

    public func unlockApp() {
        dismissPinWindow()

        if let unhandledVisualNotification = unhandledVisualNotification {
            // Adding some magic time to smooth the animations.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.displayVisualNotificationFlow(unhandledVisualNotification)
            }
        }

        lockManager.isShowingLockScreen = false
    }

    internal func logOut() {
        lockManager.wipeDataAndLogOut()

        resetWindowToLogOut()
        dismissPinWindow()

        lockManager.isShowingLockScreen = false
    }

    fileprivate func resetWindowToLogOut() {
        navController.setViewControllers([LogOutViewController()], animated: true)
        _window!.rootViewController = navController
        _window!.makeKeyAndVisible()
    }

    fileprivate func dismissPinWindow() {
        self.pinWindow?.removeFromSuperview()
        self.pinWindow?.resignKey()
        self.pinWindow = nil
        self.window?.makeKeyAndVisible()
    }
}
