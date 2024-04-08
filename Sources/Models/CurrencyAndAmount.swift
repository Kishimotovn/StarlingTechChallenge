import Foundation

public struct CurrencyAndAmount {
    public let currency: String
    public let minorUnits: Int

    public init(currency: String, minorUnits: Int) {
        self.currency = currency
        self.minorUnits = minorUnits
    }
}

extension CurrencyAndAmount: Equatable, Sendable { }
