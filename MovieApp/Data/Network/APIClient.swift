import Foundation

// MARK: - APIClientProtocol Definition
protocol APIClientProtocol {
    func request<T: Decodable>(urlRequest: URLRequest, completion: @escaping (Result<T, APIError>) -> Void)
    func buildRequest(path: String, method: String, params: [String: String]?) -> URLRequest?
}

class APIClient: APIClientProtocol { // Made APIClient conform to the protocol

    // MARK: - Properties

    // !!!IMPORTANT!!!: This is not a secure way to store an API key.
    // For a production app, this should be stored securely,
    // e.g., in a configuration file not committed to version control,
    // or retrieved from a server-side service.
    static let apiKey = "124e713abb7dfb463142baac075d3e11"

    static let shared = APIClient() // Keep shared instance for default usage
    private let session: URLSession

    // MARK: - Initialization
    // Made init public to allow instantiation where needed, e.g. for the shared instance
    // or if someone wants to create a specific session-configured client.
    // For DI, we usually pass the protocol, so this direct instantiation is less common outside initial setup.
    // Making it internal as 'shared' provides the default, and DI uses the protocol.
    internal init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Request Method

    /// Performs a network request and decodes the response.
    /// - Parameters:
    ///   - urlRequest: The URLRequest to be executed.
    ///   - completion: A closure to be called once the request is complete.
    ///                 It returns a `Result` type with either the decoded data (`T`)
    ///                 or an `APIError`.
    func request<T: Decodable>(urlRequest: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        
        session.dataTask(with: urlRequest) { data, response, error in
            // Handle client-side errors (e.g., network connectivity issues)
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            // Ensure we have an HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(statusCode: 0))) // Or a more specific error
                return
            }

            // Check for successful HTTP status codes
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode)))
                return
            }

            // Ensure data is present
            guard let data = data else {
                // This case should ideally be covered by the HTTP status code check,
                // but as a safeguard:
                completion(.failure(.invalidResponse(statusCode: httpResponse.statusCode))) // Or a new error case e.g., .noData
                return
            }

            // Attempt to decode the JSON response
            do {
                let decoder = JSONDecoder()
                // Convention for converting snake_case keys from API to camelCase
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let decodedObject = try decoder.decode(T.self, from: data)
                completion(.success(decodedObject))
            } catch let decodingError {
                completion(.failure(.decodingError(decodingError)))
            }
        }.resume()
    }
    
    /// Helper to create a URLRequest for The Movie Database (TMDB) API.
    /// - Parameters:
    ///   - path: The endpoint path (e.g., "/movie/popular").
    ///   - method: The HTTP method (default is "GET").
    ///   - params: Optional query parameters for the request.
    /// - Returns: A URLRequest? or nil if URL construction fails.
    func buildRequest(path: String, method: String = "GET", params: [String: String]? = nil) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.themoviedb.org"
        components.path = "/3" + path // API version 3

        var queryItems = [URLQueryItem(name: "api_key", value: APIClient.apiKey)]
        if let params = params {
            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
        }
        components.queryItems = queryItems

        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        // Add any common headers here if needed, e.g.:
        // request.setValue("application/json", forHTTPHeaderField: "Accept")
        // request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return request
    }
}
