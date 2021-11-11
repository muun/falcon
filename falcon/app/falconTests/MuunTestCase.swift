//
//  MuunTestCase.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 19/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import XCTest
import Dip
import GRDB
import RxSwift
import RxBlocking
@testable import core
@testable import Muun
import Libwallet

private let secureStoragePrefix = "muun_tests_secure"
private let userDefaultsDomain = "muun_tests"
private let databaseURL = try! FileManager.default
    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    .appendingPathComponent("test-db.sqlite")
private let libwalletStorageURL = try! FileManager.default
    .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    .appendingPathComponent("test-libwallet")

private let databaseCoordinator = try! DatabaseCoordinator(
    queue: DatabaseQueue(path: databaseURL.path),
    preferences: Preferences(userDefaults: UserDefaults(suiteName: userDefaultsDomain)!),
    secureStorage: SecureStorage(keyPrefix: secureStoragePrefix, group: Identifiers.group)
)

class MuunTestCase: XCTestCase {
    
    var containers: [DependencyContainer] = []
    var userDefaults: UserDefaults!
    
    override func setUp() {
        try? FileManager.default.removeItem(at: libwalletStorageURL)

        setupTestingContext()
        
        try! (resolve() as DatabaseCoordinator).wipeAll()
    }
    
    override func tearDown() {
        // Clear the previous test storage, this throws an error to the console but it can be ignore
        (resolve() as SecureStorage).wipeAll()
        try! (resolve() as DatabaseCoordinator).wipeAll()
        try? FileManager.default.removeItem(at: libwalletStorageURL)
        
        // Clear away all containers
        DIManager.testing_resetCurrentContainer()
        containers.forEach { $0.reset() }
        containers = []
    }
    
    func setupTestingContext() {
        
        // Clear away user defaults and create a new one
        UserDefaults().removePersistentDomain(forName: userDefaultsDomain)
        userDefaults = UserDefaults(suiteName: userDefaultsDomain)
        
        let testContainer = DependencyContainer { container in
            container.register(.singleton, type: URL.self, tag: DependencyContainer.DataTags.databaseUrl) {
                databaseURL
            }
            container.register(.singleton, type: String.self, tag: DependencyContainer.DataTags.secureStoragePrefix) {
                secureStoragePrefix
            }
            container.register(.singleton, type: String.self, tag: DependencyContainer.DataTags.secureStorageGroup) {
                Identifiers.group
            }

            container.register { URLSession.shared }
            container.register { self.userDefaults! }
        }

        try! FileManager.default.createDirectory(
            at: libwalletStorageURL,
            withIntermediateDirectories: true,
            attributes: [:]
        )

        let libwalletConfig = LibwalletConfig()
        libwalletConfig.dataDir = libwalletStorageURL.absoluteString
        LibwalletInit(libwalletConfig)
        
        containers = DIManager.testing_setupContainer(testContainer)
        _ = replace(.singleton, DatabaseCoordinator.self) { databaseCoordinator }
    }
    
    func setupBasicData() {
        _ = resolve() as UserDefaults
        _ = resolve() as Preferences
        _ = resolve() as SecureStorage
        
        let userRepository: UserRepository = resolve()
        let exchangeRateRepository: ExchangeRateWindowRepository = resolve()

        let user = User(id: 0,
                        firstName: "Pepe",
                        lastName: "Test",
                        email: "pepe@test.com",
                        phoneNumber: nil,
                        profilePictureUrl: nil,
                        primaryCurrency: "USD",
                        isEmailVerified: true,
                        hasPasswordChallengeKey: false,
                        hasRecoveryCodeChallengeKey: false,
                        hasP2PEnabled: false,
                        createdAt: Date())
        userRepository.setUser(user)
        
        let window = ExchangeRateWindow(id: 0,
                                        fetchDate: Date(),
                                        rates: ["USD": 1])
        exchangeRateRepository.setExchangeRateWindow(window)
    }
    
    func wait<T>(for observable: T) where T: ObservableConvertibleType {
        let result = observable
            .asObservable()
            .debug()
            .toBlocking()
            .materialize()
        
        if case .failed(_, let err) = result {
            XCTFail("observable \(observable) errored with \(err)")
        }
    }

    func expectError<T>(for observable: T, matcher: (Error) -> Bool) where T: ObservableConvertibleType {
        let result = observable
            .asObservable()
            .debug()
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Observable \(observable) yielded results instead of error")
        case .failed(_, let error):
            if matcher(error) {
                return
            } else {
                XCTFail("Observable \(observable) yielded unexpected error \(error)")
            }
        }
    }
    
    func expectTimeout<T>(for observable: T, after: TimeInterval = 1) where T: ObservableConvertibleType {
        let result = observable
            .asObservable()
            .debug()
            .toBlocking(timeout: after)
            .materialize()
        
        if case .failed(_, let err) = result,
            let rxError = err as? RxError,
            case .timeout = rxError {
            
            return
        }
        
        XCTFail("expected observable \(observable) to timeout instead got \(result)")
    }
}

extension MuunTestCase {
    
    func replace<T, U>(_ scope: ComponentScope,
                       _ type: U.Type = U.self,
                       _ factory: @escaping (()) -> T) -> T {
        
        replace { container in
            return container.register(scope, type: type) {
                factory(()) as! U
            }
        }
        
        return (resolve() as U) as! T
    }
    
    func replace<T, U, A>(_ scope: ComponentScope,
                          _ type: U.Type = U.self,
                          _ factory: @escaping ((A)) -> T) -> T {
        
        replace { container in
            return container.register(scope, type: type) { (a: A) in
                factory((a)) as! U
            }
        }
        
        return (resolve() as U) as! T
    }
    
    func replace<T, U, A, B>(_ scope: ComponentScope,
                             _ type: U.Type = U.self,
                             _ factory: @escaping ((A, B)) -> T) -> T {
        
        replace { container in
            return container.register(scope, type: type) { (a: A, b: B) in
                factory((a, b)) as! U
            }
        }
        
        return (resolve() as U) as! T
    }
    
    func replace<T, U, A, B, C>(_ scope: ComponentScope,
                                _ type: U.Type = U.self,
                                _ factory: @escaping ((A, B, C)) -> T) -> T {
        
        replace { container in
            return container.register(scope, type: type) { (a: A, b: B, c: C) in
                factory((a, b, c)) as! U
            }
        }
        
        return (resolve() as U) as! T
    }
    
    func replace<T, U, A, B, C, D>(_ scope: ComponentScope,
                                   _ type: U.Type = U.self,
                                   _ factory: @escaping ((A, B, C, D)) -> T) -> T {
        
        replace { container in
            return container.register(scope, type: type) { (a: A, b: B, c: C, d: D) in
                factory((a, b, c, d)) as! U
            }
        }
        
        return (resolve() as U) as! T
    }
    
    private func replace<T, U>(using builder: (DependencyContainer) -> Definition<T, U>) {
        // Well, there's a perfectly rational explication for this.
        // We need to scrub the existing definition to make sure only ours survives
        // BUUUUUTTTT definitions are not easily instanced, so we register, use that def
        // to erase the old one and re register cause we just erased it
        let testContainer = containers.last!
        let definition = builder(testContainer)
        
        for container in containers {
            container.remove(definition)
        }
        
        testContainer.register(definition)
    }
    
    func resolve<T>() -> T {
        return try! containers.last!.resolve()
    }
    
}

extension MuunTestCase: PresenterInstantior {}

class ExpectablePresenterDelegate: BasePresenterDelegate {
    
    let expectation: XCTestExpectation
    let expectsMessage: Bool
    
    init(expectation: XCTestExpectation, expectsMessage: Bool = false) {
        self.expectation = expectation
        self.expectsMessage = expectsMessage
        
        if expectsMessage {
            expectation.expectedFulfillmentCount += 1
        }
    }
    
    func showMessage(_ message: String) {
        if expectsMessage {
            XCTAssert(true, "Received expected message")
            expectation.fulfill()
        } else {
            XCTFail("Recieved show message when it was unexpected")
        }
    }

    func pushTo(_ vc: MUViewController) {

    }
    
}
