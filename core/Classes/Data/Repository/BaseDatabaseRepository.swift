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

    let coordinator: DatabaseCoordinator

    public init(coordinator: DatabaseCoordinator) {
        self.coordinator = coordinator
    }

    func write(objects: [M]) -> Completable {
        return Completable.deferred({
            try self.coordinator.queue.write { (db) in
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
            .observeAll(in: coordinator.queue)
            .map({ [weak self] objects in

                guard let self = self else {
                    throw MuunError(Errors.readFailed)
                }

                return try self.coordinator.queue.read { db in
                    try objects.map({ try $0.to(using: db) })
                }
            })
    }

    func watchObject(with id: T.PrimaryKeyType) -> Observable<M> {
        return T.filter(key: id)
            .rx
            .observeFirst(in: coordinator.queue)
            .map({ [weak self] object in
                guard let self = self,
                    let object = object else {
                    throw MuunError(Errors.readFailed)
                }

                return try self.coordinator.queue.read { db in
                    try object.to(using: db)
                }
            })
    }

    func object(query: QueryInterfaceRequest<T>) -> M? {

        return self.coordinator.queue.read { db in
            do {
                return try query.fetchOne(db)?.to(using: db)
            } catch {
                return nil
            }
        }
    }

    func object(with id: T.PrimaryKeyType) -> M? {
        return self.coordinator.queue.read { db in
            do {
                return try T.fetchOne(db, key: id)?.to(using: db)
            } catch {
                return nil
            }
        }
    }

    func count() -> Int {
        return self.coordinator.queue.read { db in
            do {
                return try T.fetchCount(db)
            } catch {
                Logger.log(error: error)
                return 0
            }
        }
    }

    func count(query: QueryInterfaceRequest<T>) -> Int {
        return self.coordinator.queue.read { db in
            do {
                return try query.fetchCount(db)
            } catch {
                Logger.log(error: error)
                return 0
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
