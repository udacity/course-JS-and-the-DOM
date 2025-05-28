import SwiftUI // For ObservableObject and @Published
// Foundation is usually imported by SwiftUI, but good to be explicit if needed.
// Entities (Movie, PaginatedResponse), UseCases, and Repository will be needed.
// Assuming these are accessible via the project's module or appropriate imports.

class MovieListViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var nowPlayingMovies: [Movie] = []
    @Published var popularMovies: [Movie] = []
    @Published var upcomingMovies: [Movie] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // MARK: - Use Cases
    private let getNowPlayingMoviesUseCase: GetNowPlayingMoviesUseCase
    private let getPopularMoviesUseCase: GetPopularMoviesUseCase
    private let getUpcomingMoviesUseCase: GetUpcomingMoviesUseCase

    // MARK: - Initializer
    init(
        // In a real app, these would likely be injected via a Dependency Injection framework
        // or passed in as protocols for better testability.
        getNowPlayingMoviesUseCase: GetNowPlayingMoviesUseCase = GetNowPlayingMoviesUseCase(repository: MovieRepository()),
        getPopularMoviesUseCase: GetPopularMoviesUseCase = GetPopularMoviesUseCase(repository: MovieRepository()),
        getUpcomingMoviesUseCase: GetUpcomingMoviesUseCase = GetUpcomingMoviesUseCase(repository: MovieRepository())
    ) {
        self.getNowPlayingMoviesUseCase = getNowPlayingMoviesUseCase
        self.getPopularMoviesUseCase = getPopularMoviesUseCase
        self.getUpcomingMoviesUseCase = getUpcomingMoviesUseCase
    }

    // MARK: - Fetch Methods

    // Individual fetch methods now manage their own isLoading and errorMessage states
    // when called directly. When called by fetchAllMovieLists, these will be
    // overridden by the group's state management.

    func fetchNowPlayingMovies(page: Int = 1, completionGroup: DispatchGroup? = nil, errorContainer: ErrorContainer? = nil) {
        if completionGroup == nil { // Not part of a group
            self.isLoading = true
            self.errorMessage = nil
        }
        completionGroup?.enter()

        getNowPlayingMoviesUseCase.execute(page: page) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { completionGroup?.leave(); return }
                
                if completionGroup == nil { // Not part of a group, manage its own isLoading
                    self.isLoading = false
                }
                
                switch result {
                case .success(let response):
                    self.nowPlayingMovies = response.results
                case .failure(let error):
                    if completionGroup != nil {
                        errorContainer?.setError(error, forSource: "Now Playing movies")
                    } else {
                        self.errorMessage = "Failed to load Now Playing movies: \(error.localizedDescription)"
                    }
                }
                completionGroup?.leave()
            }
        }
    }

    func fetchPopularMovies(page: Int = 1, completionGroup: DispatchGroup? = nil, errorContainer: ErrorContainer? = nil) {
        if completionGroup == nil {
            self.isLoading = true
            self.errorMessage = nil
        }
        completionGroup?.enter()

        getPopularMoviesUseCase.execute(page: page) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { completionGroup?.leave(); return }

                if completionGroup == nil {
                    self.isLoading = false
                }
                
                switch result {
                case .success(let response):
                    self.popularMovies = response.results
                case .failure(let error):
                     if completionGroup != nil {
                        errorContainer?.setError(error, forSource: "Popular movies")
                    } else {
                        self.errorMessage = "Failed to load Popular movies: \(error.localizedDescription)"
                    }
                }
                completionGroup?.leave()
            }
        }
    }

    func fetchUpcomingMovies(page: Int = 1, completionGroup: DispatchGroup? = nil, errorContainer: ErrorContainer? = nil) {
        if completionGroup == nil {
            self.isLoading = true
            self.errorMessage = nil
        }
        completionGroup?.enter()

        getUpcomingMoviesUseCase.execute(page: page) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { completionGroup?.leave(); return }

                if completionGroup == nil {
                    self.isLoading = false
                }
                
                switch result {
                case .success(let response):
                    self.upcomingMovies = response.results
                case .failure(let error):
                    if completionGroup != nil {
                        errorContainer?.setError(error, forSource: "Upcoming movies")
                    } else {
                        self.errorMessage = "Failed to load Upcoming movies: \(error.localizedDescription)"
                    }
                }
                completionGroup?.leave()
            }
        }
    }
    
    // Helper class to manage first error in a group operation
    fileprivate class ErrorContainer {
        private var firstError: (source: String, error: Error)?
        private let lock = NSLock()

        func setError(_ error: Error, forSource source: String) {
            lock.lock()
            defer { lock.unlock() }
            if firstError == nil {
                firstError = (source, error)
            }
        }

        func getErrorMessage() -> String? {
            lock.lock()
            defer { lock.unlock() }
            if let errorInfo = firstError {
                return "Failed to load \(errorInfo.source): \(errorInfo.error.localizedDescription)"
            }
            return nil
        }
    }

    // Convenience method to fetch all initial lists
    func fetchAllMovieLists() {
        self.isLoading = true
        self.errorMessage = nil // Clear previous errors before starting a batch
        
        let group = DispatchGroup()
        let errorContainer = ErrorContainer() // To capture the first error

        fetchNowPlayingMovies(page: 1, completionGroup: group, errorContainer: errorContainer)
        fetchPopularMovies(page: 1, completionGroup: group, errorContainer: errorContainer)
        fetchUpcomingMovies(page: 1, completionGroup: group, errorContainer: errorContainer)
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            self.isLoading = false
            // Set error message if any error occurred during the batch
            if let groupError = errorContainer.getErrorMessage() {
                self.errorMessage = groupError
            }
        }
    }
}
