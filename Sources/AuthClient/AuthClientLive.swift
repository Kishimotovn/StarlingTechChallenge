import Foundation

public extension AuthClient {
    static var live: AuthClient {
        .init(
            getAccessToken: {
                return ""
            }
        )
    }
}
