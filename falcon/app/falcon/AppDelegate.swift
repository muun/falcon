//
//  AppDelegate.swift
//  falcon
//
//  Created by Manu Herrera on 09/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import UIKit

import Libwallet
import os
import DeviceCheck

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var _window: UIWindow?
    internal var pinWindow: UIWindow?

    internal let navController = UINavigationController()
    internal var lockNavController = UINavigationController()
    internal var tabBarController = UITabBarController()

    internal var blurEffectView = UIVisualEffectView()

    internal let lockManager: ApplicationLockManager = resolve()
    internal let notificationProcessor: NotificationProcessor = resolve()
    internal let houstonService: HoustonService = resolve()
    internal var unhandledVisualNotification: [AnyHashable: Any]?
    internal let preferences: Preferences = resolve()
    fileprivate let taskRunner: TaskRunner = resolve()
    internal let sessionActions: SessionActions = resolve()
    internal let fcmTokenAction: FCMTokenAction = resolve()
    internal let userRepository: UserRepository = resolve()
    internal let operationMetadataDecrypter: OperationMetadataDecrypter = resolve()
    internal let apiMigrationsManager: ApiMigrationsManager = resolve()
    private let deviceCheckTokenProvider: DeviceCheckTokenProvider = resolve()
    private let reachabilityService: ReachabilityService = resolve()
    internal let databaseCoordinator: DatabaseCoordinator = resolve()

    internal let conectivityCapabilitiesProvider: ConectivityCapabilitiesProvider = resolve()
    internal let storeKitCapabilitiesProvider: StoreKitCapabilitiesProvider = resolve()
    internal let appinfoProvider: AppInfoProvider = resolve()
    internal let keychainRepository: KeychainRepository = resolve()
    var debugModeDisplayer: DebugModeDisplayer?
    private let backgroundTimesProcessor: BackgroundTimesProcessor = resolve()
    internal let gcmMessageIDKey = "gcm.message_id"
    // Used in firebase extension
    var fcmTokenHandlingAlreadyReported = false

    internal let featureFlagsRepository: FeatureFlagsRepository = resolve()
    private let preloadFeeDataAction: PreloadFeeDataAction = resolve()
    private let feeDataSyncer: FeeDataSyncer = resolve()
    internal let httpClientSessionProvider: HttpClientSessionProvider = resolve()
    internal let nfcSession: NfcSession = resolve()
    internal let keyProvider: KeyProvider = resolve()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        configureLibwallet()
        do {
            _ = try doWithError { error in
                Libwallet_initStartServer(error)
            }
        } catch {
            Logger.log(.err,
                       "Error initializing libwallet server: \(error.localizedDescription)")
        }
        // Run this as early as possible to load schema and migrations and crash early
        databaseCoordinator.migrate()

        wipeDataForTests()
        disableAnimationsForTests()
        configureRxForErrorHandling()

        #if DEBUG
        // Avoid starting app flows when we're in a test case
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return true }
        #endif

        configureFirebase()
        conectivityCapabilitiesProvider.startMonitoring()
        storeKitCapabilitiesProvider.start()
        appinfoProvider.start()
        deviceCheckTokenProvider.start()
        if sessionActions.isFirstLaunch() {
            lockManager.firstLaunch()
        }

        registerUserData()
        generateDeviceToken()
        checkEnvironment()

        DeviceUtils.appState = application.applicationState

        if application.applicationState != .background {
            setInitialWindow()
        }

        checkIfAppWasOpenByNotification(launchOptions)

        setupDebugModeIfNeeded()
        backgroundTimesProcessor.onEnterForeground()

        return true
    }

    var window: UIWindow? {
        get {
            if _window == nil {
                os_log("Noti debug -Initializing window")
                setInitialWindow()
            }

            return _window
        }
        set {
            _window = newValue
        }
    }

    func generateDeviceToken() {
        // Always store a fallback token in case we can't generate the real one
        let fallbackDeviceTokenKey = KeychainRepository.storedKeys.fallbackDeviceToken.rawValue
        do {
            if (!(try keychainRepository.has(fallbackDeviceTokenKey))) {
                try keychainRepository.store(
                    SecureRandom.randomBytes(count: 32).toHexString(),
                    at: fallbackDeviceTokenKey
                )
            }
        } catch {
            Logger.log(error: error)
        }

        let deviceTokenKey = KeychainRepository.storedKeys.deviceCheckToken.rawValue
        // swiftlint:disable force_error_handling
        let deviceToken = try? keychainRepository.get(deviceTokenKey)
        if deviceToken != nil
            && deviceToken != DeviceTokenErrorValues.failToRetrieve.rawValue
            && deviceToken != DeviceTokenErrorValues.unsupported.rawValue {
            return
        }

        if DCDevice.current.isSupported {
            DCDevice.current.generateToken { token, error in
                do {
                    guard let deviceToken = token, error == nil else {
                        error.map { Logger.log(error: $0) }
                        try self.keychainRepository.store(
                            DeviceTokenErrorValues.failToRetrieve.rawValue,
                            at: deviceTokenKey
                        )
                        self.reachabilityService.collectReachabilityStatusIfNeeded()
                        return
                    }
                    try self.keychainRepository.store(deviceToken.base64EncodedString(),
                                                      at: deviceTokenKey)
                } catch {
                    Logger.log(error: error)
                }
            }
        } else {
            do {
                try keychainRepository.store(DeviceTokenErrorValues.unsupported.rawValue,
                                             at: deviceTokenKey)
            } catch {
                Logger.log(error: error)
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        DeviceUtils.appState = application.applicationState

        // To avoid bugs, this has to be called before .appInForeground is set.
        // The HomePresenter triggers the NotificationProcessor when
        // .appInForeground is set to true.
        feeDataSyncer.appDidBecomeActive()

        preferences.set(value: true, forKey: .appInForeground)
        blurEffectView.removeFromSuperview()

        // Sync notifications in case anything happened while we slept
        if sessionActions.isLoggedIn() {
            runWhenNotTesting(taskRunner.run())
        }

        clearNotifications()

        AnalyticsHelper.logEvent("app_did_become_active")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        preferences.set(value: false, forKey: .appInForeground)
        blurApp()

        lockManager.appWillResignActive()
        feeDataSyncer.appWillResignActive()

        DeviceUtils.appState = application.applicationState
        AnalyticsHelper.logEvent("app_will_go_to_background")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if lockManager.shouldShowLockScreen() {
            presentLockWindow()
            // If we're entering from background and we'll not show lock scren then we show
            // notificationFlow
        } else if let unhandledVisualNotification = unhandledVisualNotification {
            displayVisualNotificationFlow(unhandledVisualNotification)
        }

        blurEffectView.removeFromSuperview()

        DeviceUtils.appState = application.applicationState
        AnalyticsHelper.logEvent("app_will_enter_foreground")
        deviceCheckTokenProvider.reactToForegroundAppState()
        backgroundTimesProcessor.onEnterForeground()

        if sessionActions.isLoggedIn() {
            preloadFeeDataAction.run(refreshPolicy: .foreground)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        DeviceUtils.appState = application.applicationState
        AnalyticsHelper.logEvent("app_will_terminate")
        Libwallet_initStopServer()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        DeviceUtils.appState = application.applicationState
        backgroundTimesProcessor.onEnterBackground()
    }

    func getRootNavigationControllerOnMainWindow() -> UINavigationController? {
        // Since we might be presenting the PIN, we don't want active. We want the first.
        let rootController = window?.rootViewController

        if let rootNav = rootController as? UINavigationController {
            return rootNav
        }

        if let rootNav = rootController as? UITabBarController {
            if let rootNav = rootNav.selectedViewController as? UINavigationController {
                return rootNav
            }
        }

        let rootControllerDesc = String(describing: rootController)
        Logger.log(
            .err,
            "failed to find a nav controller to open a URI: root \(rootControllerDesc)"
        )
        return nil
    }

    // Deep/Universal links
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:] ) -> Bool {

        // TODO: Check if we need to handle google sign in deeplinks as well

        guard userRepository.getUser() != nil else {
            // If user is nil then there is nothing to do
            return false
        }

        do {
            let paymentIntent = try AddressHelper.parse(url.absoluteString)

            guard let navController = getRootNavigationControllerOnMainWindow() else {
                return false
            }

            switch paymentIntent {
            case .lnurlWithdraw(let lnurl):
                navController.pushViewController(
                    LNURLWithdrawViewController(qr: lnurl),
                    animated: true
                )
            default:
                navController.pushViewController(
                    NewOperationViewController(
                        paymentIntent: paymentIntent,
                        origin: .externalLink
                    ),
                    animated: true
                )
            }

            return true
        } catch {
            Logger.log(.warn, "received invalid URL for open \(url)")
            return false
        }
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return false
        }

        if !components.path.contains("authorize")
            && !components.path.contains("verify")
            && !components.path.contains("confirm") {
            return false
        }

        var uuid: String?
        if let queryItems = components.queryItems {
            for item in queryItems where item.name == "uuid" {
                uuid = item.value
            }
        }

        guard let verificationUuid = uuid else {
            return false
        }

        // Use the first window to avoid hitting the pin lock screen if the users been gone of the
        // app for a while
        let rootViewController = UIApplication.shared.windows[0].rootViewController
        let topViewController = UIApplication.topViewController(base: rootViewController)

        if components.path.contains("confirm") {
            // Check for change password
            if let vc = topViewController as? ChangePasswordVerifyViewController {
                vc.runVerification(uuid: verificationUuid)
            }
        } else if let vc = topViewController as? SignInAuthorizeEmailViewController {
            // Check for sign in
            vc.runVerification(uuid: verificationUuid)
        } else if let vc = topViewController as? SignUpVerifyEmailViewController {
            // Check for create wallet
            vc.runVerification(uuid: verificationUuid)
        } else if let vc = topViewController as? SignInWithRCVerifyEmailViewController {
            // Check for sign in with rc flow
            vc.runVerification(uuid: verificationUuid)
        } else {
            return false
        }

        return true
    }

    // Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken: Data) {

        setApnsToken(deviceToken)

        // 1. Convert device token to string
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        // 2. Print device token to use for PNs payloads
        Logger.log(.info, "Device Token: \(token)")
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        handle(notification: userInfo, completionHandler: completionHandler)
    }

    // Force Touch
    func application(_ application: UIApplication,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: (Bool) -> Void) {
        completionHandler(handleShortcut(application, item: shortcutItem))
    }

}
