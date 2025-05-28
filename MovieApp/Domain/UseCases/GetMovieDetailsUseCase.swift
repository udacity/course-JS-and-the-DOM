import Foundation

// Movie type is expected to be defined in Domain/Entities
// MovieRepositoryProtocol is expected to be defined in Domain/Interfaces/Repositories

class GetMovieDetailsUseCase {
    private let repository: MovieRepositoryProtocol

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int, completion: @escaping (Result<Movie, Error>) -> Void) {
        repository.getMovieDetails(id: id, completion: completion)
    }
}
