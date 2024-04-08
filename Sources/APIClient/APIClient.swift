import Foundation
import ComposableArchitecture

@DependencyClient
public struct APIClient {
    public var getAccounts: @Sendable () async throws -> [Account]
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
}
#endif
