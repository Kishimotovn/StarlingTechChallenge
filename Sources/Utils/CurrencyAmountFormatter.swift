import Foundation
import ComposableArchitecture

@DependencyClient
public struct CurrencyAmountFormatter {
    public var format: @Sendable (_ minorUnit: Int, _ currency: String, _ locale: Locale) -> String?
}

extension CurrencyAmountFormatter: DependencyKey {
    public static var liveValue: CurrencyAmountFormatter = .live
    public static var testValue: CurrencyAmountFormatter = .live
}

extension CurrencyAmountFormatter {
    static var live: Self {
        .init { minorUnit, currency, locale in
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = currency
            formatter.locale = locale

            /* This is assumption */
            let amount = Decimal(minorUnit) / Decimal(100)
            return formatter.string(from: amount as NSDecimalNumber)
        }
    }
}
