import Foundation

enum APIError: Error {
    case networkError(Error)
    case invalidResponse(statusCode: Int)
    case decodingError(Error)
    case invalidURL
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Invalid response with status code: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .invalidURL:
            return "The provided URL was invalid."
        }
    }
}
