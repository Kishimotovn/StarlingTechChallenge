import Foundation
import AuthClient
import ConfigConstant
import ComposableArchitecture
import Models

public extension APIClient {
    static var live: APIClient {
        @Dependency(ConfigConstant.self) var config

        let restClient = RestClient(baseURL: config.apiBaseURL)

        return .init(
            getAccounts: {
                let requestData = RequestData("api/v2/accounts")
                let response: GetAccountsOutput = try await restClient.request(requestData)
                return response.accounts.compactMap(Account.init)
            },
            getAccountFeed: { accountID, categoryID, interval in
                let requestData = RequestData(
                    "api/v2/feed/account/\(accountID)/category/\(categoryID)/transactions-between",
                    queryItems: [
                        "minTransactionTimestamp": ISO8601DateFormatter.starlingDateFormatter.string(from: interval.start),
                        "maxTransactionTimestamp": ISO8601DateFormatter.starlingDateFormatter.string(from: interval.end)
                    ]
                )
                let response: GetAccountFeedOutput = try await restClient.request(requestData)
                return response.feedItems.compactMap(AccountFeedItem.init)
            },
            getSavingsGoals: { accountID in
                let requestData = RequestData("api/v2/account/\(accountID)/savings-goals")
                let response: GetSavingsGoalsOutput = try await restClient.request(requestData)
                return response.savingsGoalList.compactMap(SavingsGoal.init)
            },
            createSavingsGoal: { accountID, name, currency in
                let input = CreateSavingsGoalInput(name: name, currency: currency)
                let requestData = try RequestData(
                    "api/v2/account/\(accountID)/savings-goals",
                    httpMethod: .put,
                    jsonBody: input
                )
                let response: CreateSavingsGoalOutput = try await restClient.request(requestData)
                guard let goal = SavingsGoal.init(output: response) else {
                    throw AppError(.failedToCreateSavingGoal)
                }
                return goal
            },
            transferToSavingsGoal: { accountID, savingsGoalID, amount in
                @Dependency(\.uuid) var uuid
                
                let randomTransferID = uuid()
                let input = TransferToSavingsGoalInput(amount: amount)
                let requestData = try RequestData(
                    "api/v2/account/\(accountID)/savings-goals/\(savingsGoalID)/add-money/\(randomTransferID.uuidString)",
                    httpMethod: .put,
                    jsonBody: input
                )
                let response: TransferToSavingsGoalOutput = try await restClient.request(requestData)
                return response.success == true
            }
        )
    }
}
