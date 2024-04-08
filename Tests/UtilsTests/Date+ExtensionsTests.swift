@testable import Utils
import Foundation
import XCTest

extension ISO8601DateFormatter {
    static let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
}

final class DateExtensionsTests: XCTestCase {
    @MainActor
    func testStartOfWeek() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        calendar.timeZone = .gmt

        let dates = [
            "2024-04-10", // middle of week
            "2024-04-08", // start of week
            "2024-04-14" // end of week
        ].map {
            ISO8601DateFormatter.isoDateFormatter.date(from: $0)!
        }.map {
            $0.startOfWeek(using: calendar)
        }

        let expectedDates = [
            "2024-04-08",
            "2024-04-08",
            "2024-04-08"
        ].map {
            ISO8601DateFormatter.isoDateFormatter.date(from: $0)!
        }

        XCTAssertEqual(dates, expectedDates)
    }
}
