import Foundation
import ComposableArchitecture
import Models

@DependencyClient
public struct APIClient {
    public var getAccounts: @Sendable () async throws -> [Account]
    public var getAccountFeed: @Sendable (_ accountID: String, _ categoryID: String, _ interval: DateInterval) async throws -> [AccountFeedItem]
}

extension APIClient: DependencyKey {
    public static var testValue: APIClient = .init()
    public static var previewValue: APIClient = .init()
    public static var liveValue: APIClient = .live
}

#if DEBUG
import XCTestDebugSupport

extension APIClient {
    public mutating func overrideGetAccounts(
        with accounts: [Account],
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "getAccountsAPI Called")
        self.getAccounts = {
            fulfill()
            if let error {
                throw error
            }
            return accounts
        }
    }

    public mutating func overrideGetAccountFeed(
        accountID: String,
        categoryID: String,
        interval: DateInterval,
        response: [AccountFeedItem],
        throwing error: Error? = nil
    ) {
        let fulfill = expectation(description: "getAccountFeedAPI Called")
        self.getAccountFeed = { @Sendable [self] requestAccountID, requestCategoryID, requestInterval in
            guard 
                requestAccountID == accountID,
                requestCategoryID == categoryID,
                requestInterval == interval
            else {
                return try await self.getAccountFeed(accountID: requestAccountID, categoryID: requestCategoryID, interval: requestInterval)
            }
            fulfill()
            if let error {
                throw error
            }
            return response
        }
    }
}
#endif
