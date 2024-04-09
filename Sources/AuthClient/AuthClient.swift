import Foundation
import ComposableArchitecture

@DependencyClient
public struct AuthClient {
    public var getAccessToken: @Sendable () async -> String?
}

extension AuthClient: DependencyKey {
    public static var testValue: AuthClient = .init()
    public static var previewValue: AuthClient = .init()
    public static var liveValue: AuthClient = .live
}

#if DEBUG
import XCTestDebugSupport

extension AuthClient {
    public mutating func overrideGetAccessToken(
        with token: String
    ) {
        let fulfill = expectation(description: "getAccessToken Called")
        self.getAccessToken = {
            fulfill()
            return token
        }
    }
}
#endif
