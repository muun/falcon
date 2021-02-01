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

        lockManager.isShowingLockScreen = true
    }

}

extension AppDelegate: LockDelegate {

    public func unlockApp() {
        dismissPinWindow()

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
        UIView.animate(withDuration: 0.3, animations: {
            self.pinWindow?.alpha = 0
        }, completion: { _ in
            self.lockNavController.dismiss(animated: true, completion: nil)
            self.window?.makeKeyAndVisible()
        })
    }

}
