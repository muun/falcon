//
//  Constant.swift
//  core
//
//  Created by Juan Pablo Civile on 30/05/2019.
//

import Foundation

public enum Constant {
    public static let buildVersion = "\(Bundle.main.infoDictionary!["CFBundleVersion"]!)"
    static let houstonLocale = Locale.init(identifier: "en_US")

    // Falcon timeout is 32 seconds because it will attempt the requests up to 3 times (96 seconds)
    // giving Houston enough time to timeout by itself (90 seconds)
    static let requestTimeoutInterval = TimeInterval(32)

    static let feeTargetForZeroConfSwaps: UInt = 9
    static let minimumFeePerVByte: Decimal = 1
}
