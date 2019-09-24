//
//  BaseSelector.swift
//  falcon
//
//  Created by Juan Pablo Civile on 19/02/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation
import RxSwift

public class BaseSelector<T> {

    typealias Producer<T> = () -> Observable<T?>
    let producer: Producer<T>

    init(_ producer: @escaping Producer<T>) {
        self.producer = producer
    }

    public func get() -> Single<T> {
        return producer()
            .first()
            .map(unwrap)
            .asSingle()
    }

    private func unwrap(_ value: T?) throws -> T {
        if let value = value {
            return value
        } else {
            throw MuunError(Errors.noValue(type: T.self))
        }
    }

    public func watch() -> Observable<T?> {
        return producer()
    }

    enum Errors: Error {
        case noValue(type: T.Type)
    }

}
