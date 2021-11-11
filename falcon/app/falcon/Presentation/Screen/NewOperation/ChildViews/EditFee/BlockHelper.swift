//
//  BlockHelper.swift
//  falcon
//
//  Created by Manu Herrera on 02/08/2019.
//  Copyright © 2019 muun. All rights reserved.
//

import Foundation

class BlockHelper {

    static let blockConfirmationCertainty: Double = 0.75

    /**
     * Find the time t for which P(time until numBlocks are mined ≤ t) = certainty. That is, the
     * number of seconds one has to wait in order to be certain that numBlocks have been mined, with
     * a given certainty level.
     */
    public static func timeInSecs(numBlocks: UInt, certainty: Double) -> Int {
        // Since the emission of blocks is a poisson process with a number of arrivals per unit of
        // time (lambda) of 1/10 min, the time between blocks follows an exponential distribution:
        // x~exp(lambda). It turns out that's equivalent to saying that x has a gamma distribution:
        // x~gamma(1, lambda).
        //
        // Knowing that the sum of the gamma random variables x_i~gamma(k_i, r) is
        // sum(x_i)~gamma(sum(k_i), r), we can infer that the time of emission of k bitcoin blocks
        // is x~gamma(k, lambda).
        //
        // So, if T is the time it takes for k blocks to be emitted, then:
        //
        //     P(T ≤ t) = F(t; k, lambda)
        //
        // where F is the cumulative distribution function of gamma. It turns out that F can be
        // computed as:
        //
        //     P(T ≤ t) = 1 - e^(-lambda * t) * sum for i=0 to k-1 of ((lambda * t)^i / i!)
        //
        // For example, for K=1 (ie. just one block) and P = 0.9 (90% certainty), we get t = 24 min.

        if numBlocks == 0 {
            return 0
        }

        guard numBlocks > 0, certainty > 0, certainty < 1 else {
            fatalError("Invalid parameters")
        }

        // find the time T that makes the gammaCdf at least a given certainty using exponential &
        // binary search over T

        var left: Int = 0
        var right: Int = 1
        let lambda = 1.0/600.0

        while gammaCdf(time: right, numBlocks: numBlocks, lambda: lambda) < certainty {
            // Exponential search
            right *= 2
        }

        while left + 1 < right {
            // Binary search
            let mid: Int = (left + right) / 2

            if gammaCdf(time: mid, numBlocks: numBlocks, lambda: lambda) < certainty {
                left = mid
            } else {
                right = mid
            }
        }

        return right
    }

    /**
     * Compute F(t; k, lambda) = 1 - e^(-lambda * t) * sum for i=0 to k-1 of ((lambda * t)^i / i!).
     */
    private static func gammaCdf(time: Int, numBlocks: UInt, lambda: Double) -> Double {

        // We have to compute sum((lambda * t)^i / i!) and then divide it by e^(lambda * t). For
        // high t's, the sum can get really big before we divide it by the exponential.
        //
        // In order to avoid loosing precision, as we compute and accumulate each term of the sum,
        // we divide the partial sum by as many e^lambda factors as we can without making the
        // partial sum too small. Of course we'll only divide by up to t factors.

        let factor: Double = exp(lambda)
        var appliedFactors: Int = 0
        var term: Double = 1
        var sum: Double = 1

        for i in 1..<numBlocks {
            term *= (lambda * Double(time)) / Double(i)
            sum += term

            if term >= factor {
                let numFactors: Int = min(impreciseLog(x: term, base: factor), time - appliedFactors)
                appliedFactors += numFactors

                let divisor: Double = pow(factor, Double(numFactors))
                term /= divisor
                sum /= divisor
            }

        }

        return 1 - sum / pow(factor, Double(time - appliedFactors))
    }

    /**
     * Compute the integer logarithm of a number in an arbitrary base. Due to the way the
     * computation is done, we might have off by one errors due to precision loss. Fortunately, in
     * this case it isn't a problem.
     */
    private static func impreciseLog(x: Double, base: Double) -> Int {
        return Int(log(x) / log(base))
    }

    public static func hoursFor(_ blocks: UInt) -> Int {
        let secs = Double(BlockHelper.timeInSecs(numBlocks: blocks, certainty: blockConfirmationCertainty))
        return Int(ceil(secs / (60 * 60)))
    }

    public static func timeFor(_ blocks: UInt) -> String {
        let secs = Double(BlockHelper.timeInSecs(numBlocks: blocks, certainty: blockConfirmationCertainty))
        var roundedSecs: Int = 0

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated

        let secsIn3Hours: Double = 3 * 60 * 60
        if secs <= secsIn3Hours {
            let secsIn30Minutes: Double = 30 * 60
            // Between 0 and 3 hours, round up every 30 minutes
            formatter.allowedUnits = [.hour, .minute]
            // Round up seconds to next 30 minute value
            roundedSecs = Int(ceil(secs / secsIn30Minutes) * secsIn30Minutes)
        } else {
            let secsIn1Hour: Double = 60 * 60
            // For more than 3 hours round up evert 1 hour
            formatter.allowedUnits = [.hour]
            // Round up seconds to next 1 hour value
            roundedSecs = Int(ceil(secs / secsIn1Hour) * secsIn1Hour)
        }

        return formatter.string(from: TimeInterval(roundedSecs))!
    }

}
