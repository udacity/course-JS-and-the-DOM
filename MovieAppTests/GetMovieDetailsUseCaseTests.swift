import XCTest
@testable import MovieApp

class GetMovieDetailsUseCaseTests: XCTestCase {

    var mockRepository: MockMovieRepository!
    var useCase: GetMovieDetailsUseCase!

    override func setUp() {
        super.setUp()
        mockRepository = MockMovieRepository()
        useCase = GetMovieDetailsUseCase(repository: mockRepository)
    }

    override func tearDown() {
        mockRepository = nil
        useCase = nil
        super.tearDown()
    }

    func testExecute_Success_ReturnsMovieDetail() {
        // Arrange
        let expectedMovieId = 123
        let expectedMovie = MockMovieRepository.createSampleMovie(id: expectedMovieId, title: "Detailed Movie")
        mockRepository.getMovieDetailsResult = .success(expectedMovie)
        
        let expectation = self.expectation(description: "Completion handler called for movie details")
        var actualResult: Result<Movie, Error>?

        // Act
        useCase.execute(id: expectedMovieId) { result in
            actualResult = result
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Expectation should not timeout")
            
            XCTAssertTrue(self.mockRepository.getMovieDetailsCalled, "getMovieDetails should be called")
            XCTAssertEqual(self.mockRepository.getMovieDetailsLastIdFetched, expectedMovieId, "ID fetched should match expected ID")
            
            switch actualResult {
            case .success(let movie):
                XCTAssertEqual(movie.id, expectedMovieId)
                XCTAssertEqual(movie.title, expectedMovie.title)
            case .failure(let error):
                XCTFail("Expected success but got failure: \(error.localizedDescription)")
            case nil:
                XCTFail("Result should not be nil")
            }
        }
    }

    func testExecute_Failure_ReturnsError() {
        // Arrange
        let expectedMovieId = 456
        let expectedError = TestError.genericError
        mockRepository.getMovieDetailsResult = .failure(expectedError)
        
        let expectation = self.expectation(description: "Completion handler called for movie details failure")
        var actualResult: Result<Movie, Error>?

        // Act
        useCase.execute(id: expectedMovieId) { result in
            actualResult = result
            expectation.fulfill()
        }

        // Assert
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error, "Expectation should not timeout")
            
            XCTAssertTrue(self.mockRepository.getMovieDetailsCalled, "getMovieDetails should be called")
            XCTAssertEqual(self.mockRepository.getMovieDetailsLastIdFetched, expectedMovieId, "ID fetched should match expected ID")
            
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
