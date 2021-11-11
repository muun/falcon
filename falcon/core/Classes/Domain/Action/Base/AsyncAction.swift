//
//  AsyncAction.swift
//  falcon
//
//  Created by Manu Herrera on 17/08/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import RxSwift

public class AsyncAction<T>: NSObject {

    private let name: String
    private let subject: BehaviorSubject<ActionState<T>>
    private let scheduler = SerialDispatchQueueScheduler(qos: .background)

    init(name: String) {
        self.name = name
        self.subject = BehaviorSubject(value: ActionState.createEmpty())

        super.init()
    }

    func runSingle(_ single: Single<T>) {

        guard let state = try? subject.value() else {
            fatalError()
        }

        if state.type == .LOADING {
            return
        }

        _ = single
            .observeOn(scheduler)
            .do(onSuccess: {
                self.subject.onNext(ActionState.createValue(value: $0))
            }, onError: {
                self.subject.onNext(ActionState.createError(error: $0))
            }, onSubscribe: {
                self.subject.onNext(ActionState.createLoading())
            })
            .subscribeOn(Scheduler.backgroundScheduler)
            .subscribe()
    }

    public func reset() {
        subject.onNext(ActionState.createEmpty())
    }

    private func safeSetEmpty() {

        _ = scheduler.schedule((), action: { [weak self] _ in
            self?.subject.onNext(ActionState.createEmpty())
            return BooleanDisposable(isDisposed: true)
        })
    }

    public func getState() -> Observable<ActionState<T>> {
        return Observable.create({ (observer) -> Disposable in

            return self.subject
                .do(onSubscribed: {
                    observer.onNext(ActionState.createEmpty())
                })
                .subscribe(onNext: { [weak self] state in
                    switch state.type {

                    case .EMPTY:
                        break

                    case .LOADING:
                        observer.on(.next(state))

                    case .VALUE, .ERROR:
                        observer.on(.next(state))
                        observer.on(.next(ActionState.createEmpty()))

                        self?.safeSetEmpty()
                    }
                }, onError: { [weak self] error in
                    observer.on(.next(ActionState.createError(error: error)))

                    self?.safeSetEmpty()
                })
        })
    }

    public func getValue() -> Single<T> {
        return Single.create(subscribe: { (callback) -> Disposable in

            return self.subject
                .subscribe(onNext: { [weak self] state in
                    switch state.type {

                    case .EMPTY, .LOADING:
                        break

                    case .VALUE:
                        callback(.success(state.getValue()!))
                        self?.safeSetEmpty()

                    case .ERROR:
                        callback(.error(state.getError()!))
                        self?.safeSetEmpty()
                    }
                }, onError: { [weak self] err in
                    callback(.error(err))
                    self?.safeSetEmpty()
                }, onCompleted: {
                    // This should never ever be called
                })
        })
    }

}

protocol Runnable {
    func run()
}

extension AsyncAction where T == () {

    func runCompletable(_ completable: Completable) {
        runSingle(completable.andThen(Single.just(())))
    }

}
