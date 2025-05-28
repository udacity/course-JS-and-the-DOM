import XCTest
import Combine // For testing @Published properties if needed, though direct checks are also fine.
@testable import MovieApp

class MovieListViewModelTests: XCTestCase {

    var mockRepository: MockMovieRepository!
    // Use cases will be initialized by the ViewModel itself using this mockRepository
    var getNowPlayingMoviesUseCase: GetNowPlayingMoviesUseCase!
    var getPopularMoviesUseCase: GetPopularMoviesUseCase!
    var getUpcomingMoviesUseCase: GetUpcomingMoviesUseCase!
    
    var viewModel: MovieListViewModel!
    
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        // The ViewModel initializes its own use cases, but they will use the repository we pass.
        // For more control, we could inject mock use cases, but the current ViewModel design
        // instantiates them directly. We will create a view model and then assign its use cases the mock repo.
        // This is a bit of a workaround for the current ViewModel init.
        // A better approach would be to allow injecting use cases directly into the ViewModel.
        
        // Create actual use cases but with the mock repository
        getNowPlayingMoviesUseCase = GetNowPlayingMoviesUseCase(repository: mockRepository)
        getPopularMoviesUseCase = GetPopularMoviesUseCase(repository: mockRepository)
        getUpcomingMoviesUseCase = GetUpcomingMoviesUseCase(repository: mockRepository)

        viewModel = MovieListViewModel(
            getNowPlayingMoviesUseCase: getNowPlayingMoviesUseCase,
            getPopularMoviesUseCase: getPopularMoviesUseCase,
            getUpcomingMoviesUseCase: getUpcomingMoviesUseCase
        )
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        getNowPlayingMoviesUseCase = nil
        getPopularMoviesUseCase = nil
        getUpcomingMoviesUseCase = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }

    // Helper to create expectations for @Published properties
    private func expectPublished<T: Equatable>(
        _ publishedValue: Published<T>.Publisher,
        equals expected: T,
        description: String,
        timeout: TimeInterval = 1.0
    ) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        var actualValue: T?
        
        publishedValue
            .dropFirst() // Ignore the initial value
            .first() // We are interested in the first change after the action
            .sink { value in
                actualValue = value
                if actualValue == expected {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        return expectation
    }
    
    private func expectPublishedNonNil<T>(
        _ publishedValue: Published<T?>.Publisher,
        description: String,
        timeout: TimeInterval = 1.0
    ) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        
        publishedValue
            .dropFirst()
            .first(where: { $0 != nil }) // Fulfill when value is not nil
            .sink { value in
                if value != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        return expectation
    }


    // MARK: - Now Playing Movies Tests

    func testFetchNowPlayingMovies_Success() {
        // Arrange
        let movies = [MockMovieRepository.createSampleMovie(id: 1, title: "Now Playing 1")]
        let response = MockMovieRepository.createSamplePaginatedResponse(movies: movies)
        mockRepository.getNowPlayingMoviesResult = .success(response)
        
        let moviesExpectation = expectPublished(viewModel.$nowPlayingMovies, equals: movies, description: "Now playing movies updated")
        let loadingExpectation = expectPublished(viewModel.$isLoading, equals: false, description: "isLoading should be false after fetch")
        loadingExpectation.expectedFulfillmentCount = 2 // true then false

        // Act
        viewModel.fetchNowPlayingMovies()

        // Assert
        wait(for: [moviesExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getNowPlayingMoviesCalled)
        XCTAssertEqual(viewModel.nowPlayingMovies.count, 1)
        XCTAssertEqual(viewModel.nowPlayingMovies.first?.title, "Now Playing 1")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchNowPlayingMovies_Failure() {
        // Arrange
        let expectedError = TestError.genericError
        mockRepository.getNowPlayingMoviesResult = .failure(expectedError)
        
        let errorExpectation = expectPublishedNonNil(viewModel.$errorMessage, description: "Error message should be set")
        let loadingExpectation = expectPublished(viewModel.$isLoading, equals: false, description: "isLoading should be false after fetch attempt")
        loadingExpectation.expectedFulfillmentCount = 2


        // Act
        viewModel.fetchNowPlayingMovies()

        // Assert
        wait(for: [errorExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getNowPlayingMoviesCalled)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.nowPlayingMovies.isEmpty)
    }

    // MARK: - Popular Movies Tests

    func testFetchPopularMovies_Success() {
        // Arrange
        let movies = [MockMovieRepository.createSampleMovie(id: 2, title: "Popular 1")]
        let response = MockMovieRepository.createSamplePaginatedResponse(movies: movies)
        mockRepository.getPopularMoviesResult = .success(response)
        
        let moviesExpectation = expectPublished(viewModel.$popularMovies, equals: movies, description: "Popular movies updated")
        let loadingExpectation = expectPublished(viewModel.$isLoading, equals: false, description: "isLoading should be false")
        loadingExpectation.expectedFulfillmentCount = 2


        // Act
        viewModel.fetchPopularMovies()

        // Assert
        wait(for: [moviesExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getPopularMoviesCalled)
        XCTAssertEqual(viewModel.popularMovies.first?.title, "Popular 1")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchPopularMovies_Failure() {
        // Arrange
        let expectedError = TestError.genericError
        mockRepository.getPopularMoviesResult = .failure(expectedError)

        let errorExpectation = expectPublishedNonNil(viewModel.$errorMessage, description: "Error message should be set for popular")
        let loadingExpectation = expectPublished(viewModel.$isLoading, equals: false, description: "isLoading should be false after fetch attempt for popular")
        loadingExpectation.expectedFulfillmentCount = 2

        // Act
        viewModel.fetchPopularMovies()

        // Assert
        wait(for: [errorExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getPopularMoviesCalled)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.popularMovies.isEmpty)
    }

    // MARK: - Upcoming Movies Tests

    func testFetchUpcomingMovies_Success() {
        // Arrange
        let movies = [MockMovieRepository.createSampleMovie(id: 3, title: "Upcoming 1")]
        let response = MockMovieRepository.createSamplePaginatedResponse(movies: movies)
        mockRepository.getUpcomingMoviesResult = .success(response)

        let moviesExpectation = expectPublished(viewModel.$upcomingMovies, equals: movies, description: "Upcoming movies updated")
        let loadingExpectation = expectPublished(viewModel.$isLoading, equals: false, description: "isLoading should be false")
        loadingExpectation.expectedFulfillmentCount = 2

        // Act
        viewModel.fetchUpcomingMovies()

        // Assert
        wait(for: [moviesExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getUpcomingMoviesCalled)
        XCTAssertEqual(viewModel.upcomingMovies.first?.title, "Upcoming 1")
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchUpcomingMovies_Failure() {
        // Arrange
        let expectedError = TestError.genericError
        mockRepository.getUpcomingMoviesResult = .failure(expectedError)

        let errorExpectation = expectPublishedNonNil(viewModel.$errorMessage, description: "Error message should be set for upcoming")
        let loadingExpectation = expectPublished(viewModel.$isLoading, equals: false, description: "isLoading should be false after fetch attempt for upcoming")
        loadingExpectation.expectedFulfillmentCount = 2
        
        // Act
        viewModel.fetchUpcomingMovies()

        // Assert
        wait(for: [errorExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getUpcomingMoviesCalled)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.upcomingMovies.isEmpty)
    }
    
    // MARK: - Fetch All Lists
    
    func testFetchAllMovieLists_Success() {
        // Arrange
        let nowPlaying = [MockMovieRepository.createSampleMovie(id: 1, title: "NP")]
        let popular = [MockMovieRepository.createSampleMovie(id: 2, title: "Pop")]
        let upcoming = [MockMovieRepository.createSampleMovie(id: 3, title: "Up")]
        
        mockRepository.getNowPlayingMoviesResult = .success(MockMovieRepository.createSamplePaginatedResponse(movies: nowPlaying))
        mockRepository.getPopularMoviesResult = .success(MockMovieRepository.createSamplePaginatedResponse(movies: popular))
        mockRepository.getUpcomingMoviesResult = .success(MockMovieRepository.createSamplePaginatedResponse(movies: upcoming))
        
        let npExpectation = expectPublished(viewModel.$nowPlayingMovies, equals: nowPlaying, description: "Now Playing movies loaded by fetchAll")
        let popExpectation = expectPublished(viewModel.$popularMovies, equals: popular, description: "Popular movies loaded by fetchAll")
        let upExpectation = expectPublished(viewModel.$upcomingMovies, equals: upcoming, description: "Upcoming movies loaded by fetchAll")
        // isLoading will be set to true 3 times and false 3 times. We only care about the final false.
        // A more robust way might be to use a dispatch group or combine multiple expectations.
        let loadingExp = expectation(description: "isLoading eventually false after all fetches")
        
        viewModel.$isLoading
            .filter { !$0 } // looking for false
            .dropFirst(2) // Expect it to go true->false, true->false, true->false. So drop first 2 false.
            .first()
            .sink { _ in loadingExp.fulfill() }
            .store(in: &cancellables)

        // Act
        viewModel.fetchAllMovieLists()
        
        // Assert
        wait(for: [npExpectation, popExpectation, upExpectation, loadingExp], timeout: 5.0) // Increased timeout for multiple async calls
        XCTAssertTrue(mockRepository.getNowPlayingMoviesCalled)
        XCTAssertTrue(mockRepository.getPopularMoviesCalled)
        XCTAssertTrue(mockRepository.getUpcomingMoviesCalled)
        XCTAssertNil(viewModel.errorMessage)
    }
}
