//
//  BaseSelector.swift
//  core.root-all-notifications
//
//  Created by Juan Pablo Civile on 11/12/2020.
//

import Foundation
import RxSwift

public class BaseSelector<T> {

    typealias Producer<T> = () -> Observable<T>
    let producer: Producer<T>

    init(_ producer: @escaping Producer<T>) {
        self.producer = producer
    }

    public func get() -> Single<T> {
        return producer()
            .take(1)
            .asSingle()
    }

    public func watch() -> Observable<T> {
        return producer()
    }

}
