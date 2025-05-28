import Foundation

// APIClientProtocol (and APIClient) are expected to be in Data/Network
// MovieRepositoryProtocol is expected to be in Domain/Interfaces/Repositories
// PaginatedResponse, Movie, APIError are expected to be defined appropriately

class MovieRepository: MovieRepositoryProtocol {

    private let apiClient: APIClientProtocol
    private let userDefaults: UserDefaults

    // Cache Keys
    private static let nowPlayingCacheKey = "nowPlayingMoviesCache"
    private static let popularCacheKey = "popularMoviesCache"
    private static let upcomingCacheKey = "upcomingMoviesCache"
    private static func movieDetailCacheKey(id: Int) -> String { "movieDetailCache_\(id)" }

    init(apiClient: APIClientProtocol = APIClient.shared, userDefaults: UserDefaults = .standard) {
        self.apiClient = apiClient
        self.userDefaults = userDefaults
    }

    // MARK: - Caching Helper Methods
    private func cacheData<T: Encodable>(_ data: T, forKey key: String) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            userDefaults.set(encodedData, forKey: key)
        } catch {
            // Log error or handle it as appropriate for your app
            print("Caching error: Failed to encode data for key \(key). Error: \(error)")
        }
    }

    private func loadData<T: Decodable>(forKey key: String) -> T? {
        guard let savedData = userDefaults.data(forKey: key) else {
            return nil
        }
        do {
            let decodedData = try JSONDecoder().decode(T.self, from: savedData)
            return decodedData
        } catch {
            print("Caching error: Failed to decode data for key \(key). Error: \(error)")
            // Consider removing corrupted data: userDefaults.removeObject(forKey: key)
            return nil
        }
    }

    // MARK: - Data Fetching Methods with Caching

    func getNowPlayingMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        let cacheKey = MovieRepository.nowPlayingCacheKey
        let cachedResponse: PaginatedResponse<Movie>? = loadData(forKey: cacheKey)
        
        let path = "/movie/now_playing"
        let params = ["page": String(page)]

        guard let urlRequest = apiClient.buildRequest(path: path, params: params) else {
        guard let urlRequest = apiClient.buildRequest(path: path, params: params) else {
        guard let urlRequest = apiClient.buildRequest(path: path, params: params) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        apiClient.request(urlRequest: urlRequest) { [weak self] (result: Result<PaginatedResponse<Movie>, APIError>) in
            guard let self = self else { return }
            switch result {
            case .success(let networkResponse):
                self.cacheData(networkResponse, forKey: cacheKey)
                completion(.success(networkResponse))
            case .failure(let error):
                if let cachedData = cachedResponse {
                    completion(.success(cachedData))
                } else {
                    completion(.failure(error as Error))
                }
            }
        }
    }

    func getPopularMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        let cacheKey = MovieRepository.popularCacheKey
        let cachedResponse: PaginatedResponse<Movie>? = loadData(forKey: cacheKey)

        let path = "/movie/popular"
        let params = ["page": String(page)]

        guard let urlRequest = apiClient.buildRequest(path: path, method: "GET", params: params) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        apiClient.request(urlRequest: urlRequest) { [weak self] (result: Result<PaginatedResponse<Movie>, APIError>) in
            guard let self = self else { return }
            switch result {
            case .success(let networkResponse):
                self.cacheData(networkResponse, forKey: cacheKey)
                completion(.success(networkResponse))
            case .failure(let error):
                if let cachedData = cachedResponse {
                    completion(.success(cachedData))
                } else {
                    completion(.failure(error as Error))
                }
            }
        }
    }

    func getUpcomingMovies(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        let cacheKey = MovieRepository.upcomingCacheKey
        let cachedResponse: PaginatedResponse<Movie>? = loadData(forKey: cacheKey)

        let path = "/movie/upcoming"
        let params = ["page": String(page)]

        guard let urlRequest = apiClient.buildRequest(path: path, method: "GET", params: params) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        apiClient.request(urlRequest: urlRequest) { [weak self] (result: Result<PaginatedResponse<Movie>, APIError>) in
            guard let self = self else { return }
            switch result {
            case .success(let networkResponse):
                self.cacheData(networkResponse, forKey: cacheKey)
                completion(.success(networkResponse))
            case .failure(let error):
                if let cachedData = cachedResponse {
                    completion(.success(cachedData))
                } else {
                    completion(.failure(error as Error))
                }
            }
        }
    }

    func getMovieDetails(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        let cacheKey = MovieRepository.movieDetailCacheKey(id: id)
        let cachedMovie: Movie? = loadData(forKey: cacheKey)

        let path = "/movie/\(id)"

        guard let urlRequest = apiClient.buildRequest(path: path, params: nil) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        apiClient.request(urlRequest: urlRequest) { [weak self] (result: Result<Movie, APIError>) in
            guard let self = self else { return }
            switch result {
            case .success(let networkMovie):
                self.cacheData(networkMovie, forKey: cacheKey)
                completion(.success(networkMovie))
            case .failure(let error):
                if let cachedData = cachedMovie {
                    completion(.success(cachedData))
                } else {
                    completion(.failure(error as Error))
                }
            }
        }
    }
}
