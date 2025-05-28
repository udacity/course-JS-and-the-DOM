import XCTest
import Combine
@testable import MovieApp

class MovieDetailViewModelTests: XCTestCase {

    var mockRepository: MockMovieRepository!
    var getMovieDetailsUseCase: GetMovieDetailsUseCase!
    var viewModel: MovieDetailViewModel!
    
    private var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        // As with MovieListViewModelTests, we inject the use case with the mock repository
        getMovieDetailsUseCase = GetMovieDetailsUseCase(repository: mockRepository)
        viewModel = MovieDetailViewModel(getMovieDetailsUseCase: getMovieDetailsUseCase)
    }

    override func tearDown() {
        mockRepository = nil
        viewModel = nil
        getMovieDetailsUseCase = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        super.tearDown()
    }
    
    // Helper to create expectations for @Published properties
    private func expectPublished<T: Equatable>(
        _ publishedValue: Published<T?>.Publisher, // Note: T? because movie is optional
        equals expected: T?,
        description: String,
        timeout: TimeInterval = 1.0
    ) -> XCTestExpectation {
        let expectation = self.expectation(description: description)
        var actualValue: T?? // Double optional to distinguish initial nil from set nil
        
        publishedValue
            .dropFirst() // Ignore the initial value
            .first()
            .sink { value in
                actualValue = value
                if actualValue == expected { // This works even if both are nil
                    expectation.fulfill()
                } else if let actual = actualValue, let exp = expected, actual == exp { // For non-nil comparison
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
            .first(where: { $0 != nil })
            .sink { value in
                if value != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        return expectation
    }


    func testFetchMovieDetails_Success() {
        // Arrange
        let movieId = 123
        let expectedMovie = MockMovieRepository.createSampleMovie(id: movieId, title: "Detailed Movie")
        mockRepository.getMovieDetailsResult = .success(expectedMovie)
        
        let movieExpectation = expectPublished(viewModel.$movie, equals: expectedMovie, description: "Movie details updated")
        let loadingExpectation = self.expectation(description: "isLoading goes true then false")
        loadingExpectation.expectedFulfillmentCount = 2 // true, then false
        
        viewModel.$isLoading.sink { isLoading in
            loadingExpectation.fulfill()
        }.store(in: &cancellables)


        // Act
        viewModel.fetchMovieDetails(id: movieId)

        // Assert
        wait(for: [movieExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getMovieDetailsCalled)
        XCTAssertEqual(mockRepository.getMovieDetailsLastIdFetched, movieId)
        XCTAssertEqual(viewModel.movie?.id, expectedMovie.id)
        XCTAssertEqual(viewModel.movie?.title, expectedMovie.title)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchMovieDetails_Failure() {
        // Arrange
        let movieId = 456
        let expectedError = TestError.genericError
        mockRepository.getMovieDetailsResult = .failure(expectedError)
        
        let errorExpectation = expectPublishedNonNil(viewModel.$errorMessage, description: "Error message should be set on failure")
        let loadingExpectation = self.expectation(description: "isLoading goes true then false on failure")
        loadingExpectation.expectedFulfillmentCount = 2 // true, then false

        viewModel.$isLoading.sink { isLoading in
            loadingExpectation.fulfill()
        }.store(in: &cancellables)
        
        // Act
        viewModel.fetchMovieDetails(id: movieId)

        // Assert
        wait(for: [errorExpectation, loadingExpectation], timeout: 2.0)
        XCTAssertTrue(mockRepository.getMovieDetailsCalled)
        XCTAssertEqual(mockRepository.getMovieDetailsLastIdFetched, movieId)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.movie)
    }
}
