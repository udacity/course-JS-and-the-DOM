import XCTest
@testable import MovieApp

class GetUpcomingMoviesUseCaseTests: XCTestCase {

    var mockRepository: MockMovieRepository!
    var useCase: GetUpcomingMoviesUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        useCase = GetUpcomingMoviesUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        useCase = nil
        super.tearDown()
    }

    func testExecute_Success_ReturnsMovies() {
        // Arrange
        let expectedPage = 3
        let expectedMovies = [MockMovieRepository.createSampleMovie(id: 20, title: "Upcoming Movie 1")]
        let paginatedResponse = MockMovieRepository.createSamplePaginatedResponse(page: expectedPage, movies: expectedMovies)
        mockRepository.getUpcomingMoviesResult = .success(paginatedResponse)
        
        let expectation = self.expectation(description: "Completion handler called for upcoming movies")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?

        // Act
        useCase.execute(page: expectedPage) { result in
            actualResult = result
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Expectation should not timeout")
            
            XCTAssertTrue(self.mockRepository.getUpcomingMoviesCalled, "getUpcomingMovies should be called")
            XCTAssertEqual(self.mockRepository.getUpcomingMoviesLastPageFetched, expectedPage, "Page fetched should match expected page")
            
            switch actualResult {
            case .success(let response):
                XCTAssertEqual(response.page, expectedPage)
                XCTAssertEqual(response.results.count, expectedMovies.count)
                XCTAssertEqual(response.results.first?.id, expectedMovies.first?.id)
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
        mockRepository.getUpcomingMoviesResult = .failure(expectedError)
        
        let expectation = self.expectation(description: "Completion handler called for upcoming movies failure")
        var actualResult: Result<PaginatedResponse<Movie>, Error>?

        // Act
        useCase.execute(page: expectedPage) { result in
            actualResult = result
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Expectation should not timeout")
            
            XCTAssertTrue(self.mockRepository.getUpcomingMoviesCalled, "getUpcomingMovies should be called")
            XCTAssertEqual(self.mockRepository.getUpcomingMoviesLastPageFetched, expectedPage, "Page fetched should match expected page")
            
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
