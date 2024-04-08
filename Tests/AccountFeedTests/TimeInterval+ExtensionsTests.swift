import Foundation
@testable import AccountFeed
import XCTest

final class TimeIntervalExtensionsTests: XCTestCase {
    func testConstants() {
        XCTAssertEqual(TimeInterval.oneDay, 60*60*24)
        XCTAssertEqual(TimeInterval.oneWeek, 60*60*24*7)
    }
}
