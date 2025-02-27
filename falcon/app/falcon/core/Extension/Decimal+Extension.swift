//
//  Decimal+Extension.swift
//  falcon
//
//  Created by Juan Pablo Civile on 18/12/2018.
//  Copyright © 2018 muun. All rights reserved.
//

import Foundation

private func operationFailed(_ value1: Decimal,
                             _ value2: Decimal,
                             _ roundingMode: Decimal.RoundingMode,
                             _ error: NSDecimalNumber.CalculationError,
                             operation: String = #function,
                             file: StaticString = #file,
                             line: UInt = #line) -> Never {

    let str = "Operation \(operation)(\(value1), \(value2)) with rounding \(roundingMode) failed with status \(error)"
    fatalError(str, file: file, line: line)
}

extension Decimal {

    public var isNotANumber: Bool {
        var mutableSelf = self
        return NSDecimalIsNotANumber(&mutableSelf)
    }

    public mutating func compact() {
        NSDecimalCompact(&self)
    }

    public func round(scale: Int = Int(NSDecimalNoScale), roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self

        NSDecimalRound(&out, &mutableSelf, scale, roundingMode)

        return out
    }

    public static func normalize(_ decimal1: inout Decimal,
                                 _ decimal2: inout Decimal,
                                 roundingMode: RoundingMode = .plain) {

        let error = NSDecimalNormalize(&decimal1, &decimal2, roundingMode)
        guard error == .noError else {
            operationFailed(decimal1, decimal2, roundingMode, error)

        }
    }

    public func add(_ otherDecimal: Decimal, roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self
        var mutableOtherDecimal = otherDecimal

        let error = NSDecimalAdd(&out, &mutableSelf, &mutableOtherDecimal, roundingMode)
        guard error == .noError else {
            operationFailed(self, otherDecimal, roundingMode, error)
        }

        return out
    }

    public func subtract(otherDecimal: Decimal, roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self
        var mutableOtherDecimal = otherDecimal

        let error = NSDecimalSubtract(&out, &mutableSelf, &mutableOtherDecimal, roundingMode)
        guard error == .noError else {
            operationFailed(self, otherDecimal, roundingMode, error)
        }

        return out

    }

    public func multiplyBy(otherDecimal: Decimal, roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self
        var mutableOtherDecimal = otherDecimal

        let error = NSDecimalMultiply(&out, &mutableSelf, &mutableOtherDecimal, roundingMode)
        guard error == .noError else {
            operationFailed(self, otherDecimal, roundingMode, error)
        }

        return out

    }

    public func divideBy(otherDecimal: Decimal, roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self
        var mutableOtherDecimal = otherDecimal

        let error = NSDecimalDivide(&out, &mutableSelf, &mutableOtherDecimal, roundingMode)
        guard error == .noError else {
            operationFailed(self, otherDecimal, roundingMode, error)
        }

        return out

    }

    public func power(power: Int, roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self

        let error = NSDecimalPower(&out, &mutableSelf, power, roundingMode)
        guard error == .noError else {
            operationFailed(self, Decimal(power), roundingMode, error)
        }

        return out

    }

    public func multiplyByPowerOf10(power: Int16, roundingMode: RoundingMode = .plain) -> Decimal {

        var out: Decimal = 0
        var mutableSelf = self

        let error = NSDecimalMultiplyByPowerOf10(&out, &mutableSelf, power, roundingMode)
        guard error == .noError else {
            operationFailed(self, Decimal(power), roundingMode, error)
        }

        return out
    }

    public func stringValue(locale: Locale? = nil) -> String {
        var mutableSelf = self
        return NSDecimalString(&mutableSelf, locale)
    }
}
