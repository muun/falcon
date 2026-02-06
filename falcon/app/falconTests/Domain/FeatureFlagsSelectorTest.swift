//
//  FeatureFlagsSelectorTest.swift
//  falcon
//
//  Created by Daniel Mankowski on 19/01/2026.
//  Copyright © 2026 muun. All rights reserved.
//


import XCTest

@testable import Muun

class FeatureFlagsSelectorTest: MuunTestCase {
    private lazy var featureFlagsSelector: FeatureFlagsSelector = resolve()
    private lazy var featureFlagsRepository: FeatureFlagsRepository = resolve()
    private lazy var featureFlagsOverridesRepository: FeatureFlagsOverridesRepository = resolve()

    override func setUp() {
        super.setUp()
        // Reset repository in each test
        featureFlagsRepository.store(flags: [])
    }

    override func tearDown() {
        super.tearDown()
        // Remove local override
        featureFlagsOverridesRepository.setFlag(.nfcCardV2, isDisabled: false)
    }

    func testLocalDisabledFlagAndBackendEnabledShouldReturnDisable() {
        // If NFC_CARD_V2 is not overridable in the future, this test should change.
        XCTAssertTrue(FeatureFlags.nfcCardV2.overrideMetadata.isOverridable)

        featureFlagsRepository.store(flags: [.nfcCardV2])
        featureFlagsOverridesRepository.setFlag(.nfcCardV2, isDisabled: true)

        XCTAssertFalse(featureFlagsSelector.fetch().contains(.nfcCardV2))
    }

    func testLocalEnabledFlagAndBackendEnabledShouldReturnEnable() {
        // If NFC_CARD_V2 is not overridable in the future, this test should change.
        XCTAssertTrue(FeatureFlags.nfcCardV2.overrideMetadata.isOverridable)

        featureFlagsRepository.store(flags: [.nfcCardV2])
        featureFlagsOverridesRepository.setFlag(.nfcCardV2, isDisabled: false)

        XCTAssertTrue(featureFlagsSelector.fetch().contains(.nfcCardV2))
    }

    // Ensures all overridable feature flags can be set.
    // This test acts as a safeguard: if any flag key changes in `schema.go`,
    // it will fail and prevent the merge.
    func testAllFeatureKeys() {
        FeatureFlags
            .allCases
            .filter { $0.overrideMetadata.isOverridable }
            .forEach {
                featureFlagsOverridesRepository.setFlag($0, isDisabled: false)
            }
    }
}
