import Foundation

public struct SavingsGoal: Identifiable {
    public let id: UUID

    public init(id: UUID) {
        self.id = id
    }
}

extension SavingsGoal: Equatable { }
