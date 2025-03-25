//
//  BaseRealmRepository.swift
//  falcon
//
//  Created by Juan Pablo Civile on 07/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation
import RxSwift
import RxGRDB
import GRDB

typealias DatabaseModel = PersistableRecord & FetchableRecord & DatabaseModelConvertible

class BaseDatabaseRepository<T, M> where T: DatabaseModel, T.Model == M {

    enum Errors: Error {
        case readFailed
    }

    let queue: DatabaseQueue

    public init(queue: DatabaseQueue) {
        self.queue = queue
    }

    func write(objects: [M]) -> Completable {
        return Completable.deferred({
            try self.queue.write { (db) in
                for object in objects {
                    try T(from: object).save(db)
                }
            }

            return Completable.empty()
        })
    }

    func watchObjects() -> Observable<[M]> {
        return T.all()
            .rx
            .observeAll(in: queue)
            .map({ [weak self] objects in

                guard let self = self else {
                    throw MuunError(Errors.readFailed)
                }

                return try self.queue.read { db in
                    try objects.map({ try $0.to(using: db) })
                }
            })
    }

    func watchObject(with id: T.PrimaryKeyType) -> Observable<M> {
        return T.filter(key: id)
            .rx
            .observeFirst(in: queue)
            .map({ [weak self] object in
                guard let self = self,
                    let object = object else {
                    throw MuunError(Errors.readFailed)
                }

                return try self.queue.read { db in
                    try object.to(using: db)
                }
            })
    }

    func objects(query: QueryInterfaceRequest<T>) -> [M]? {
        return queue.read { db in
            do {
                return try query.fetchAll(db).map {
                    try $0.to(using: db)
                }
            } catch {
                return nil
            }
        }
    }

    func object(query: QueryInterfaceRequest<T>) -> M? {
        return queue.read { db in
            do {
                return try query.fetchOne(db)?.to(using: db)
            } catch {
                return nil
            }
        }
    }

    func object(with id: T.PrimaryKeyType) -> M? {
        return queue.read { db in
            do {
                return try T.fetchOne(db, key: id)?.to(using: db)
            } catch {
                return nil
            }
        }
    }

    func count() -> Int {
        return queue.read { db in
            do {
                return try T.fetchCount(db)
            } catch {
                Logger.log(error: error)
                return 0
            }
        }
    }

    func count(query: QueryInterfaceRequest<T>) -> Int {
        return queue.read { db in
            do {
                return try query.fetchCount(db)
            } catch {
                Logger.log(error: error)
                return 0
            }
        }
    }

    func exists(query: QueryInterfaceRequest<T>) -> Bool {
        return queue.read { db in
            do {
                return try query.limit(1).fetchOne(db) != nil
            } catch {
                Logger.log(error: error)
                return false
            }
        }
    }

}

protocol DatabaseModelConvertible {

    associatedtype Model
    associatedtype PrimaryKeyType: DatabaseValueConvertible

    init(from: Model)

    func to(using: Database) throws -> Model

}
