import Foundation

public struct Account: Identifiable {
    public enum AccountType: String {
        case primary = "PRIMARY"
        case additional = "ADDITIONAL"
        case loan = "LOAN"
        case fixedTermDeposit = "FIXED_TERM_DEPOSIT"
    }

    public let id: UUID
    public let accountType: AccountType
    public let defaultCategory: String
    public let createdAt: Date
    public let name: String
    public let currency: String // Too lazy to convert to enum

    public init(
        accountID: UUID,
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

extension Account.AccountType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .primary: "Primary"
        case .additional: "Additional"
        case .fixedTermDeposit: "Fixed Term Deposit"
        case .loan: "Loan"
        }
    }
}

extension Account: Equatable { }
