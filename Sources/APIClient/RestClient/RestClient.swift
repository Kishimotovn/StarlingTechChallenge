import Foundation
import AuthClient
import ComposableArchitecture

actor RestClient {
    let baseURL: any URLConvertible

    init(baseURL: any URLConvertible) {
        self.baseURL = baseURL
    }

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            let formatter = ISO8601DateFormatter.starlingDateFormatter
            guard let date = formatter.date(from: value) else {
                throw RestClientError.invalidDateFormat(value: value)
            }
            return date
        })
        return decoder
    }()

    @Sendable func request(_ requestData: RequestData) async throws -> (Data, URLResponse) {
        var request = try requestData.urlRequest(given: self.baseURL)
        await self.addHeaders(for: &request)
        let (data, response) = try await URLSession.shared.data(for: request)
        if let error = APIError(response: response, data: data) {
            throw error
        }
        return (data, response)
    }

    /**
    Headers as per requirements
     */
    private func addHeaders(for request: inout URLRequest) async {
        @Dependency(AuthClient.self) var authClient

        if let accessToken = await authClient.getAccessToken() {
            request.setValue(
                HTTPHeader.Value.bearer(jwt: accessToken),
                forHTTPHeaderField: HTTPHeader.Key.authorization
            )
        }

        request.setValue(
            HTTPHeader.Key.accept,
            forHTTPHeaderField: HTTPHeader.Value.applicationJSON
        )

        request.setValue(
            HTTPHeader.Key.userAgent,
            forHTTPHeaderField: HTTPHeader.Value.userAgent
        )
    }
}

extension RestClient {
    func request<T: Decodable>(_ requestData: RequestData) async throws -> T {
        let (data, _) = try await self.request(requestData)
        return try self.decoder.decode(T.self, from: data)
    }
}

enum RestClientError: Error {
    case invalidDateFormat(value: String)
}
