//
//  NotificationTests.swift
//  falconTests
//
//  Created by Juan Pablo Civile on 23/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import XCTest
import RxSwift
@testable import core
@testable import falcon

// For some reason Swift thinks Notification is ambiguous in this file
typealias Notification = core.Notification

class NotificationProcessorTests: MuunTestCase {
    
    override func setUp() {
        super.setUp()
        
        let sessionRepository: SessionRepository = resolve()
        sessionRepository.setStatus(.BLOCKED_BY_EMAIL)
    }
    
    func testProcessFirst() {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = [0]
        fake.expectedConfirmedIds = [1]
        fake.fetchResult = []
        
        let processor = resolve() as NotificationProcessor
        let notifications: [Notification] = [
            buildSimpleNotification(id: 1)
        ]
        
        _ = processor.process(notifications: notifications).toBlocking().materialize()
        
        XCTAssertEqual(fake.fetchCalls, 0)
        XCTAssertEqual(fake.confirmCalls, 1)
    }
    
    func testFetchMissing() {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = [0]
        // We expect the id to be 1 because we discard the passed in notifications and just use the fetch
        // in the current implementation
        fake.expectedConfirmedIds = [1]
        fake.fetchResult = [
            buildSimpleNotification(id: 1)
        ]
        
        let processor = resolve() as NotificationProcessor
        let notifications: [Notification] = [
            buildSimpleNotification(id: 2)
        ]
        
        _ = processor.process(notifications: notifications).toBlocking().materialize()
        
        XCTAssertEqual(fake.fetchCalls, 1)
        XCTAssertEqual(fake.confirmCalls, 1)
    }
    
    func testConcurrentCalls() {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = [0]
        fake.expectedConfirmedIds = [3, 5]
        fake.fetchResult = []
        
        let processor = resolve() as NotificationProcessor
        
        let expectation = self.expectation(description: "two calls")
        expectation.expectedFulfillmentCount = 2
        
        DispatchQueue.main.async {
            
            let notifications: [Notification] = [
                self.buildSimpleNotification(id: 1),
                self.buildSimpleNotification(id: 2),
                self.buildSimpleNotification(id: 3)
            ]
            
            _ = processor.process(notifications: notifications)
                .subscribe(onCompleted: {
                    expectation.fulfill()
                })
        }
        
        DispatchQueue.main.async {
            
            let notifications: [Notification] = [
                self.buildSimpleNotification(id: 3),
                self.buildSimpleNotification(id: 4),
                self.buildSimpleNotification(id: 5)
            ]
            
            _ = processor.process(notifications: notifications)
                .subscribe(onCompleted: {
                    expectation.fulfill()
                })
        }
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(fake.fetchCalls, 0)
        XCTAssertEqual(fake.confirmCalls, 2)
    }
    
    func testInvalidNotification() {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = [0]
        fake.expectedConfirmedIds = [1]
        fake.fetchResult = []
        
        let processor = resolve() as NotificationProcessor
        let notifications: [Notification] = [
            buildSimpleNotification(id: 1),
            buildInvalidNotification(id: 2)
        ]
        
        _ = processor.process(notifications: notifications).toBlocking().materialize()
        
        XCTAssertEqual(fake.fetchCalls, 0)
        XCTAssertEqual(fake.confirmCalls, 1)
    }
    
    func testIgnoreLowerIds() {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = [0]
        fake.expectedConfirmedIds = [3]
        fake.fetchResult = []
        
        let processor = resolve() as NotificationProcessor
        var notifications: [Notification] = [
            buildSimpleNotification(id: 1),
            buildSimpleNotification(id: 2),
            buildSimpleNotification(id: 3)
        ]
        
        _ = processor.process(notifications: notifications).toBlocking().materialize()
        
        notifications = [
            buildSimpleNotification(id: 1),
            buildSimpleNotification(id: 2),
            buildSimpleNotification(id: 3)
        ]
        
        _ = processor.process(notifications: notifications).toBlocking().materialize()
        
        XCTAssertEqual(fake.fetchCalls, 0)
        // We should only confirm once since the second batch should be totally dropped
        XCTAssertEqual(fake.confirmCalls, 1)
    }
    
    func testComplexCase() {
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = [3]
        fake.expectedConfirmedIds = [3, 6]
        fake.fetchResult = [
            self.buildSimpleNotification(id: 4),
            self.buildSimpleNotification(id: 5),
            self.buildSimpleNotification(id: 6)
        ]
        
        let processor = resolve() as NotificationProcessor
        
        let expectation = self.expectation(description: "two calls")
        expectation.expectedFulfillmentCount = 2
        
        DispatchQueue.main.async {
            
            let notifications: [Notification] = [
                self.buildSimpleNotification(id: 1),
                self.buildSimpleNotification(id: 2),
                self.buildSimpleNotification(id: 3)
            ]
            
            _ = processor.processReport(notifications, maximumId: 6)
                .subscribe(onCompleted: {
                    expectation.fulfill()
                })
        }
        
        DispatchQueue.main.async {
            
            let notifications: [Notification] = [
                self.buildSimpleNotification(id: 3),
                self.buildSimpleNotification(id: 4),
                self.buildSimpleNotification(id: 5)
            ]
            
            _ = processor.processReport(notifications, maximumId: 6)
                .subscribe(onCompleted: {
                    expectation.fulfill()
                })
        }
        
        wait(for: [expectation], timeout: 5)
        
        XCTAssertEqual(fake.fetchCalls, 1)
        // We should only confirm in the first block since the second batch should be totally dropped
        // BUT the first block calls twice: once for the batch we pass in and another for the one it loads
        XCTAssertEqual(fake.confirmCalls, 2)
    }
    
    func testInvalidPermissions() {
        let sessionRepository: SessionRepository = resolve()
        sessionRepository.setStatus(.CREATED)
        
        let fake = replace(.singleton, HoustonService.self, FakeHoustonService.init)
        
        fake.expectedAfterIds = []
        fake.expectedConfirmedIds = [0]
        fake.fetchResult = []
        
        let processor = resolve() as NotificationProcessor
        let notifications: [Notification] = [
            buildSimpleNotification(id: 1)
        ]
        
        _ = processor.process(notifications: notifications).toBlocking().materialize()
        
        XCTAssertEqual(fake.fetchCalls, 0)
        XCTAssertEqual(fake.confirmCalls, 0)
    }
    
    private func buildSimpleNotification(id: Int) -> Notification {
        return Notification(id: id, previousId: id - 1, senderSessionUuid: "", message: .sessionAuthorized)
    }
    
    private func buildInvalidNotification(id: Int) -> Notification {
        return Notification(id: id, previousId: id - 1, senderSessionUuid: "", message: .unknownMessage(type: "foo"))
    }
    
}

fileprivate class FakeHoustonService: HoustonService {
    
    var expectedConfirmedIds: [Int]? = nil
    var expectedAfterIds: [Int]? = nil
    var fetchResult: [Notification] = []
    
    var fetchCalls: Int = 0
    var confirmCalls: Int = 0
    
    override func fetchNotificationsAfter(notificationId: Int?) -> Single<[Notification]> {
        
        return Single.deferred({
            self.fetchCalls += 1

            if let expectedAfterId = self.expectedAfterIds?.first {
                self.expectedAfterIds?.removeFirst()
                XCTAssertEqual(expectedAfterId, notificationId)
            }
            
            return Single.just(self.fetchResult)
        })
    }
    
    override func confirmNotificationsDeliveryUntil(notificationId: Int,
                                                    deviceModel: String,
                                                    osVersion: String,
                                                    appStatus: String) -> Completable {
        
        return Completable.deferred({
            self.confirmCalls += 1
            
            if let expectedConfirmedId = self.expectedConfirmedIds?.first {
                self.expectedConfirmedIds?.removeFirst()
                XCTAssertEqual(expectedConfirmedId, notificationId)
            }
            
            return Completable.empty()
        })
    }
    
}
