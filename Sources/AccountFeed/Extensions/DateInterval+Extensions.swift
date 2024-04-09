import Foundation

extension DateInterval {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM YYYY"
        return formatter
    }()

    func formated() -> String {
        let startDate = Self.dateFormatter.string(from: self.start)
        let endDate = Self.dateFormatter.string(from: self.end)
        return "\(startDate) - \(endDate)"
    }
}
