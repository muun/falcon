//
//  DependencyContainer.swift
//  falcon
//
//  Created by Juan Pablo Civile on 13/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation


import Dip

enum DIManager {

    private static let appContainer = createAppContainer(domain: domainContainer)
    private static let domainContainer = DependencyContainer.domainContainer(data: dataContainer)
    private static let dataContainer = DependencyContainer.dataContainer()

    // By default we use appContainer
    fileprivate static var activeContainer = appContainer

    // This next two methods are for our testing harness exclusively
    static func testing_setupContainer(_ container: DependencyContainer) -> [DependencyContainer] {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            preconditionFailure("This method should only be used in tests")
        }

        activeContainer = container
        let dataContainer = DependencyContainer.dataContainer()
        let domainContainer = DependencyContainer.domainContainer(data: dataContainer)
        activeContainer.collaborate(with: domainContainer)

        return [dataContainer, domainContainer, activeContainer]
    }

    static func testing_resetCurrentContainer() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            preconditionFailure("This method should only be used in tests")
        }

        activeContainer = appContainer
    }

    private static func createAppContainer(domain: DependencyContainer) -> DependencyContainer {
        return DependencyContainer { container in
            container.collaborate(with: domain)

            // Set config variables

            let databaseURL: URL
            do {
                databaseURL = try FileManager.default
                    .url(for: .applicationSupportDirectory,
                         in: .userDomainMask,
                         appropriateFor: nil,
                         create: true)
                    .appendingPathComponent("db.sqlite")
            } catch {
                fatalError("Couldn't create path for DB")
            }

            container.register(.singleton,
                               type: URL.self,
                               tag: DependencyContainer.DataTags.databaseUrl) {
                databaseURL
            }
            container.register(.singleton,
                               type: String.self,
                               tag: DependencyContainer.DataTags.secureStoragePrefix) {
                Identifiers.bundleId
            }
            container.register(.singleton,
                               type: String.self,
                               tag: DependencyContainer.DataTags.secureStorageGroup) {
                Identifiers.group
            }

            // Make system objects available to data classes
            container.register { URLSession.shared }
            container.register { UserDefaults.standard }
        }
    }

}

// This code abuses both tuples and force trys with full knowledge of their consequences
// There's really no place in the codebase where failing to resolve a dependency is a non-fatal
// error

// swiftlint:disable force_try large_tuple

extension AppDelegate: Resolver {}

protocol Resolver {
    static func resolve<T>() -> T
}

extension Resolver {
    static func resolve<T>() -> T {
        return try! DIManager.activeContainer.resolve()
    }
}

protocol PresenterInstantior {}

extension MUViewController: PresenterInstantior {}

extension PresenterInstantior {

    func instancePresenter<T, U>(_ factory: ((U)) -> T,
                                 delegate: U) -> T where T: BasePresenter<U> {
        return factory((delegate))
    }

    func instancePresenter<T, U, S>(_ factory: ((U, S)) -> T, delegate: U, state: S) -> T
        where T: BasePresenter<U> {
        return factory((delegate, state))
    }

    func instancePresenter<T, U, A>(_ factory: ((U, A)) -> T, delegate: U) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            try! DIManager.activeContainer.resolve() as A
        ))
    }

    func instancePresenter<T, U, A, S>(_ factory: ((U, S, A)) -> T, delegate: U, state: S) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            state,
            try! DIManager.activeContainer.resolve() as A
        ))
    }

    func instancePresenter<T, U, A, B>(_ factory: ((U, A, B)) -> T, delegate: U) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            try! DIManager.activeContainer.resolve() as A,
            try! DIManager.activeContainer.resolve() as B
        ))
    }

    func instancePresenter<T, U, A, B, S>(_ factory: ((U, S, A, B)) -> T,
                                          delegate: U,
                                          state: S) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            state,
            try! DIManager.activeContainer.resolve() as A,
            try! DIManager.activeContainer.resolve() as B
        ))
    }

    func instancePresenter<T, U, A, B, C>(_ factory: ((U, A, B, C)) -> T, delegate: U) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            try! DIManager.activeContainer.resolve() as A,
            try! DIManager.activeContainer.resolve() as B,
            try! DIManager.activeContainer.resolve() as C
        ))
    }

    func instancePresenter<T, U, A, B, C, S>(_ factory: ((U, S, A, B, C)) -> T,
                                             delegate: U,
                                             state: S) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            state,
            try! DIManager.activeContainer.resolve() as A,
            try! DIManager.activeContainer.resolve() as B,
            try! DIManager.activeContainer.resolve() as C
        ))
    }

    func instancePresenter<T, U, A, B, C, D>(_ factory: ((U, A, B, C, D)) -> T, delegate: U) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            try! DIManager.activeContainer.resolve() as A,
            try! DIManager.activeContainer.resolve() as B,
            try! DIManager.activeContainer.resolve() as C,
            try! DIManager.activeContainer.resolve() as D
        ))
    }

    func instancePresenter<T, U, A, B, C, D, S>(_ factory: ((U, S, A, B, C, D)) -> T,
                                                delegate: U,
                                                state: S) -> T
        where T: BasePresenter<U> {

        return factory((
            delegate,
            state,
            try! DIManager.activeContainer.resolve() as A,
            try! DIManager.activeContainer.resolve() as B,
            try! DIManager.activeContainer.resolve() as C,
            try! DIManager.activeContainer.resolve() as D
        ))
    }

    func instancePresenter<T, U, A, B, C, D, E>(_ factory: ((U, A, B, C, D, E)) -> T,
                                                delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, S>(_ factory: ((U, S, A, B, C, D, E)) -> T,
                                                   delegate: U,
                                                   state: S) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                state,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F>(_ factory: ((U, A, B, C, D, E, F)) -> T,
                                                   delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, S>(_ factory: ((U, S, A, B, C, D, E, F)) -> T,
                                                      delegate: U,
                                                      state: S) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                state,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G>(_ factory: ((U, A, B, C, D, E, F, G)) -> T,
                                                      delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, S>(
        _ factory: ((U, S, A, B, C, D, E, F, G)) -> T, delegate: U, state: S) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                state,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, H>(_ factory: ((U, A, B, C, D, E, F, G, H)) -> T,
                                                         delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G,
                try! DIManager.activeContainer.resolve() as H
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, H, S>(
        _ factory: ((U, S, A, B, C, D, E, F, G, H)) -> T, delegate: U, state: S) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                state,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G,
                try! DIManager.activeContainer.resolve() as H
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, H, I>(_ factory: ((U, A, B, C, D, E, F, G, H, I)) -> T,
                                                            delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G,
                try! DIManager.activeContainer.resolve() as H,
                try! DIManager.activeContainer.resolve() as I
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, H, I, S>(
        _ factory: ((U, S, A, B, C, D, E, F, G, H, I)) -> T, delegate: U, state: S) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                state,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G,
                try! DIManager.activeContainer.resolve() as H,
                try! DIManager.activeContainer.resolve() as I
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, H, I, J>(
        _ factory: ((U, A, B, C, D, E, F, G, H, I, J)) -> T, delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G,
                try! DIManager.activeContainer.resolve() as H,
                try! DIManager.activeContainer.resolve() as I,
                try! DIManager.activeContainer.resolve() as J
            ))
    }

    func instancePresenter<T, U, A, B, C, D, E, F, G, H, I, J, K>(
        _ factory: ((U, A, B, C, D, E, F, G, H, I, J, K)) -> T, delegate: U) -> T
        where T: BasePresenter<U> {

            return factory((
                delegate,
                try! DIManager.activeContainer.resolve() as A,
                try! DIManager.activeContainer.resolve() as B,
                try! DIManager.activeContainer.resolve() as C,
                try! DIManager.activeContainer.resolve() as D,
                try! DIManager.activeContainer.resolve() as E,
                try! DIManager.activeContainer.resolve() as F,
                try! DIManager.activeContainer.resolve() as G,
                try! DIManager.activeContainer.resolve() as H,
                try! DIManager.activeContainer.resolve() as I,
                try! DIManager.activeContainer.resolve() as J,
                try! DIManager.activeContainer.resolve() as K
            ))
    }
}

// swiftlint:enable force_try large_tuple
