import Foundation

public enum URLConvertibleError: Error {
    case invalidURL
}

public protocol URLConvertible: Equatable {
    func toURL() throws -> URL
}

extension String: URLConvertible {
    public func toURL() throws -> URL {
        guard let url = URL(string: self) else {
            throw URLConvertibleError.invalidURL
        }
        return url
    }
}

extension URL: URLConvertible {
    public func toURL() throws -> URL { self }
}
