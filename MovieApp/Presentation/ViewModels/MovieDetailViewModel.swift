import SwiftUI // For ObservableObject and @Published
// Foundation is usually imported by SwiftUI.
// Movie entity, GetMovieDetailsUseCase, and MovieRepository will be needed.
// Assuming these are accessible via the project's module or appropriate imports.

class MovieDetailViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var movie: Movie? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Use Case
    private let getMovieDetailsUseCase: GetMovieDetailsUseCase

    // MARK: - Initializer
    init(
        // In a real app, this would likely be injected.
        getMovieDetailsUseCase: GetMovieDetailsUseCase = GetMovieDetailsUseCase(repository: MovieRepository())
    ) {
        self.getMovieDetailsUseCase = getMovieDetailsUseCase
    }

    // MARK: - Fetch Method
    func fetchMovieDetails(id: Int) {
        self.isLoading = true
        self.errorMessage = nil
        self.movie = nil // Clear previous movie details if any

        getMovieDetailsUseCase.execute(id: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let movieDetail):
                    self.movie = movieDetail
                case .failure(let error):
                    self.errorMessage = "Failed to load movie details: \(error.localizedDescription)"
                }
            }
        }
    }
}
