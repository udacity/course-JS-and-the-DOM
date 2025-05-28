import XCTest
@testable import MovieApp // To access GetNowPlayingMoviesUseCase, Movie, PaginatedResponse, etc.

class GetNowPlayingMoviesUseCaseTests: XCTestCase {

    var mockRepository: MockMovieRepository!
    var useCase: GetNowPlayingMoviesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        useCase = GetNowPlayingMoviesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        useCase = nil
        super.tearDown()
    }

    func testExecute_Success_ReturnsMovies() {
        // Arrange
        let expectedPage = 1
        let expectedMovies = [MockMovieRepository.createSampleMovie(id: 1, title: "Now Playing Movie 1")]
        let paginatedResponse = MockMovieRepository.createSamplePaginatedResponse(page: expectedPage, movies: expectedMovies)
        mockRepository.getNowPlayingMoviesResult = .success(paginatedResponse)
        
        let expectation = self.expectation(description: "Completion handler called")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?

        // Act
        useCase.execute(page: expectedPage) { result in
            actualResult = result
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Expectation should not timeout")
            
            XCTAssertTrue(self.mockRepository.getNowPlayingMoviesCalled, "getNowPlayingMovies should be called")
            XCTAssertEqual(self.mockRepository.getNowPlayingMoviesLastPageFetched, expectedPage, "Page fetched should match expected page")
            
            switch actualResult {
            case .success(let response):
                XCTAssertEqual(response.page, expectedPage)
                XCTAssertEqual(response.results.count, expectedMovies.count)
                XCTAssertEqual(response.results.first?.id, expectedMovies.first?.id)
                XCTAssertEqual(response.results.first?.title, expectedMovies.first?.title)
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error.localizedDescription)")
            case nil:
                XCTFail("Result should not be nil")
            }
        }
    }

    func testExecute_Failure_ReturnsError() {
        // Arrange
        let expectedPage = 1
        let expectedError = TestError.genericError
        mockRepository.getNowPlayingMoviesResult = .failure(expectedError)
        
        let expectation = self.expectation(description: "Completion handler called")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?

        // Act
        useCase.execute(page: expectedPage) { result in
            actualResult = result
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Expectation should not timeout")
            
            XCTAssertTrue(self.mockRepository.getNowPlayingMoviesCalled, "getNowPlayingMovies should be called")
            XCTAssertEqual(self.mockRepository.getNowPlayingMoviesLastPageFetched, expectedPage, "Page fetched should match expected page")
            
            switch actualResult {
            case .success:
                XCTFail("Expected failure but got success")
            case .failure(let receivedError):
                XCTAssertEqual(receivedError as? TestError, expectedError, "Received error should match expected error")
            case nil:
                XCTFail("Result should not be nil")
            }
        }
    }
}
