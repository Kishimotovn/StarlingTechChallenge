import Foundation

public extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear, .timeZone], from: self)
        return calendar.date(from: components)
    }
}
