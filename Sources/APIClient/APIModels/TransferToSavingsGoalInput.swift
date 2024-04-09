import Foundation
import Models

struct TransferToSavingsGoalInput: Encodable {
    var amount: CurrencyAndAmount
}

extension CurrencyAndAmount: Encodable {
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.currency, forKey: .currency)
        try container.encode(self.minorUnits, forKey: .minorUnits)
    }
}
