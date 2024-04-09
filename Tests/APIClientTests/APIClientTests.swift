import XCTest
@testable import APIClient
import ComposableArchitecture
import XCTestDebugSupport
import ConfigConstant
import AuthClient

final class APIClientTests: XCTestCase {
    func testGetAccountsRequestFormat() async throws {
        try await withDependencies {
            let mockConfiguration = URLSessionConfiguration.ephemeral
            mockConfiguration.protocolClasses = [MockURLProtocol.self]
            $0.urlSession = URLSession(configuration: mockConfiguration)
            $0[ConfigConstant.self].overrideGetConfig(with: ConfigPlist.init(apiBaseURL: "http://test.com"))
            $0[AuthClient.self].overrideGetAccessToken(with: "token")
        } operation: {
            let client = APIClient.live
            let targetRequestData = RequestData("api/v2/accounts")
            let targetRequest = try targetRequestData.urlRequest(given: "http://test.com")
            let expectation = XCTestExpectation(description: "request intercept expected")
            let expectedHeaders: [String: String] = [
                "Authorization": "Bearer token",
                "User-Agent": "Phan Anh Tran",
                "Accept": "application/json"
            ]
            MockURLProtocol.requestHandler = { request in
                XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
                self.XCTAssertEqualURLs(targetRequest.url, request.url)
                XCTAssertEqual(nil, request.httpBodyStream?.readfully())
                XCTAssertEqual(targetRequest.httpMethod, request.httpMethod)
                expectation.fulfill()
                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
            _ = try? await client.getAccounts()
        }
    }
    
    func testGetAccountFeedRequestFormat() async throws {
        try await withDependencies {
            let mockConfiguration = URLSessionConfiguration.ephemeral
            mockConfiguration.protocolClasses = [MockURLProtocol.self]
            $0.urlSession = URLSession(configuration: mockConfiguration)
            $0[ConfigConstant.self].overrideGetConfig(with: ConfigPlist.init(apiBaseURL: "http://test.com"))
            $0[AuthClient.self].overrideGetAccessToken(with: "token")
        } operation: {
            let client = APIClient.live
            let accountID = "accountID"
            let categoryID = "categoryID"
            let interval = DateInterval(start: Date(), duration: 60*60*24*7)
            let targetRequestData = RequestData(
                "api/v2/feed/account/\(accountID)/category/\(categoryID)/transactions-between",
                queryItems: [
                    "minTransactionTimestamp": ISO8601DateFormatter.starlingDateFormatter.string(from: interval.start),
                    "maxTransactionTimestamp": ISO8601DateFormatter.starlingDateFormatter.string(from: interval.end)
                ]
            )
            let targetRequest = try targetRequestData.urlRequest(given: "http://test.com")
            let expectation = XCTestExpectation(description: "request intercept expected")
            let expectedHeaders: [String: String] = [
                "Authorization": "Bearer token",
                "User-Agent": "Phan Anh Tran",
                "Accept": "application/json"
            ]
            MockURLProtocol.requestHandler = { request in
                XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
                self.XCTAssertEqualURLs(targetRequest.url, request.url)
                XCTAssertEqual(nil, request.httpBodyStream?.readfully())
                XCTAssertEqual(targetRequest.httpMethod, request.httpMethod)
                expectation.fulfill()
                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
            _ = try? await client.getAccountFeed(accountID: accountID, categoryID: categoryID, interval: interval)
        }
    }
    
    func testGetSavingsGoalsRequestFormat() async throws {
        try await withDependencies {
            let mockConfiguration = URLSessionConfiguration.ephemeral
            mockConfiguration.protocolClasses = [MockURLProtocol.self]
            $0.urlSession = URLSession(configuration: mockConfiguration)
            $0[ConfigConstant.self].overrideGetConfig(with: ConfigPlist.init(apiBaseURL: "http://test.com"))
            $0[AuthClient.self].overrideGetAccessToken(with: "token")
        } operation: {
            let client = APIClient.live
            let accountID = "accountID"
            let targetRequestData = RequestData("api/v2/account/\(accountID)/savings-goals")
            let targetRequest = try targetRequestData.urlRequest(given: "http://test.com")
            let expectation = XCTestExpectation(description: "request intercept expected")
            let expectedHeaders: [String: String] = [
                "Authorization": "Bearer token",
                "User-Agent": "Phan Anh Tran",
                "Accept": "application/json"
            ]
            MockURLProtocol.requestHandler = { request in
                XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
                self.XCTAssertEqualURLs(targetRequest.url, request.url)
                XCTAssertEqual(nil, request.httpBodyStream?.readfully())
                XCTAssertEqual(targetRequest.httpMethod, request.httpMethod)
                expectation.fulfill()
                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
            _ = try? await client.getSavingsGoals(accountID: accountID)
        }
    }
    
    func testCreateSavingsGoalRequestFormat() async throws {
        try await withDependencies {
            let mockConfiguration = URLSessionConfiguration.ephemeral
            mockConfiguration.protocolClasses = [MockURLProtocol.self]
            $0.urlSession = URLSession(configuration: mockConfiguration)
            $0[ConfigConstant.self].overrideGetConfig(with: ConfigPlist.init(apiBaseURL: "http://test.com"))
            $0[AuthClient.self].overrideGetAccessToken(with: "token")
        } operation: {
            let client = APIClient.live
            let accountID = "accountID"
            let goalName = "goalName"
            let currency = "currency"
            let input = CreateSavingsGoalInput(name: goalName, currency: currency)
            let targetRequestData = try RequestData(
                "api/v2/account/\(accountID)/savings-goals",
                httpMethod: .put,
                jsonBody: input
            )
            let targetRequest = try targetRequestData.urlRequest(given: "http://test.com")
            let expectation = XCTestExpectation(description: "request intercept expected")
            let expectedHeaders: [String: String] = [
                "Authorization": "Bearer token",
                "User-Agent": "Phan Anh Tran",
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Content-Length": "41"
            ]
            MockURLProtocol.requestHandler = { request in
                XCTAssertEqual(request.allHTTPHeaderFields, expectedHeaders)
                self.XCTAssertEqualURLs(targetRequest.url, request.url)
                let body = request.httpBodyStream!.readfully()
                let decoder = JSONDecoder()
                let requestInput = try! decoder.decode(CreateSavingsGoalInput.self, from: body)
                XCTAssertEqual(input, requestInput)
                XCTAssertEqual(targetRequest.httpMethod, request.httpMethod)
                expectation.fulfill()
                return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, nil)
            }
            _ = try? await client.createSavingsGoal(accountID: accountID, name: goalName, currency: currency)
        }
    }

    private func XCTAssertEqualURLs(_ url1: URL?, _ url2: URL?, file: StaticString = #file, line: UInt = #line) {
        guard let url1 = url1, let url2 = url2 else {
            return XCTFail("One or both URLs are nil", file: file, line: line)
        }
        
        guard let components1 = URLComponents(url: url1, resolvingAgainstBaseURL: false),
              let components2 = URLComponents(url: url2, resolvingAgainstBaseURL: false) else {
            return XCTFail("Could not create URLComponents from URLs", file: file, line: line)
        }
        
        guard components1.scheme == components2.scheme,
              components1.host == components2.host,
              components1.path == components2.path,
              components1.port == components2.port else {
            return XCTFail("URL components do not match", file: file, line: line)
        }
        
        // Sort query items by name (and value if names are equal) before comparison
        let queryItems1 = components1.queryItems?.sorted(by: {
            $0.name < $1.name || ($0.name == $1.name && $0.value ?? "" < $1.value ?? "")
        })
        let queryItems2 = components2.queryItems?.sorted(by: {
            $0.name < $1.name || ($0.name == $1.name && $0.value ?? "" < $1.value ?? "")
        })
        
        XCTAssertEqual(queryItems1, queryItems2, "Query items do not match", file: file, line: line)
    }

}

extension CreateSavingsGoalInput: Decodable, Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && lhs.currency == rhs.currency
    }

    enum CodingKeys: String, CodingKey {
        case name
        case currency
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let currency = try container.decode(String.self, forKey: .currency)
        self.init(name: name, currency: currency)
    }
}

extension InputStream {
    func readfully() -> Data {
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        open()
        
        var amount = 0
        repeat {
            amount = read(&buffer, maxLength: buffer.count)
            if amount > 0 {
                result.append(buffer, count: amount)
            }
        } while amount > 0
        
        close()
        
        return result
    }
}

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Handler is not set.")
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
}
