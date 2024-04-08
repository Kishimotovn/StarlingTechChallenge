import Foundation
import Models

struct GetAccountsOutput: Decodable {
    struct Account: Decodable {
        public enum AccountType: String, Decodable {
            case primary = "PRIMARY"
            case additional = "ADDITIONAL"
            case loan = "LOAN"
            case fixedTermDeposit = "FIXED_TERM_DEPOSIT"
        }
        public let accountID: UUID?
        public let accountType: AccountType?
        public let defaultCategory: String?
        public let createdAt: Date?
        public let name: String?
        public let currency: String?
        
        enum CodingKeys: String, CodingKey {
            case accountID = "accountUid"
            case accountType
            case defaultCategory
            case createdAt
            case name
            case currency
        }
    }

    let accounts: [GetAccountsOutput.Account]
}

extension Models.Account {
    init?(from account: GetAccountsOutput.Account) {
        guard
            let id = account.accountID,
            let rawAccountType = account.accountType,
            let accountType = AccountType(from: rawAccountType),
            let defaultCategory = account.defaultCategory,
            let createdAt = account.createdAt,
            let name = account.name,
            let currency = account.currency
        else {
            return nil
        }
        
        self.init(
            accountID: id,
            accountType: accountType,
            defaultCategory: defaultCategory,
            createdAt: createdAt,
            name: name,
            currency: currency
        )
    }
}

extension Models.Account.AccountType {
    init?(from accountType: GetAccountsOutput.Account.AccountType) {
        self.init(rawValue: accountType.rawValue)
    }
}
