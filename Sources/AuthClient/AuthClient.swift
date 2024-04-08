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
