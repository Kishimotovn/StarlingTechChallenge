import Foundation

public enum HTTPHeader {
    public enum Key {
        public static let contentType = "Content-Type"
        public static let authorization = "Authorization"
    }
    
    public enum Value {
        public static let applicationJSON = "application/json"
        public static func bearer(jwt: String) -> String { "Bearer \(jwt)" }
    }
}
