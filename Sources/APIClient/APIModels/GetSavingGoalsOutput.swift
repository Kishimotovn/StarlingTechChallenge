import Foundation
import Models

struct GetSavingsGoalsOutput: Decodable {
    struct SavingsGoal: Decodable {
        var savingsGoalID: UUID?
        var name: String?
        var target: CurrencyAndAmount?
        var totalSaved: CurrencyAndAmount?
        var savedPercentage: Int?
        var state: State

        enum State: String, Decodable {
            case creating = "CREATING"
            case active = "ACTIVE"
            case archiving = "ARCHIVING"
            case archived = "ARCHIVED"
            case restoring = "RESTORING"
            case pending = "PENDING"
        }

        enum CodingKeys: String, CodingKey {
            case savingsGoalID = "savingsGoalUid"
            case name
            case target
            case totalSaved
            case savedPercentage
            case state
        }
    }

    let savingsGoalList: [SavingsGoal]
}

extension Models.SavingsGoal {
    init?(goal: GetSavingsGoalsOutput.SavingsGoal) {
        guard let id = goal.savingsGoalID else { return nil }
        self.init(id: id)
    }
}
