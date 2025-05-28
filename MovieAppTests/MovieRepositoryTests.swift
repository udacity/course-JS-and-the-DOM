import XCTest
@testable import MovieApp

class MovieRepositoryTests: XCTestCase {

    var mockAPIClient: MockAPIClient!
    var movieRepository: MovieRepository!
    var testUserDefaults: UserDefaults!

    // Cache Keys (mirrored for direct cache inspection in tests)
    private static let nowPlayingCacheKey = "nowPlayingMoviesCache"
    private static let popularCacheKey = "popularMoviesCache"
    private static let upcomingCacheKey = "upcomingMoviesCache"
    private static func movieDetailCacheKey(id: Int) -> String { "movieDetailCache_\(id)" }


    override func setUpWithError() throws {
        try super.setUpWithError()
        mockAPIClient = MockAPIClient()
        // Use a specific suite for testing to avoid interfering with app's UserDefaults
        let suiteName = #file
        testUserDefaults = UserDefaults(suiteName: suiteName)
        movieRepository = MovieRepository(apiClient: mockAPIClient, userDefaults: testUserDefaults)
    }

    override func tearDownWithError() throws {
        mockAPIClient.reset()
        mockAPIClient = nil
        movieRepository = nil
        // Clear UserDefaults for the test suite
        let suiteName = #file
        testUserDefaults.removePersistentDomain(forName: suiteName)
        testUserDefaults = nil
        try super.tearDownWithError()
    }

    // MARK: - Test Data Helpers (from MockAPIClient to avoid direct dependency on MockMovieRepository here)
    private func sampleMovie(id: Int, title: String = "Sample Movie") -> Movie {
        return MockAPIClient.createSampleMovie(id: id, title: title)
    }

    private func samplePaginatedResponse(page: Int, movies: [Movie]) -> PaginatedResponse<Movie> {
        return MockAPIClient.createSamplePaginatedResponse(page: page, movies: movies)
    }

    // Helper to directly cache data for testing fallback scenarios
    private func cacheDirectly<T: Encodable>(_ data: T, forKey key: String) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            testUserDefaults.set(encodedData, forKey: key)
        } catch {
            XCTFail("Test setup error: Failed to cache data directly. Error: \(error)")
        }
    }
    
    private func loadDirectlyFromCache<T: Decodable>(forKey key: String) -> T? {
        guard let data = testUserDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - getNowPlayingMovies Tests (Original tests + Caching tests)

    func testGetNowPlayingMovies_Success_Original() { // Renamed original test
        let expectedPage = 1
        let networkResponse = samplePaginatedResponse(page: expectedPage, movies: [sampleMovie(id: 1)])
        mockAPIClient.paginatedMovieResponseResult = .success(networkResponse)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/movie/now_playing?page=1")!)

        let expectation = self.expectation(description: "getNowPlayingMovies success original")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?
        movieRepository.getNowPlayingMovies(page: expectedPage) { result in actualResult = result; expectation.fulfill() }
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockAPIClient.buildRequestCalled)
        XCTAssertTrue(mockAPIClient.requestCalled)
        guard case .success(let response) = actualResult else { XCTFail("Expected success"); return }
        XCTAssertEqual(response.results.first?.id, 1)
    }
    
    func testGetNowPlayingMovies_APIFailure_Original() { // Renamed
        let expectedError = APIError.networkError(NSError(domain: "Test", code: 123, userInfo: nil))
        mockAPIClient.paginatedMovieResponseResult = .failure(expectedError)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/movie/now_playing?page=1")!)

        let expectation = self.expectation(description: "getNowPlayingMovies API failure original")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?
        movieRepository.getNowPlayingMovies(page: 1) { result in actualResult = result; expectation.fulfill() }
        waitForExpectations(timeout: 1.0)

        XCTAssertTrue(mockAPIClient.requestCalled)
        guard case .failure(let error) = actualResult else { XCTFail("Expected failure"); return }
        XCTAssertEqual(error as? APIError, expectedError)
    }

    func testGetNowPlayingMovies_BuildRequestFailure_Original() { // Renamed
        mockAPIClient.buildRequestReturnValue = nil
        let expectation = self.expectation(description: "getNowPlayingMovies buildRequest failure original")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?
        movieRepository.getNowPlayingMovies(page: 1) { result in actualResult = result; expectation.fulfill() }
        waitForExpectations(timeout: 1.0)

        XCTAssertFalse(mockAPIClient.requestCalled)
        guard case .failure(let error) = actualResult else { XCTFail("Expected failure"); return }
        XCTAssertEqual(error as? APIError, APIError.invalidURL)
    }

    // Caching Tests for getNowPlayingMovies
    func test_getNowPlayingMovies_success_servesNetworkDataAndCachesIt() {
        let networkData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 10, title: "Network Now Playing")])
        mockAPIClient.paginatedMovieResponseResult = .success(networkData)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/now_playing")!)

        let expectation = self.expectation(description: "Network success and caches data")
        movieRepository.getNowPlayingMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "Network Now Playing")
            
            // Verify cache
            let cached: PaginatedResponse<Movie>? = self.loadDirectlyFromCache(forKey: MovieRepositoryTests.nowPlayingCacheKey)
            XCTAssertNotNil(cached)
            XCTAssertEqual(cached?.results.first?.title, "Network Now Playing")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func test_getNowPlayingMovies_networkFailure_servesCachedDataIfExists() {
        let cachedData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 20, title: "Cached Now Playing")])
        cacheDirectly(cachedData, forKey: MovieRepositoryTests.nowPlayingCacheKey)
        
        mockAPIClient.paginatedMovieResponseResult = .failure(APIError.networkError(NSError(domain: "Test", code: 0)))
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/now_playing")!)

        let expectation = self.expectation(description: "Network failure serves cached data")
        movieRepository.getNowPlayingMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success from cache"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "Cached Now Playing")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func test_getNowPlayingMovies_networkFailure_noCache_returnsError() {
        mockAPIClient.paginatedMovieResponseResult = .failure(APIError.invalidResponse(statusCode: 500))
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/now_playing")!)

        let expectation = self.expectation(description: "Network failure no cache returns error")
        movieRepository.getNowPlayingMovies(page: 1) { result in
            guard case .failure(let error) = result else { XCTFail("Expected failure"); expectation.fulfill(); return }
            XCTAssertEqual(error as? APIError, APIError.invalidResponse(statusCode: 500))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func test_getNowPlayingMovies_success_overwritesOldCache() {
        let oldCachedData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 30, title: "Old Now Playing")])
        cacheDirectly(oldCachedData, forKey: MovieRepositoryTests.nowPlayingCacheKey)

        let newNetworkData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 40, title: "New Now Playing")])
        mockAPIClient.paginatedMovieResponseResult = .success(newNetworkData)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/now_playing")!)

        let expectation = self.expectation(description: "Network success overwrites old cache")
        movieRepository.getNowPlayingMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "New Now Playing")
            
            let currentCached: PaginatedResponse<Movie>? = self.loadDirectlyFromCache(forKey: MovieRepositoryTests.nowPlayingCacheKey)
            XCTAssertEqual(currentCached?.results.first?.title, "New Now Playing")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    // MARK: - getPopularMovies Tests (Caching tests - assuming original tests are similar and can be omitted for brevity here if needed)
    
    func test_getPopularMovies_success_servesNetworkDataAndCachesIt() {
        let networkData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 11, title: "Network Popular")])
        mockAPIClient.paginatedMovieResponseResult = .success(networkData)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/popular")!)

        let expectation = self.expectation(description: "Popular: Network success and caches data")
        movieRepository.getPopularMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "Network Popular")
            let cached: PaginatedResponse<Movie>? = self.loadDirectlyFromCache(forKey: MovieRepositoryTests.popularCacheKey)
            XCTAssertEqual(cached?.results.first?.title, "Network Popular")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func test_getPopularMovies_networkFailure_servesCachedDataIfExists() {
        let cachedData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 21, title: "Cached Popular")])
        cacheDirectly(cachedData, forKey: MovieRepositoryTests.popularCacheKey)
        
        mockAPIClient.paginatedMovieResponseResult = .failure(APIError.networkError(NSError(domain: "Test", code: 0)))
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/popular")!)

        let expectation = self.expectation(description: "Popular: Network failure serves cached data")
        movieRepository.getPopularMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success from cache"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "Cached Popular")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - getUpcomingMovies Tests (Caching tests)

    func test_getUpcomingMovies_success_servesNetworkDataAndCachesIt() {
        let networkData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 12, title: "Network Upcoming")])
        mockAPIClient.paginatedMovieResponseResult = .success(networkData)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/upcoming")!)

        let expectation = self.expectation(description: "Upcoming: Network success and caches data")
        movieRepository.getUpcomingMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "Network Upcoming")
            let cached: PaginatedResponse<Movie>? = self.loadDirectlyFromCache(forKey: MovieRepositoryTests.upcomingCacheKey)
            XCTAssertEqual(cached?.results.first?.title, "Network Upcoming")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func test_getUpcomingMovies_networkFailure_servesCachedDataIfExists() {
        let cachedData = samplePaginatedResponse(page: 1, movies: [sampleMovie(id: 22, title: "Cached Upcoming")])
        cacheDirectly(cachedData, forKey: MovieRepositoryTests.upcomingCacheKey)
        
        mockAPIClient.paginatedMovieResponseResult = .failure(APIError.networkError(NSError(domain: "Test", code: 0)))
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/upcoming")!)

        let expectation = self.expectation(description: "Upcoming: Network failure serves cached data")
        movieRepository.getUpcomingMovies(page: 1) { result in
            guard case .success(let response) = result else { XCTFail("Expected success from cache"); expectation.fulfill(); return }
            XCTAssertEqual(response.results.first?.title, "Cached Upcoming")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    // MARK: - getMovieDetails Tests (Caching tests)
    
    func test_getMovieDetails_success_servesNetworkDataAndCachesIt() {
        let movieId = 101
        let networkMovie = sampleMovie(id: movieId, title: "Network Detail Movie")
        mockAPIClient.movieDetailResult = .success(networkMovie)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/movie/\(movieId)")!)

        let expectation = self.expectation(description: "Detail: Network success and caches data")
        movieRepository.getMovieDetails(id: movieId) { result in
            guard case .success(let movie) = result else { XCTFail("Expected success"); expectation.fulfill(); return }
            XCTAssertEqual(movie.title, "Network Detail Movie")
            
            let cached: Movie? = self.loadDirectlyFromCache(forKey: MovieRepositoryTests.movieDetailCacheKey(id: movieId))
            XCTAssertEqual(cached?.title, "Network Detail Movie")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func test_getMovieDetails_networkFailure_servesCachedDataIfExists() {
        let movieId = 102
        let cachedMovie = sampleMovie(id: movieId, title: "Cached Detail Movie")
        cacheDirectly(cachedMovie, forKey: MovieRepositoryTests.movieDetailCacheKey(id: movieId))
        
        mockAPIClient.movieDetailResult = .failure(APIError.networkError(NSError(domain: "Test", code: 0)))
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/movie/\(movieId)")!)

        let expectation = self.expectation(description: "Detail: Network failure serves cached data")
        movieRepository.getMovieDetails(id: movieId) { result in
            guard case .success(let movie) = result else { XCTFail("Expected success from cache"); expectation.fulfill(); return }
            XCTAssertEqual(movie.title, "Cached Detail Movie")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func test_getMovieDetails_networkFailure_noCache_returnsError() {
        let movieId = 103
        mockAPIClient.movieDetailResult = .failure(APIError.invalidResponse(statusCode: 404))
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/movie/\(movieId)")!)

        let expectation = self.expectation(description: "Detail: Network failure no cache returns error")
        movieRepository.getMovieDetails(id: movieId) { result in
            guard case .failure(let error) = result else { XCTFail("Expected failure"); expectation.fulfill(); return }
            XCTAssertEqual(error as? APIError, APIError.invalidResponse(statusCode: 404))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func test_getMovieDetails_success_overwritesOldCache() {
        let movieId = 104
        let oldCachedMovie = sampleMovie(id: movieId, title: "Old Detail Movie")
        cacheDirectly(oldCachedMovie, forKey: MovieRepositoryTests.movieDetailCacheKey(id: movieId))

        let newNetworkMovie = sampleMovie(id: movieId, title: "New Detail Movie")
        mockAPIClient.movieDetailResult = .success(newNetworkMovie)
        mockAPIClient.buildRequestReturnValue = URLRequest(url: URL(string: "https://dummy.url/movie/\(movieId)")!)

        let expectation = self.expectation(description: "Detail: Network success overwrites old cache")
        movieRepository.getMovieDetails(id: movieId) { result in
            guard case .success(let movie) = result else { XCTFail("Expected success"); expectation.fulfill(); return }
            XCTAssertEqual(movie.title, "New Detail Movie")
            
            let currentCached: Movie? = self.loadDirectlyFromCache(forKey: MovieRepositoryTests.movieDetailCacheKey(id: movieId))
            XCTAssertEqual(currentCached?.title, "New Detail Movie")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
}
