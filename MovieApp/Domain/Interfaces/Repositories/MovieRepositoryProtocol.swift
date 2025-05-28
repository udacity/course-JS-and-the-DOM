import Foundation

// Note: PaginatedResponse and Movie types are expected to be defined in Domain/Entities

/// Protocol defining the contract for fetching movie data.
protocol MovieRepositoryProtocol {
    /// Fetches a list of movies currently playing in theaters.
    /// - Parameters:
    ///   - page: The page number to fetch.
    ///   - completion: A closure to be called with the result, either a `PaginatedResponse<Movie>` or an `Error`.
    func getNowPlayingMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void)

    /// Fetches a list of popular movies.
    /// - Parameters:
    ///   - page: The page number to fetch.
    ///   - completion: A closure to be called with the result, either a `PaginatedResponse<Movie>` or an `Error`.
    func getPopularMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void)

    /// Fetches a list of upcoming movies.
    /// - Parameters:
    ///   - page: The page number to fetch.
    ///   - completion: A closure to be called with the result, either a `PaginatedResponse<Movie>` or an `Error`.
    func getUpcomingMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void)

    /// Fetches the details for a specific movie.
    /// - Parameters:
    ///   - id: The ID of the movie to fetch details for.
    ///   - completion: A closure to be called with the result, either a `Movie` object or an `Error`.
    func getMovieDetails(id: Int, completion: @escaping (Result<Movie, Error>) -> Void)
}
