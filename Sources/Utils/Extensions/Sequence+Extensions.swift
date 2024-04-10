import Foundation

public extension Collection where Index == Int {
    func get(at index: Int) -> Element? {
        guard self.count > index else { return nil }
        return self[index]
    }
}
