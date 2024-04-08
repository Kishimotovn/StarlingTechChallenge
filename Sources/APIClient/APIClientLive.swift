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
                    "api/v2/feed/account/\(accountID)/category/\(categoryID)",
                    queryItems: [
                        "minTransactionTimestamp": ISO8601DateFormatter.starlingDateFormatter.string(from: interval.start),
                        "maxTransactionTimestamp": ISO8601DateFormatter.starlingDateFormatter.string(from: interval.end)
                    ]
                )
                let response: GetAccountFeedOutput = try await restClient.request(requestData)
                return response.feedItems.compactMap(AccountFeedItem.init)
            }
        )
    }
}
