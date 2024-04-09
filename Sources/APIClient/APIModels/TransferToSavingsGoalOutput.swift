import Foundation

struct TransferToSavingsGoalOutput: Decodable {
    let transferID: UUID
    let success: Bool?

    enum CodingKeys: String, CodingKey {
        case transferID = "transferUid"
        case success
    }
}
