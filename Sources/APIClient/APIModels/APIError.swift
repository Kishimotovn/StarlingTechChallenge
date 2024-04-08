import Foundation

public struct APIError: Error {
    public let code: Int
    let response: ErrorResponse?
    
    struct ErrorResponse: Decodable {
        struct ErrorDetails: Decodable {
            let message: String
        }
        let errors: [ErrorDetails]
        let success: Bool
    }
}

extension APIError {
    init?(response: URLResponse, data: Data) {
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 else {
            return nil
        }

        self.code = httpResponse.statusCode
        self.response = try? JSONDecoder().decode(APIError.ErrorResponse.self, from: data)
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        var infos = [String]()

        infos.append("APIError code: \(self.code)")
        if let response {
            let errorMessages = response.errors.map(\.message).joined(separator: ", ")
            infos.append("Errors: \(errorMessages)")
        }

        return infos.joined(separator: " | ")
    }
}
