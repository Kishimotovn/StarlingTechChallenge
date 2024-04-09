import Foundation
@testable import Utils
import XCTest

final class CurrencyAmountFormatterTests: XCTestCase {
    @MainActor
    func testFormat() {
        let formatter = CurrencyAmountFormatter.live
        
        let minorUnits = 2347
        let currency = "GBP"
        let expected = "£23.47"
        let locale = Locale(identifier: "en_GB")
        
        XCTAssertEqual(formatter.format(minorUnit: minorUnits, currency: currency, locale: locale), expected)
    }
}

