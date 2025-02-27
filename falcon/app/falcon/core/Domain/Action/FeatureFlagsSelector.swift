//
//  FeatureFlagsSelector.swift
//
//  Created by Lucas Serruya on 09/05/2023.
//

import Foundation
import RxSwift

public class FeatureFlagsSelector: AsyncAction<[FeatureFlags]> {

    private let featureFlagsRepository: FeatureFlagsRepository

    init(featureFlagsRepository: FeatureFlagsRepository) {
        self.featureFlagsRepository = featureFlagsRepository

        super.init(name: "FeatureFlagsSelector")
    }

    public func run() -> Observable<[FeatureFlags]> {
        return featureFlagsRepository.watch()
    }
}
