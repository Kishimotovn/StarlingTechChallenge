import Foundation
import Models

struct CreateSavingsGoalOutput: Decodable {
    let savingsGoalID: UUID?
    let success: Bool?

    enum CodingKeys: String, CodingKey {
        case savingsGoalID = "savingsGoalUid"
        case success
    }
}

extension SavingsGoal {
    init?(output: CreateSavingsGoalOutput) {
        guard 
            output.success == true,
            let id = output.savingsGoalID
        else {
            return nil
        }
        
        self.init(id: id)
    }
}
