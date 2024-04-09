import Foundation
@testable import APIClient
import XCTest

class RequestDataTests: XCTestCase {
    func testRequestDataInitialization() {
        let path = "/test"
        let httpMethod = RequestData.HttpMethod.get
        let queryItems = ["key": "value"]
        let headers = ["Content-Type": "application/json"]
        let bodyData = "Test body".data(using: .utf8)
        
        let requestData = RequestData(path, httpMethod: httpMethod, queryItems: queryItems, headers: headers, body: bodyData)
        
        XCTAssertEqual(requestData.path, path)
        XCTAssertEqual(requestData.httpMethod, httpMethod)
        XCTAssertEqual(requestData.queryItems, queryItems)
        XCTAssertEqual(requestData.headers, headers)
        XCTAssertEqual(requestData.body, bodyData)
    }
    
    func testRequestDataEquality() {
        let requestData1 = RequestData("/test", httpMethod: .post, queryItems: ["key": "value"], headers: ["Header": "Value"], body: nil)
        let requestData2 = RequestData("/test", httpMethod: .post, queryItems: ["key": "value"], headers: ["Header": "Value"], body: nil)
        
        XCTAssertEqual(requestData1, requestData2)
    }
    
    func testURLRequestCreation() throws {
        let path = "/test"
        let requestData = RequestData(path, queryItems: ["key": "value"], headers: ["Authorization": "Bearer token"])
        
        let request = try requestData.urlRequest(given: "https://example.com")
        
        XCTAssertEqual(request.url?.absoluteString, "https://example.com/test?key=value")
        XCTAssertEqual(request.allHTTPHeaderFields?["Authorization"], "Bearer token")
        XCTAssertEqual(request.httpMethod, "GET")
    }
    
    // Test initialization with JSON body
    func testRequestDataWithJSONBody() throws {
        struct MockEncodable: Codable {
            let key: String
        }
        
        let encodableBody = MockEncodable(key: "value")
        let requestData = try RequestData("/test", httpMethod: .post, jsonBody: encodableBody)
        let request = try requestData.urlRequest(given: "https://example.com")
        
        // Decode the body back to compare
        let decodedBody = try JSONDecoder().decode(MockEncodable.self, from: request.httpBody!)
        XCTAssertEqual(decodedBody.key, "value")
        XCTAssertEqual(request.httpMethod, "POST")
    }
}
