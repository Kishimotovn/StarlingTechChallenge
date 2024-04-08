import Foundation
import AuthClient
import ConfigConstant
import ComposableArchitecture

public extension APIClient {
    static var live: APIClient {
        @Dependency(ConfigConstant.self) var config

        let restClient = RestClient(baseURL: config.apiBaseURL)

        return .init(
            getAccounts: {
                let requestData = RequestData("api/v2/accounts")
                let response: Accounts = try await restClient.request(requestData)
                return response.accounts
            }
        )
    }
}
