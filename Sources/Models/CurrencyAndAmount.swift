import Foundation
import ComposableArchitecture
import Utils

public struct CurrencyAndAmount {
    public let currency: String
    public let minorUnits: Int

    public init(
        currency: String,
        minorUnits: Int = 0
    ) {
        self.currency = currency
        self.minorUnits = minorUnits
    }
}

extension CurrencyAndAmount: Equatable, Sendable { }

extension CurrencyAndAmount: CustomStringConvertible {
    public var description: String {
        @Dependency(CurrencyAmountFormatter.self) var formatter
        return formatter.format(self.minorUnits, self.currency, .current) ?? "N/A"
    }
}

extension CurrencyAndAmount {
    public static func +(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.currency == rhs.currency, "Can only add 2 amounts with the same currency")
        return .init(currency: lhs.currency, minorUnits: lhs.minorUnits + rhs.minorUnits)
    }
    
    public static func -(lhs: Self, rhs: Self) -> Self {
        precondition(lhs.currency == rhs.currency, "Can only deduce 2 amounts with the same currency")
        return .init(currency: lhs.currency, minorUnits: lhs.minorUnits - rhs.minorUnits)
    }

    public func roundedToNearestHundred() -> CurrencyAndAmount {
        .init(
            currency: self.currency,
            minorUnits: self.minorUnits.roundUpToNearestHundred()
        )
    }
}
