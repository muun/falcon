//
//  FakeHoustonService.swift
//  falconTests
//
//  Created by Lucas Serruya on 27/10/2022.
//  Copyright © 2022 muun. All rights reserved.
//

@testable import Muun

import RxSwift
import XCTest

class FakeHoustonService: HoustonService {
    var expectedSetupChallengeResponse: SetupChallengeResponse!
    var startChallengeCalledCount = 0
    var lastReceivedChallengeSetup: ChallengeSetup!
    var expectedError: NSError?

    override func startChallenge(challengeSetup: ChallengeSetup) -> Single<SetupChallengeResponse> {
        lastReceivedChallengeSetup = challengeSetup

        return Single.just(expectedSetupChallengeResponse)
            .do(onSubscribe: {
                self.startChallengeCalledCount += 1
            })
    }
    
    var finishChallengeCalledCount = 0
    
    override func finishChallenge(challengeType: ChallengeType, challengeSetupPublicKey: String) -> Completable {
        self.finishChallengeCalledCount += 1
        guard let error = expectedError else {
            return Completable.empty()
        }

        return Completable.error(error)
    }
    
    var updateCalls = 0
    
    override func update(externalAddressesRecord: ExternalAddressesRecord) -> Single<ExternalAddressesRecord> {
        
        let maxIndex = max(externalAddressesRecord.maxUsedIndex, externalAddressesRecord.maxWatchingIndex ?? -1)
        
        return Single.just(ExternalAddressesRecord(
            maxUsedIndex: externalAddressesRecord.maxUsedIndex,
            maxWatchingIndex: maxIndex + 10))
            .do(onSubscribe: {
                self.updateCalls += 1
            })
    }
    
    var expectedConfirmedIds: [Int]? = nil
    var expectedAfterIds: [Int]? = nil
    var fetchResult: [NotificationReport] = []
    
    var fetchCalls: Int = 0
    var confirmCalls: Int = 0

    override func fetchNotificationReportAfter(notificationId: Int?) -> Single<NotificationReport> {
        
        return Single.deferred({
            self.fetchCalls += 1

            if let expectedAfterId = self.expectedAfterIds?.first {
                self.expectedAfterIds?.removeFirst()
                XCTAssertEqual(expectedAfterId, notificationId)
            }

            let result = self.fetchResult.removeFirst()

            return Single.just(result)
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
    
    var fetchFulfillmentCalls = 0
    var fulfillCalls = 0
    var expiredCalls = 0

    var pushedPreimage = [Data]()
    var expiredHash = [Data]()

    override func fetchFulfillmentData(for uuid: String) -> Single<IncomingSwapFulfillmentData> {
        return Single.from {
            self.fetchFulfillmentCalls += 1
            throw MuunError(ServiceError.customError(DeveloperError(
                developerMessage: "",
                errorCode: 2074,
                message: "already fulfilled",
                requestId: 0,
                status: 400
            )))
        }
    }

    override func pushFulfillmentTransaction(rawTransaction: RawTransaction, incomingSwap: String) -> Single<FulfillmentPushed> {

        return Single.create { completion in
            XCTFail("no test is expected to call this method")

            return Disposables.create()
        }
    }

    override func fulfill(incomingSwap: String, preimage: Data) -> Completable {
        return Completable.executing {
            self.pushedPreimage.append(preimage)
            self.fulfillCalls += 1
        }
    }

    override func expireInvoice(_ invoiceHex: String) -> Completable {
        return Completable.executing {
            self.expiredCalls += 1
            self.expiredHash.append(Data(hex: invoiceHex))
        }
    }
    
    var calls = 0

    override func updateUserPreferences(_ preferences: UserPreferences) -> Completable {
        return Completable.empty()
            .do(afterCompleted: {
                    self.calls += 1
            })
    }

    var canReachServerExpected = true
    var canReachServerCalledCount = 0
    override func publicStatus() -> Single<()> {
        canReachServerCalledCount += 1
        return Single.create { completion in
            guard self.canReachServerExpected else {
                completion(.error(NSError(domain: "", code: 1)))
                return Disposables.create()
            }

            completion(.success(()))

            return Disposables.create()
        }
    }

    var canUpdateGcmToken = true
    var updateGcmTokenCalledCount = 0
    var shouldRespondToUpdateGcmToken = BehaviorSubject<Bool>(value: true)
    var lastSyncedGCMToken: String?
    var updateGcmTokenExpectation: XCTestExpectation?
    override func updateGcmToken(gcmToken: String) -> Single<()> {
        updateGcmTokenCalledCount += 1
        return Single.create { completion in
            _ = self.shouldRespondToUpdateGcmToken.subscribe { value in
                if value.element ?? false {
                    guard self.canUpdateGcmToken else {
                        completion(.error(NSError(domain: "", code: 1)))
                        return
                    }

                    self.lastSyncedGCMToken = gcmToken
                    completion(.success(()))
                    self.updateGcmTokenExpectation?.fulfill()
                }
            }

            return Disposables.create()
        }
    }

    var fetchRealTimeFeesCalledCount = 0
    let feeWindow = FeeWindow(id: 1,
                              fetchDate: Date(),
                              targetedFees: [0: FeeRate(satsPerVByte: 10)],
                              fastConfTarget: 1,
                              mediumConfTarget: 43,
                              slowConfTarget: 90)
    let feeBumpFunctions = FeeBumpFunctions(uuid: "testID", functions: ["f4AAAD+AAAAAAAAA"]) // [+Inf, 1, 0]
    lazy var fetchRealTimeFeesResult = RealTimeFees(feeBumpFunctions: feeBumpFunctions,
                                               feeWindow: feeWindow,
                                               minMempoolFeeRateInSatPerVbyte: 1,
                                               minFeeRateIncrementToReplaceByFeeInSatPerVbyte: 1,
                                               computedAt: Date())
    override func fetchRealTimeFees(realTimeFeesRequest: RealTimeFeesRequestJson) -> Single<RealTimeFees> {
        fetchRealTimeFeesCalledCount += 1
        return .just(self.fetchRealTimeFeesResult)
    }
}
