//
//  Preferences.swift
//  falcon
//
//  Created by Manu Herrera on 01/10/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift

/*
 For a complete guide on how to use this class refer to:
 https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
 */

public class Preferences {

    private let userDefaults: UserDefaults
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    private let subject: BehaviorSubject<Persistence?> = BehaviorSubject(value: nil)

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    public func set(value: Any?, forKey: Persistence) {
        userDefaults.set(value, forKey: forKey.rawValue)
        subject.onNext(forKey)
    }

    public func set<T>(object codable: T, forKey key: Persistence) where T: Codable {
        guard let data = try? encoder.encode(Container(value: codable)) else {
            fatalError("Cant encode value for key \(key.rawValue)")
        }

        userDefaults.set(data, forKey: key.rawValue)
        subject.onNext(key)
    }

    public func remove(key: Persistence) {
        userDefaults.removeObject(forKey: key.rawValue)

        subject.onNext(key)
    }

    public func wipeAll() {
        let currentToken = string(forKey: .gcmToken)
        let environment = string(forKey: .currentEnvironment)

        let dictionary = userDefaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }

        // At this point the app is still in foreground
        set(value: true, forKey: .appInForeground)

        // Push notification token remains the same, as it is associated to the instance, not the user
        set(value: currentToken, forKey: .gcmToken)

        // Environment does not change with a log out
        set(value: environment, forKey: .currentEnvironment)

        Persistence.allCases.forEach(subject.onNext)
    }

    // Getters

    public func object<T>(forKey key: Persistence) -> T? where T: Codable {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return nil
        }

        do {
            return try self.decoder.decode(Container<T>.self, from: data).value
        } catch {
            fatalError("Can't decode object for key \(key.rawValue)")
        }
    }

    public func any(forKey: Persistence) -> Any? {
        return userDefaults.object(forKey: forKey.rawValue)
    }

    public func string(forKey: Persistence) -> String? {
        return userDefaults.string(forKey: forKey.rawValue)
    }

    public func array(forKey: Persistence) -> [Any]? {
        return userDefaults.array(forKey: forKey.rawValue)
    }

    public func dictionary(forKey: Persistence) -> [String: Any]? {
        return userDefaults.dictionary(forKey: forKey.rawValue)
    }

    public func data(forKey: Persistence) -> Data? {
        return userDefaults.data(forKey: forKey.rawValue)
    }

    public func stringArray(forKey: Persistence) -> [String]? {
        return userDefaults.stringArray(forKey: forKey.rawValue)
    }

    public func integer(forKey: Persistence) -> Int {
        return userDefaults.integer(forKey: forKey.rawValue)
    }

    public func float(forKey: Persistence) -> Float {
        return userDefaults.float(forKey: forKey.rawValue)
    }

    public func double(forKey: Persistence) -> Double {
        return userDefaults.double(forKey: forKey.rawValue)
    }

    public func bool(forKey: Persistence) -> Bool {
        return userDefaults.bool(forKey: forKey.rawValue)
    }

    public func has(key: Persistence) -> Bool {
        return userDefaults.object(forKey: key.rawValue) != nil
    }

    // Observables

    private func watch<T>(key: Persistence, _ mapper: @escaping (Persistence) -> T?) -> Observable<T?> {

        let firstFire = Observable.deferred({
            Observable.just(mapper(key))
        })

        let updates = subject.asObservable()
            .filter { $0 == key }
            .map { _ in mapper(key) }

        return firstFire.concat(updates)

    }

    public func watchObject<T>(key: Persistence) -> Observable<T?> where T: Codable {
        return watch(key: key) { [weak self] _ in
            guard let data = self?.data(forKey: key) else {
                return nil
            }

            do {
                return try self?.decoder.decode(Container<T>.self, from: data).value
            } catch {
                fatalError("Can't decode object for key \(key.rawValue)")
            }
        }
    }

    public func watchAny(key: Persistence) -> Observable<Any?> {
        return watch(key: key, self.any)
    }

    public func watchString(key: Persistence) -> Observable<String?> {
        return watch(key: key, self.string)
    }

    public func watchArray(key: Persistence) -> Observable<[Any]?> {
        return watch(key: key, self.array)
    }

    public func watchDictionary(key: Persistence) -> Observable<[String: Any]?> {
        return watch(key: key, self.dictionary)
    }

    public func watchData(key: Persistence) -> Observable<Data?> {
        return watch(key: key, self.data)
    }

    public func watchStringArray(key: Persistence) -> Observable<[String]?> {
        return watch(key: key, self.stringArray)
    }

    public func watchInteger(key: Persistence) -> Observable<Int?> {
        return watch(key: key, self.integer)
    }

    public func watchFloat(key: Persistence) -> Observable<Float?> {
        return watch(key: key, self.float)
    }

    public func watchDouble(key: Persistence) -> Observable<Double?> {
        return watch(key: key, self.double)
    }

    public func watchBool(key: Persistence) -> Observable<Bool?> {
        return watch(key: key, self.bool)
    }

}

// Hack class to avoid crashing when storing Codables that are primitive values
private struct Container<T>: Codable where T: Codable {
    let value: T
}
