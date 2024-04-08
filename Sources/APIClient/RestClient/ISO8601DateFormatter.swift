import Foundation

extension ISO8601DateFormatter {
    static let starlingDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withFullTime, .withFractionalSeconds, .withTimeZone]
        return formatter
    }()
}
