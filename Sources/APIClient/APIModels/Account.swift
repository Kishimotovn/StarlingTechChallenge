import Foundation

public struct Account: Decodable, Identifiable {
    public enum AccountType: String, Decodable {
        case primary = "PRIMARY"
        case additional = "ADDITIONAL"
        case loan = "LOAN"
        case fixedTermDeposit = "FIXED_TERM_DEPOSIT"
    }
    public let id: String
    public let accountType: AccountType
    public let defaultCategory: String
    public let createdAt: Date
    public let name: String
    public let currency: String

    enum CodingKeys: String, CodingKey {
        case id = "accountUid"
        case accountType
        case defaultCategory
        case createdAt
        case name
        case currency
    }

    public init(
        accountID: String,
        accountType: AccountType,
        defaultCategory: String,
        createdAt: Date,
        name: String,
        currency: String = "GBP"
    ) {
        self.id = accountID
        self.accountType = accountType
        self.defaultCategory = defaultCategory
        self.createdAt = createdAt
        self.name = name
        self.currency = currency
    }
}

extension Account: Equatable { }
