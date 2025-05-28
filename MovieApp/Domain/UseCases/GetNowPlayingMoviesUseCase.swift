import Foundation

// PaginatedResponse and Movie types are expected to be defined in Domain/Entities
// MovieRepositoryProtocol is expected to be defined in Domain/Interfaces/Repositories

class GetNowPlayingMoviesUseCase {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, completion: @escaping (Result<PaginatedResponse<Movie>, Error>) -> Void) {
        repository.getNowPlayingMovies(page: page, completion: completion)
    }
}
