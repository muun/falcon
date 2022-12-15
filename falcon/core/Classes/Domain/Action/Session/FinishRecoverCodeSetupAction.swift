//
//  FinishRecoverCodeSetupAction.swift
//  core-all
//
//  Created by Lucas Serruya on 20/10/2022.
//

import Foundation
import RxSwift

public class FinishRecoverCodeSetupAction: AsyncAction<()> {

    private let houstonService: HoustonService
    private let keysRepository: KeysRepository
    
    init(houstonService: HoustonService,
         keysRepository: KeysRepository) {
        self.houstonService = houstonService
        self.keysRepository = keysRepository

        super.init(name: "StartRecoverCodeSetupAction")
    }

    public func run(type: ChallengeType, recoveryCode: RecoveryCode) {
        runCompletable(
            getChallengePublicKey(recoveryCode: recoveryCode).flatMapCompletable({ [weak self] in
                guard let self = self else {
                    return Completable.error(NSError(domain: "failed_to_retrieve_challenge_key", code: 1))
                }
                
                return self.houstonService.finishChallenge(challengeType: type,
                                                           challengeSetupPublicKey: $0).do(onCompleted: { [weak self] in
                    self?.keysRepository.markChallengeKeyAsVerifiedForRecoveryCode()
                })
            })
        )
    }
    
    private func getChallengePublicKey(recoveryCode: RecoveryCode) -> Single<String>{
        guard let publicKey = try? recoveryCode.toKey().publicKey.toHexString() else {
            let error = NSError(domain: "failed_to_retrieve_challenge_key", code: 999)
            Logger.log(error: error)
            return Single.error(error)
        }
        
        return Single.just(publicKey)
    }
}
