//
//  Libwallet+Extension.swift
//  core.root-all-notifications
//
//  Created by Federico Bond on 14/07/2021.
//  Created by Juan Pablo Civile on 21/10/2021.
//

import Foundation
import Libwallet

extension FeeWindow {

    public func toLibwallet() -> NewopFeeWindow {
        let window = NewopFeeWindow()
        window.fastConfTarget = Int64(fastConfTarget ?? 0)
        window.mediumConfTarget = Int64(mediumConfTarget ?? 0)
        window.slowConfTarget = Int64(slowConfTarget ?? 0)

        for (key, value) in targetedFees {
            let feeRate = (value.satsPerVByte as NSDecimalNumber).doubleValue
            window.putTargetedFees(
                Int64(key), feeRateInSatsPerVByte: feeRate)
        }
        return window
    }

}

extension ExchangeRateWindow {

    public func toLibwallet() -> NewopExchangeRateWindow {
        let window = NewopExchangeRateWindow()
        window.windowId = id
        for (key, value) in rates {
            window.addRate(key, rate: value)
        }
        return window
    }

}

extension SizeForAmount {

    public func toLibwallet() -> NewopSizeForAmount {
        let amount = (amountInSatoshis.asDecimal() as NSDecimalNumber).int64Value

        let sizeForAmount = NewopSizeForAmount()
        sizeForAmount.amountInSat = amount
        sizeForAmount.sizeInVByte = sizeInBytes / 4 // This is necessary to convert the size in weight units to vbytes as accepted by libwallet
        sizeForAmount.outpoint = outpoint ?? ""

        return sizeForAmount
    }

}

extension NextTransactionSize {

    public func toLibwallet() -> NewopNextTransactionSize {
        let nts = NewopNextTransactionSize()

        for sizeForAmount in sizeProgression {
            nts.add(sizeForAmount.toLibwallet())
        }

        nts.validAtOperationHid = Int64(validAtOperationHid ?? 0)
        nts.expectedDebtInSat = (expectedDebt.asDecimal() as NSDecimalNumber).int64Value

        return nts
    }

}

extension Satoshis {

    public func toLibwallet() -> NewopMonetaryAmount {
        let value = (asDecimal() as NSDecimalNumber).int64Value
        return NewopNewMonetaryAmountFromSatoshis(value)!
    }

}

extension MuunPaymentURI {

    public func toLibwallet() -> LibwalletMuunPaymentURI {
        let muunURI = LibwalletMuunPaymentURI()
        muunURI.address = address ?? ""
        muunURI.amount = amount?.stringValue() ?? ""
        muunURI.bip70Url = bip70URL ?? ""
        muunURI.creationTime = creationTime ?? ""
        muunURI.expiresTime = expiresTime ?? ""
        muunURI.label = label ?? ""
        muunURI.message = message ?? ""
        muunURI.uri = uri.absoluteString
        return muunURI
    }

}

extension NewopBitcoinAmount {

    public func adapt() -> BitcoinAmount {
        return BitcoinAmount(
            inSatoshis: Satoshis(value: inSat),
            inInputCurrency: inInputCurrency!.adapt(),
            inPrimaryCurrency: inPrimaryCurrency!.adapt()
        )
    }

}

extension NewopMonetaryAmount {

    public func adapt() -> MonetaryAmount {
        return MonetaryAmount(amount: valueAsString(), currency: currency)!
    }

}

extension MonetaryAmount {

    public func toLibwallet() -> NewopMonetaryAmount {
        return NewopNewMonetaryAmountFromFiat("\(amount)", currency)!
    }

}

extension LibwalletStringList {

    public func adapt() -> [String] {
        var list: [String] = []
        for index in 0...(length() - 1) {
            list.append(get(index))
        }

        return list
    }
}

extension Array where Element == String {

    func toLibwallet() -> LibwalletStringList {

        let list = LibwalletStringList()!
        for s in self {
            list.add(s)
        }

        return list
    }

}

extension NewopSwapFees {

    public func adapt() -> SwapExecutionParameters {
        return SwapExecutionParameters(
            sweepFee: Satoshis(value: outputPaddingInSat),
            routingFee: Satoshis(value: routingFeeInSat),
            debtType: DebtType(rawValue: debtType)!,
            debtAmount: Satoshis(value: debtAmountInSat),
            confirmationsNeeded: UInt(confirmationsNeeded)
        )
    }

}

extension SubmarineSwap {

    public func toLibwallet() -> NewopSubmarineSwap {
        let submarineSwap = NewopSubmarineSwap()
        submarineSwap.receiver = _receiver.toLibwallet()

        let fees = NewopSwapFees()
        fees.confirmationsNeeded = Int64(_fundingOutput.confirmationsNeeded())
        fees.debtAmountInSat = _fundingOutput._debtAmount?.value ?? 0
        fees.debtType = _fundingOutput._debtType?.rawValue ?? ""
        fees.outputAmountInSat = _fundingOutput._outputAmount?.value ?? 0
        fees.outputPaddingInSat = _fees?._sweep.value ?? 0
        fees.routingFeeInSat = _fees?._lightning.value ?? 0

        submarineSwap.fees = fees
        submarineSwap.fundingOutputPolicies = _fundingOutputPolicies?.toLibwallet()

        if let bestRouteFees = _bestRouteFees {
            for bestRouteFee in bestRouteFees {
                submarineSwap.add(bestRouteFee.toLibwallet())
            }
        }

        return submarineSwap
    }

}

extension SubmarineSwapReceiver {

    public func toLibwallet() -> NewopSubmarineSwapReceiver {
        let receiver = NewopSubmarineSwapReceiver()
        receiver.alias = _alias ?? ""
        receiver.publicKey = _publicKey ?? ""
        receiver.networkAddresses = _networkAddresses.joined(separator: "\n")
        return receiver
    }

}

extension FundingOutputPolicies {

    public func toLibwallet() -> NewopFundingOutputPolicies {
        let policies = NewopFundingOutputPolicies()
        policies.maximumDebtInSat = _maximumDebtInSat
        policies.potentialCollectInSat = _potentialCollectInSat
        policies.maxAmountInSatFor0Conf = _maxAmountInSatFor0Conf
        return policies
    }

}

extension BestRouteFees {

    public func toLibwallet() -> NewopBestRouteFees {
        let fees = NewopBestRouteFees()
        fees.maxCapacity = _maxCapacityInSat
        fees.feeProportionalMillionth = _proportionalMillionth
        fees.feeBase = _baseInSat
        return fees
    }

}

extension LibwalletMuunPaymentURI {

    public func adapt() -> MuunPaymentURI {
        let toParse: String
        if self.uri != "" {
            toParse = self.uri
        } else {
            toParse = self.bip70Url
        }

        guard let uri = URL(string: toParse) else {
            Logger.fatal("Failed to parse URL \(toParse)")
        }

        return MuunPaymentURI(
            address: address,
            label: label,
            message: message,
            amount: Decimal(string: amount),
            others: [:],
            uri: uri,
            bip70URL: bip70Url,
            creationTime: creationTime,
            expiresTime: expiresTime,
            raw: self.uri
        )
    }
}

extension Array where Element == Int {

    func toLibwallet() -> LibwalletIntList {

        let list = LibwalletIntList()!
        for v in self {
            list.add(v)
        }

        return list
    }
}
