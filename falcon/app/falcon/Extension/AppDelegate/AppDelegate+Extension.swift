//
//  AppDelegate+Extension.swift
//  falcon
//
//  Created by Manu Herrera on 02/05/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import RxSwift
import core
import Libwallet

extension AppDelegate {

    internal func wipeDataForTests() {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            lockManager.wipeDataAndLogOut()
        }
        #endif
    }

    internal func disableAnimationsForTests() {
        #if DEBUG
        if ProcessInfo().arguments.contains("testMode") {
            UIView.setAnimationsEnabled(false)
        }
        #endif
    }

    internal func configureRxForErrorHandling() {
        Hooks.recordCallStackOnError = true
        Hooks.defaultErrorHandler = { (_, err: Error) in
            Logger.log(error: err)
        }
    }

    internal func setInitialWindow() {
        _window = UIWindow(frame: UIScreen.main.bounds)
        _window!.backgroundColor = Asset.Colors.background.color

        var initialVC: UIViewController?

        if sessionActions.isLoggedIn() {
            // The user tapped on create wallet and then killed the app. We're recovering for that
            // situation. We have to create a new pin for the user.
            if lockManager.shouldStartSetUpPinFlow() && !isDisplayingPin() {
                initialVC = PinViewController(state: .choosePin, isExistingUser: true)
                lockManager.isShowingLockScreen = true
            } else {
                if let syncStatus = preferences.string(forKey: .syncStatus), syncStatus == "failed" {
                    initialVC = SyncViewController(
                        existingUser: true,
                        shouldRunSyncAction: true
                    )
                } else {
                    preferences.set(value: "success", forKey: .syncStatus)

                    if apiMigrationsManager.hasPending() {
                        initialVC = ApiMigrationsViewController()
                    } else {
                    	initialVC = nil // We will use a the tab bar in this case
                    }
                }
            }
        } else {
            initialVC = GetStartedViewController()
        }

        if let initialVC = initialVC {
            navController.setViewControllers([initialVC], animated: true)
            _window!.rootViewController = navController
        } else {
            _window!.rootViewController = MuunTabBarController()
        }

        // User already has a pin but has to show the pin due to security reasons.
        if lockManager.shouldShowLockScreen() {
            presentLockWindow()
        } else if !lockManager.isShowingLockScreen {
            // When opening the app from a push notification, if the app is killed, the first method to run
            // is willEnterForeground, which makes the pinWindow visible. Then, didFinishLaunchWithOptions
            // runs, making the mainWindow visible and overlapping the pinWindow. This code avoids that
            // issue.
            _window?.makeKeyAndVisible()
            if let unhandledVisualNotification = unhandledVisualNotification {
                // Everything went well, we're not displaying lock screen
                displayVisualNotificationFlow(unhandledVisualNotification)
            }
        } else if pinWindow?.isKeyWindow != true {
            // In this case lockManager.isShowingLockScreen is true because pinView is being
            // displayed over mainWindow. We're recovering a user who tapped in create wallet and
            // then killed the app.
            _window?.makeKeyAndVisible()
        }
    }

    // Use this method when a user logs out completly.
    // We want to do this to avoid keeping the tab bar in the stack.
    func resetWindowToGetStarted() {
        navController.setViewControllers([GetStartedViewController()], animated: true)
        _window!.rootViewController = navController
        _window!.makeKeyAndVisible()
    }

    fileprivate func setAnalyticsProperties(_ user: User?) {
        if let user = user {
            let userId = String(describing: user.id)
            AnalyticsHelper.setCrashlyticsUserId(userId)
            AnalyticsHelper.setUserProperty(id: userId)
            AnalyticsHelper.setUserProperty(user.unsafeGetPrimaryCurrency(), forName: "currency")
        } else {
            AnalyticsHelper.setCrashlyticsUserId(nil)
            AnalyticsHelper.setUserProperty(id: nil)
        }
    }

    internal func registerUserData() {
        _ = userRepository.watchUser()
            .subscribe(onNext: { user in
                #if !DEBUG
                self.setAnalyticsProperties(user)
                #else
                // silence the linter
                _ = user
                #endif

            }, onError: { error in
                Logger.log(error: error)
            })
    }

    internal func blurApp() {
        guard let window = self.window else {
            return
        }
        if !self.blurEffectView.isDescendant(of: window) {
            let blurEffect = UIBlurEffect(style: .light)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = window.bounds

            window.addSubview(self.blurEffectView)

            blurEffectView.alpha = 0
            UIView.animate(withDuration: 0.5) {
                self.blurEffectView.alpha = 1
            }
        }
    }

    internal func checkEnvironment() {
        let currentEnvironment = Environment.current.rawValue
        guard let previousEnvironment = preferences.string(forKey: .currentEnvironment) else {
            preferences.set(value: currentEnvironment, forKey: .currentEnvironment)
            return
        }

        if previousEnvironment != currentEnvironment {
            let alert = UIAlertController(
                title: "Uninstall the app",
                message: "You changed the environment, that will cause bugs with the notifications",
                preferredStyle: .alert
            )

            navController.present(alert, animated: true)

            preferences.set(value: currentEnvironment, forKey: .currentEnvironment)
        }
    }

    internal func configureLibwallet() {
        LibwalletStorageHelper.ensureExists()

        let libwalletConfig = LibwalletConfig()
        libwalletConfig.dataDir = Environment.current.libwalletDataDirectory.absoluteString

        LibwalletInit(libwalletConfig)
    }

}

// Force touch stuff
extension AppDelegate {

    internal func handleShortcut(_ application: UIApplication, item: UIApplicationShortcutItem) -> Bool {
        guard let shortcutIdentifier = ShortcutIdentifier(fullIdentifier: item.type) else {
            return false
        }

        if userRepository.getUser() == nil {
            return false
        }

        guard let navController = getRootNavigationControllerOnMainWindow() else {
            return false
        }

        switch shortcutIdentifier {
        case .receiveMoney:
            navController.pushViewController(ReceiveViewController(origin: .forcePush), animated: true)
        case .sendMoney:
            navController.pushViewController(ScanQRViewController(), animated: true)
        }
        return true
    }

}
