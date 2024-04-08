import Foundation

public struct Account: Decodable {
    public enum AccountType: String, Decodable {
        case primary = "PRIMARY"
        case additional = "ADDITIONAL"
        case loan = "LOAN"
        case fixedTermDeposit = "FIXED_TERM_DEPOSIT"
    }
    public let accountID: String
    public let accountType: AccountType
    public let defaultCategory: String
    public let createdAt: Date
    public let name: String

    enum CodingKeys: String, CodingKey {
        case accountID = "accountUid"
        case accountType
        case defaultCategory
        case createdAt
        case name
    }

    public init(
        accountID: String,
        accountType: AccountType,
        defaultCategory: String,
        createdAt: Date,
        name: String
    ) {
        self.accountID = accountID
        self.accountType = accountType
        self.defaultCategory = defaultCategory
        self.createdAt = createdAt
        self.name = name
    }
}

extension Account: Equatable { }
