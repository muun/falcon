//
//  BasePresenter.swift
//  falcon
//
//  Created by Manu Herrera on 16/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift
import core

protocol BasePresenterDelegate: AnyObject {
    func showMessage(_ message: String)
    func pushTo(_ vc: MUViewController)
}

class BasePresenter<Delegate> where Delegate: BasePresenterDelegate {

    weak var delegate: Delegate!
    var compositeDisposable: CompositeDisposable?
    private var sessionActions: SessionActions = resolve()

    lazy private var className = String(describing: type(of: self))
        .components(separatedBy: ".")
        .first!

    init(delegate: Delegate) {
        self.delegate = delegate
        compositeDisposable = CompositeDisposable()
    }

    func setUp() {
        if compositeDisposable == nil {
            compositeDisposable = CompositeDisposable()
        }

        Logger.log(.debug, "\(className) Set Up")
    }

    @discardableResult
    public func subscribeTo<T>(_ observable: Observable<T>, onNext: @escaping (_ t: T) -> Void)
        -> CompositeDisposable.DisposeKey? {
        let disp = observable
            .subscribeOn(Scheduler.backgroundScheduler)
            .observeOn(Scheduler.foregroundScheduler)
            .subscribe(
                onNext: onNext,
                onError: self.handleError
            )

        return compositeDisposable?.insert(disp)
    }

    @discardableResult
    public func subscribeTo<T>(_ single: Single<T>, onSuccess: @escaping (_ t: T) -> Void)
        -> CompositeDisposable.DisposeKey? {
        let disp = single
            .subscribeOn(Scheduler.backgroundScheduler)
            .observeOn(Scheduler.foregroundScheduler)
            .subscribe(
                onSuccess: onSuccess,
                onError: self.handleError
            )

        return compositeDisposable?.insert(disp)
    }

    @discardableResult
    public func subscribeTo(_ completable: Completable, onComplete: @escaping () -> Void)
        -> CompositeDisposable.DisposeKey? {
        let disp = completable
            .subscribeOn(Scheduler.backgroundScheduler)
            .observeOn(Scheduler.foregroundScheduler)
            .subscribe(
                onCompleted: onComplete,
                onError: self.handleError
            )

        return compositeDisposable?.insert(disp)
    }

    func handleError(_ e: Error) {

        if let muunError = e as? MuunError,
            let error = muunError.kind as? ServiceError {

            switch error {

            case .customError(let devError):

                switch devError.getKindOfError() {

                case .forceUpdate:
                    delegate.pushTo(UpdateAppViewController())

                case .sessionExpired, .missingOrInvalidAuthToken:
                    handleSessionExpired(e)

                case .nonUserFacing, .emailNotRegistered, .invoiceUnreachableNode, .recoveryCodeNotSetUp,
                     .invalidEmail, .emailAlreadyUsed, .invalidChallengeSignature, .exchangeRateWindowTooOld,
                     .invalidInvoice, .invoiceAlreadyUsed, .invoiceExpiresTooSoon, .noPaymentRoute, .cyclicalSwap,
                     .incomingSwapAlreadyFulfilled, .amountLessInvoicesNotSupported:
                    let error = devError.developerMessage ?? devError.message
                    Logger.log(LogLevel.debug, error)

                case .tooManyRequests:
                    delegate.showMessage(L10n.BasePresenter.s1)

                case .defaultError:
                    Logger.log(error: e)
                    delegate.showMessage(L10n.BasePresenter.s2)
                }

            case .internetError:
                delegate.showMessage(L10n.BasePresenter.s3)

            case .defaultError, .codableError, .serviceFailure, .timeOut:
                Logger.log(error: e)
                delegate.showMessage(L10n.BasePresenter.s2)
            }
        } else {
            Logger.log(error: e)
            delegate.showMessage(L10n.BasePresenter.s2)
        }
    }

    private func handleSessionExpired(_ e: Error) {
        // If the user is unrecoverable we can't wipe her data because that will cause the user to lose her money.
        // So instead we just display an error toast and the app will be bricked until we fix it in the backend.
        if sessionActions.isUnrecoverableUser() {
            Logger.log(error: e)
            delegate.showMessage(
                L10n.BasePresenter.s6
            )
        } else {
            delegate.pushTo(SessionExpiredViewController())
        }
    }

    func tearDown() {
        compositeDisposable?.dispose()
        compositeDisposable = nil

        Logger.log(.debug, "\(className) Tear Down")
    }

}

extension BasePresenter: Resolver {}
