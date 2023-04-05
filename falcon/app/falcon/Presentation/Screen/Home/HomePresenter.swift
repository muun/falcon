//
//  HomePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 05/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift
import core
import Libwallet

enum HomeOperationsState {
    case confirmed
    case pending
    case rbf
}

enum HomeCompanion {
    case backUp
    case activateTaproot
    case preactiveTaproot(blocksLeft: UInt)
    case blockClock(blocksLeft: UInt)
    case none
}

protocol HomePresenterDelegate: BasePresenterDelegate {
    func showWelcome()
    func showTaprootActivated()
    func onOperationsChange()
    func onBalanceChange(_ balance: MonetaryAmount)
    func onBalanceVisibilityChange(_ isHidden: Bool)
    func didReceiveNewOperation(amount: MonetaryAmount, direction: OperationDirection)
    func onCompanionChange(_ companion: HomeCompanion)
}

class HomePresenter<Delegate: HomePresenterDelegate>: BasePresenter<Delegate> {

    private let operationActions: OperationActions
    private let balanceActions: BalanceActions
    private let realTimeDataAction: RealTimeDataAction
    private let preferences: Preferences
    private let userPreferencesSelector: UserPreferencesSelector
    private let updateUserPreferencesAction: UpdateUserPreferencesAction
    private let sessionActions: SessionActions
    internal let fetchNotificationsAction: FetchNotificationsAction
    private let userActivatedFeatureSelector: UserActivatedFeaturesSelector
    private var balance: MonetaryAmount = MonetaryAmount(amount: 0, currency: "BTC")

    private var numberOfOperations: Int?

    init(delegate: Delegate,
         operationActions: OperationActions,
         balanceActions: BalanceActions,
         realTimeDataAction: RealTimeDataAction,
         sessionActions: SessionActions,
         preferences: Preferences,
         userPreferencesSelector: UserPreferencesSelector,
         updateUserPreferencesAction: UpdateUserPreferencesAction,
         fetchNotificationsAction: FetchNotificationsAction,
         userActivatedFeatureSelector: UserActivatedFeaturesSelector) {

        self.operationActions = operationActions
        self.balanceActions = balanceActions
        self.realTimeDataAction = realTimeDataAction
        self.sessionActions = sessionActions
        self.preferences = preferences
        self.userPreferencesSelector = userPreferencesSelector
        self.updateUserPreferencesAction = updateUserPreferencesAction
        self.fetchNotificationsAction = fetchNotificationsAction
        self.userActivatedFeatureSelector = userActivatedFeatureSelector

        super.init(delegate: delegate)
    }

    override func setUp() {
        super.setUp()

        subscribeTo(watchAppState(), onNext: self.onAppStateChange)
        subscribeTo(realTimeDataAction.getState(), onNext: self.handleRealTimeDataAction)
        subscribeTo(operationActions.getOperationsChange(), onNext: self.onOperationsChange)
        subscribeTo(balanceActions.watchBalance(), onNext: self.onBalanceChange)
        subscribeTo(fetchNotificationsAction.getState(), onNext: { _ in })

        let taproot = Libwallet.userActivatedFeatureTaproot()!
        subscribeTo(
                Observable.combineLatest(sessionActions.watchUser(), userActivatedFeatureSelector.watch(for: taproot))
        ) { [self] (_, taprootStatus) in

            if case .active = taprootStatus,
               preferences.bool(forKey: .preactivedTaproot) {

                preferences.set(value: false, forKey: .preactivedTaproot)
                delegate.showTaprootActivated()

            } else if case .preactivated = taprootStatus {
                // FIXME: delete me, this is a nasty hack

                preferences.set(value: true, forKey: .preactivedTaproot)
            }

            delegate.onCompanionChange(decideCompanion(taprootStatus: taprootStatus))
        }

        decidePollNotificationsPolicy()

        if shouldDisplayWelcomeMessage() {
            delegate.showWelcome()
            setWelcomeMessageSeen()
        }
    }

    private func decidePollNotificationsPolicy() {
        // Since users can enable and disable push notifications as they want, we need a way to ensure
        // that the notifications from the backend gets processed.
        // This method schedules a call to the fetchNotifications endpoint every N seconds.
        // With N variable over some conditions (described below, see `buildPeriodicAction` method)

        #if targetEnvironment(simulator)
        // We are OK with polling every 10 seconds on simulator builds
        let simulatorFetch: Observable<Int> = buildFetchNotificationsPeriodicAction(intervalInSeconds: 10)
        self.subscribeTo(simulatorFetch, onNext: { _ in })
        return
        #endif

        PushNotificationsHelper.getPushNotificationAuthorizationStatus { (status) in
            let periodicFetch: Observable<Int>

            switch status {
            case .authorized, .ephemeral, .provisional:
                periodicFetch = self.buildPeriodicAction(isPermissionEnabled: true)
            case .denied, .notDetermined:
                periodicFetch = self.buildPeriodicAction(isPermissionEnabled: false)
            }

            self.subscribeTo(periodicFetch, onNext: { _ in })
        }
    }

    private func buildPeriodicAction(isPermissionEnabled: Bool) -> Observable<Int> {

        return operationActions.getOperationsChange().flatMap({ _ -> Observable<Int> in
            if self.operationActions.hasPendingSwaps() {
                // If we have push notification permissions enabled, we'll only poll to get updates on unconfirmed
                // 0-conf swaps.
                return Observable.just(10)

             } else if !isPermissionEnabled {
                // If we don't have push notification permissions enabled, we'll poll every:
                // * 30 seconds if we have pending transactions,
                // * 60 seconds if we don't.
                let hasPendingOps = self.operationActions.hasPendingOperations()
                let secondsForPolling = hasPendingOps ? 30 : 60

                return Observable.just(secondsForPolling)

             } else {
                return Observable.empty() // nothing to poll!
            }
        })
        .flatMap({ seconds in
            self.buildFetchNotificationsPeriodicAction(intervalInSeconds: seconds)
        })

    }

    private func onAppStateChange(_ result: Bool?) {
        // This method is going to be called:
        // 1. on every home view will appear with result = true
        // 2. every time the app goes to background from the home with result = false
        // 3. every time the app enter foreground in the home with result = true

        if let isInForeground = result, isInForeground {
            // We want to call these actions if we are on foreground (see points 1 and 3)
            realTimeDataAction.run()
            fetchNotificationsAction.run()
        }
    }

    private func handleRealTimeDataAction(_ result: ActionState<RealTimeData>) {
        switch result.type {
        case .EMPTY, .LOADING, .VALUE: break
            // We dont need to do anything on this states
        case .ERROR:
            guard let error = result.getError() else {
                Logger.log(.err, "didnt have an error value")
                return
            }
            handleError(error)
        }
    }

    private func onOperationsChange(_ change: core.OperationsChange) {
        guard areThereVisualChangesToApply(change: change) else {
            return
        }

        // Whenever the operations change, we check if there has been any new operation (incoming or outgoing)
        // to display a component in the homescreen indicating the money diff in BTC
        if let ops = numberOfOperations,
           change.numberOfOperations > ops,
           let newOp = change.lastOperation {

            delegate.didReceiveNewOperation(
                amount: diffAmount(newOp),
                direction: newOp.direction
            )
        }

        numberOfOperations = change.numberOfOperations

        delegate.onOperationsChange()
    }

    private func areThereVisualChangesToApply(change: core.OperationsChange) -> Bool {
        if let lastOperation = change.lastOperation,
           lastOperation.isFailedAndOutgoing() {
            return false
        }

        return true
    }

    private func diffAmount(_ op: core.Operation) -> MonetaryAmount {
        switch op.direction {
        case .OUTGOING:
            // If the operation is outgoing, the money diff needs to take the fee into consideration
            let totalSats = op.amount.inSatoshis + op.totalFeeInSatoshis()
            return totalSats.toBTC()
        case .INCOMING:
            // If the operation is incoming, display the amount received
            return op.amount.inSatoshis.toBTC()
        case .CYCLICAL:
            // If the operation is cyclical, display the fee spent
            return op.totalFeeInSatoshis().toBTC()
        }
    }

    private func onBalanceChange(_ balance: MonetaryAmount) {
        self.balance = balance
        delegate.onBalanceChange(balance)
    }

    func getBTCBalance() -> MonetaryAmount {

        if let window = getExchangeRateWindow() {
            let bitcoinAmount = BitcoinAmount.from(
                inputCurrency: balance,
                with: window,
                primaryCurrency: "BTC"
            )
            return bitcoinAmount.inPrimaryCurrency
        }

        return balance
    }

    func getPrimaryBalance() -> MonetaryAmount {
        guard sessionActions.getPrimaryCurrency() != "BTC" else {
            return getBTCBalance()
        }

        if let window = getExchangeRateWindow() {
            let bitcoinAmount = BitcoinAmount.from(
                inputCurrency: balance,
                with: window,
                primaryCurrency: sessionActions.getPrimaryCurrency()
            )
            return bitcoinAmount.inPrimaryCurrency
        }

        return balance
    }

    func getOperationsState() -> core.OperationsState {
        return operationActions.getOperationsState()
    }

    func isBalanceHidden() -> Bool {
        return preferences.bool(forKey: .isBalanceHidden)
    }

    func toggleBalanceVisibility() {
        let newVisibilityValue = !isBalanceHidden()
        setBalanceHidden(newVisibilityValue)
        delegate.onBalanceVisibilityChange(newVisibilityValue)
    }

    private func setBalanceHidden(_ hidden: Bool) {
        preferences.set(value: hidden, forKey: .isBalanceHidden)
    }

    private func getExchangeRateWindow() -> ExchangeRateWindow? {
        return preferences.object(forKey: .exchangeRateWindow)
    }

    func hasEmailAndPassword() -> Bool {
        return sessionActions.hasPasswordChallengeKey()
    }

    private func isUnrecoverableUser() -> Bool {
        return sessionActions.isUnrecoverableUser()
    }

    private func shouldDisplayWelcomeMessage() -> Bool {
        return isUnrecoverableUser() && !preferences.bool(forKey: .welcomeMessageSeen)
    }

    func shouldDisplayTransactionListTooltip() -> Bool {
        let preferences = try? userPreferencesSelector.get()
            .toBlocking()
            .single()

        if let preferences = preferences {
            return !preferences.seenNewHome
        }

        return true
    }

    func setTooltipSeen() {
        updateUserPreferencesAction.run { prefs in
            prefs.copy(seenNewHome: true)
        }
    }

    private func setWelcomeMessageSeen() {
        preferences.set(value: true, forKey: .welcomeMessageSeen)
    }

    private func watchAppState() -> Observable<Bool?> {
        return preferences.watchBool(key: .appInForeground)
    }

    func logType() -> String {
        // Well, this is _awkward_. The event and variable say anon because that's how it was coded back when.
        // But the actual criteria was whether the user is unrecoverable. This is also the behaviour on apollo, so we'll
        // stick to it.
        let isAnon = isUnrecoverableUser()
        let hasOperations = operationActions.hasOperations()

        if isAnon {
            if hasOperations {
                return "anon_user_with_operations"
            } else {
                return "anon_user_without_operations"
            }
        }
        if hasOperations {
            return "user_set_up_with_operations"
        } else {
            return "user_set_up_without_operations"
        }
    }

    private func decideCompanion(taprootStatus: UserActivatedFeatureStatus) -> HomeCompanion {
        if isUnrecoverableUser() {
            return .backUp
        }

        switch taprootStatus {
        case .canActivate:
            return .activateTaproot

        case .canPreactivate(let blocksLeft):
            return .preactiveTaproot(blocksLeft: blocksLeft)

        case .preactivated(let blocksLeft):
            return .blockClock(blocksLeft: blocksLeft)

        case .active, .off, .scheduledActivation:
            return .none
        }
    }
}

extension HomePresenter: NotificationsFetcher {}
