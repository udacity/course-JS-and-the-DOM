import Foundation
@testable import MovieApp // To access APIClientProtocol, APIError, PaginatedResponse, Movie

class MockAPIClient: APIClientProtocol {

    // MARK: - Properties for buildRequest
    var buildRequestCalled: Bool = false
    var buildRequestPathArg: String?
    var buildRequestMethodArg: String?
    var buildRequestParamsArg: [String: String]?
    var buildRequestReturnValue: URLRequest? = URLRequest(url: URL(string: "https://dummy.url/path")!) // Default dummy request

    // MARK: - Properties for request
    var requestCalled: Bool = false
    var requestURLRequestArg: URLRequest?
    
    // We need separate result properties for each type of expected Decodable,
    // as the generic T cannot be directly stored with a specific type.
    var paginatedMovieResponseResult: Result<PaginatedResponse<Movie>, APIError>?
    var movieDetailResult: Result<Movie, APIError>?

    // MARK: - Method Implementations

    func buildRequest(path: String, method: String, params: [String: String]?) -> URLRequest? {
        buildRequestCalled = true
        buildRequestPathArg = path
        buildRequestMethodArg = method
        buildRequestParamsArg = params
        return buildRequestReturnValue
    }

    func request<T: Decodable>(urlRequest: URLRequest, completion: @escaping (Result<T, APIError>) -> Void) {
        requestCalled = true
        requestURLRequestArg = urlRequest

        // Determine which mock result to use based on T
        if T.self == PaginatedResponse<Movie>.self, let result = paginatedMovieResponseResult as? Result<T, APIError> {
            completion(result)
        } else if T.self == Movie.self, let result = movieDetailResult as? Result<T, APIError> {
            completion(result)
        } else {
            // Fallback or fatal error if the mock result for type T is not set
            // This indicates a test setup issue.
            fatalError("MockAPIClient.request called with type \(T.self) but no mock result was set for this type.")
        }
    }

    // MARK: - Helper to reset state
    func reset() {
        buildRequestCalled = false
        buildRequestPathArg = nil
        buildRequestMethodArg = nil
        buildRequestParamsArg = nil
        buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/path")!) // Reset to default

        requestCalled = false
        requestURLRequestArg = nil
        
        paginatedMovieResponseResult = nil
        movieDetailResult = nil
    }
    
    // MARK: - Sample Data (Convenience for tests, can be shared or moved)
    // Using sample data from MockMovieRepository to avoid duplication for now.
    // In a larger project, these might live in a shared test utilities file.
    static func createSampleMovie(id: Int, title: String = "Sample Movie") -> Movie {
        return MockMovieRepository.createSampleMovie(id: id, title: title)
    }
    
    static func createSamplePaginatedResponse(page: Int = 1, movies: [Movie]? = nil) -> PaginatedResponse<Movie> {
        return MockMovieRepository.createSamplePaginatedResponse(page: page, movies: movies)
    }
}
