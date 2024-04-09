@testable import Utils
import Foundation
import XCTest

final class IntExtensionsTests: XCTestCase {
    @MainActor
    func testRoundUptoNearestHundred() {
        let initialValues = [
            435,
            520,
            087
        ]
            
        let values = initialValues.map { $0.roundUpToNearestHundred() }
        
        let expected = [
            500,
            600,
            100
        ]
        
        XCTAssertEqual(expected, values)

        let difference = expected.reduce(0, +) - initialValues.reduce(0, +)
        XCTAssertEqual(difference, 158)
    }
}
