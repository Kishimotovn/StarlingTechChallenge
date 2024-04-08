import Foundation

public struct RequestData: Equatable {
    public enum HttpMethod: String, Equatable {
        case get, put, patch, post, delete
    }
    
    let path: String
    let httpMethod: HttpMethod
    let queryItems: [String: String?]
    let headers: [String: String]
    let body: Data?
    
    public init(
        _ path: String,
        httpMethod: HttpMethod = .get,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.httpMethod = httpMethod
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
    
    public static func == (lhs: RequestData, rhs: RequestData) -> Bool {
        return lhs.path == rhs.path
            && lhs.body == rhs.body
            && lhs.headers == rhs.headers
            && lhs.queryItems == rhs.queryItems
            && lhs.httpMethod == rhs.httpMethod
    }
}

extension RequestData {
    public init(
        _ path: String,
        httpMethod: HttpMethod = .get,
        queryItems: [String: String?] = [:],
        headers: [String: String] = [
            HTTPHeader.Key.contentType: HTTPHeader.Value.applicationJSON
        ],
        jsonBody: any Encodable
    ) throws {
        try self.init(
            path,
            httpMethod: httpMethod,
            queryItems: queryItems,
            headers: headers,
            body: JSONEncoder().encode(jsonBody)
        )
    }
    
    func urlRequest(given baseURL: any URLConvertible) throws -> URLRequest {
        let fullURL = try baseURL.toURL().appending(path: self.path)
        guard var urlComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) else {
            throw URLConvertibleError.invalidURL
        }
        
        urlComponents.queryItems = queryItems.map(URLQueryItem.init)
        
        guard let url = urlComponents.url else {
            throw URLConvertibleError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue.uppercased()
        request.httpBody = body
        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        return request
    }
}
