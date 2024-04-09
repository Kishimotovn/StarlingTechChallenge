import Foundation

public extension Int {
    func roundUpToNearestHundred() -> Int {
        return ((self + 99) / 100) * 100
    }
}
