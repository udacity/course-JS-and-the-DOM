import Foundation
// We need to import the main module to access MovieRepositoryProtocol, PaginatedResponse, Movie, APIError
// The actual name of the module is 'MovieApp' based on the project structure.
// If tests are part of the same module, this import might not be strictly needed for types,
// but it's good practice for clarity and when dealing with access control (e.g., public vs internal).
@testable import MovieApp

// Dummy Error for testing
enum TestError: Error, Equatable {
    case genericError
}

class MockMovieRepository: MovieRepositoryProtocol {

    // MARK: - Properties for getNowPlayingMovies
    var getNowPlayingMoviesResult: Result<PaginatedResponse<Movie>, Error>?
    var getNowPlayingMoviesCalled: Bool = false
    var getNowPlayingMoviesLastPageFetched: Int?

    // MARK: - Properties for getPopularMovies
    var getPopularMoviesResult: Result<PaginatedResponse<Movie>, Error>?
    var getPopularMoviesCalled: Bool = false
    var getPopularMoviesLastPageFetched: Int?

    // MARK: - Properties for getUpcomingMovies
    var getUpcomingMoviesResult: Result<PaginatedResponse<Movie>, Error>?
    var getUpcomingMoviesCalled: Bool = false
    var getUpcomingMoviesLastPageFetched: Int?

    // MARK: - Properties for getMovieDetails
    var getMovieDetailsResult: Result<Movie, Error>?
    var getMovieDetailsCalled: Bool = false
    var getMovieDetailsLastIdFetched: Int?

    // MARK: - Method Implementations

    func getNowPlayingMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        getNowPlayingMoviesCalled = true
        getNowPlayingMoviesLastPageFetched = page
        if let result = getNowPlayingMoviesResult {
            completion(result)
        } else {
            // Default behavior or fatal error if not set, to ensure tests configure it.
            fatalError("getNowPlayingMoviesResult was not set in MockMovieRepository")
        }
    }

    func getPopularMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        getPopularMoviesCalled = true
        getPopularMoviesLastPageFetched = page
        if let result = getPopularMoviesResult {
            completion(result)
        } else {
            fatalError("getPopularMoviesResult was not set in MockMovieRepository")
        }
    }

    func getUpcomingMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        getUpcomingMoviesCalled = true
        getUpcomingMoviesLastPageFetched = page
        if let result = getUpcomingMoviesResult {
            completion(result)
        } else {
            fatalError("getUpcomingMoviesResult was not set in MockMovieRepository")
        }
    }

    func getMovieDetails(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        getMovieDetailsCalled = true
        getMovieDetailsLastIdFetched = id
        if let result = getMovieDetailsResult {
            completion(result)
        } else {
            fatalError("getMovieDetailsResult was not set in MockMovieRepository")
        }
    }

    // MARK: - Helper to reset state
    func reset() {
        getNowPlayingMoviesResult = nil
        getNowPlayingMoviesCalled = false
        getNowPlayingMoviesLastPageFetched = nil

        getPopularMoviesResult = nil
        getPopularMoviesCalled = false
        getPopularMoviesLastPageFetched = nil

        getUpcomingMoviesResult = nil
        getUpcomingMoviesCalled = false
        getUpcomingMoviesLastPageFetched = nil

        getMovieDetailsResult = nil
        getMovieDetailsCalled = false
        getMovieDetailsLastIdFetched = nil
    }
    
    // MARK: - Sample Data (Convenient for tests)
    
    static func createSampleMovie(id: Int, title: String = "Sample Movie") -> Movie {
        return Movie(id: id, title: title, releaseDate: "2023-01-01", posterPath: "/sample.jpg", overview: "This is a sample overview.", genres: [Genre(id: 1, name: "Action")], runtime: 120, popularity: 8.0, voteAverage: 7.5, voteCount: 100)
    }
    
    static func createSamplePaginatedResponse(page: Int = 1, totalPages: Int = 5, totalResults: Int = 100, movies: [Movie]? = nil) -> PaginatedResponse<Movie> {
        let sampleMovies = movies ?? [
            createSampleMovie(id: 1, title: "Movie 1 in Page \(page)"),
            createSampleMovie(id: 2, title: "Movie 2 in Page \(page)")
        ]
        return PaginatedResponse<Movie>(
            page: page,
            results: sampleMovies,
            totalPages: totalPages,
            totalResults: totalResults
        )
    }
}
