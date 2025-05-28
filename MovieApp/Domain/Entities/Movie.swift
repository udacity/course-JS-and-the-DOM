import Foundation

// MARK: - Genre

struct Genre: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
}

// MARK: - Movie

struct Movie: Decodable, Identifiable, Hashable {
    let id: Int
    let title: String
    let releaseDate: String?
    let posterPath: String?
    let overview: String?
    let genres: [Genre]? // This will be populated if fetching movie details
    let runtime: Int?
    let popularity: Double?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case releaseDate = "release_date"
        case posterPath = "poster_path"
        case overview
        case genres
        case runtime
        case popularity
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }

    var posterURL: URL? {
        guard let path = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
}

// MARK: - PaginatedResponse

struct PaginatedResponse<T: Decodable>: Decodable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// Example Usage (for compilation check, can be removed later)
/*
struct MovieService {
    func fetchPopularMovies(completion: @escaping (Result<PaginatedResponse<Movie>, APIError>) -> Void) {
        guard let urlRequest = APIClient.shared.buildRequest(path: "/movie/popular") else {
            completion(.failure(.invalidURL))
            return
        }
        APIClient.shared.request(urlRequest: urlRequest, completion: completion)
    }

    func fetchMovieDetails(movieId: Int, completion: @escaping (Result<Movie, APIError>) -> Void) {
        guard let urlRequest = APIClient.shared.buildRequest(path: "/movie/\(movieId)") else {
            completion(.failure(.invalidURL))
            return
        }
        APIClient.shared.request(urlRequest: urlRequest, completion: completion)
    }
}
*/
