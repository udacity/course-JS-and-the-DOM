import SwiftUI

struct MovieDetailView: View {
    @StateObject var viewModel = MovieDetailViewModel()
    let movieId: Int

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("Loading details...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let movie = viewModel.movie {
                    moviePoster(for: movie)
                    movieTitle(for: movie)
                    movieOverview(for: movie)
                    movieInfoSection(for: movie)
                    movieStats(for: movie)
                    Spacer() // Push content to top
                } else {
                    Text("Movie details not available.")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchMovieDetails(id: movieId)
        }
        .navigationTitle(viewModel.movie?.title ?? "Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private View Builders
    
    @ViewBuilder
    private func moviePoster(for movie: Movie) -> some View {
        AsyncImage(url: movie.posterURL) { phase in
            switch phase {
            case .empty:
                ProgressView().frame(height: 300)
            case .success(let image):
                image.resizable().aspectRatio(contentMode: .fit).cornerRadius(12)
            case .failure:
                Image(systemName: "photo.artframe").resizable().aspectRatio(contentMode: .fit).frame(height: 300).foregroundColor(.gray)
            @unknown default:
                EmptyView().frame(height: 300)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func movieTitle(for movie: Movie) -> some View {
        Text(movie.title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding(.top, 8)
    }

    @ViewBuilder
    private func movieOverview(for movie: Movie) -> some View {
        if let overview = movie.overview, !overview.isEmpty {
            Text("Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
            Text(overview)
                .font(.body)
        }
    }
    
    @ViewBuilder
    private func movieInfoSection(for movie: Movie) -> some View {
        // Release Date
        if let releaseDate = movie.releaseDate, !releaseDate.isEmpty {
            HStack {
                Text("Release Date:").fontWeight(.semibold)
                Text(releaseDate).foregroundColor(.gray)
            }
            .font(.subheadline)
            .padding(.top, 2)
        }

        // Runtime
        if let runtime = movie.runtime, runtime > 0 {
            HStack {
                Text("Runtime:").fontWeight(.semibold)
                Text(formattedRuntime(runtime)).foregroundColor(.gray)
            }
            .font(.subheadline)
            .padding(.top, 2)
        }

        // Genres
        if let genres = movie.genres, !genres.isEmpty {
            VStack(alignment: .leading) {
                Text("Genres:").fontWeight(.semibold)
                Text(genres.map { $0.name }.joined(separator: ", "))
                    .foregroundColor(.gray)
            }
            .font(.subheadline)
            .padding(.top, 2)
        }
    }

    @ViewBuilder
    private func movieStats(for movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let popularity = movie.popularity {
                Text("Popularity: \(String(format: "%.1f", popularity))")
            }
            if let voteAverage = movie.voteAverage, let voteCount = movie.voteCount {
                 Text("Rating: \(String(format: "%.1f", voteAverage))/10 (\(voteCount) votes)")
            }
        }
        .font(.caption)
        .foregroundColor(.secondary)
        .padding(.top, 8)
    }

    private func formattedRuntime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 && remainingMinutes > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(remainingMinutes)m"
        }
    }
}

// Preview (Optional - for development in Xcode)
struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = MovieDetailViewModel()
        // Simulate a loaded movie state for preview
        let sampleGenres = [Genre(id: 28, name: "Action"), Genre(id: 12, name: "Adventure")]
        let sampleMovie = Movie(id: 1, title: "Preview Blockbuster", releaseDate: "2023-01-01", posterPath: "/uS1AIL7I1Ycgs8PTfqUeN6jYNsQ.jpg", overview: "This is a very long and detailed overview of the movie to see how text wrapping and layout behaves within the ScrollView. It should provide enough content to test scrolling if necessary, especially on smaller devices. The plot involves exciting chases, dramatic confrontations, and a resolution that ties everything together neatly. More text just to make it longer and longer and longer.", genres: sampleGenres, runtime: 155, popularity: 250.5, voteAverage: 8.8, voteCount: 3500)
        mockViewModel.movie = sampleMovie
        // mockViewModel.isLoading = true // To test loading state
        // mockViewModel.errorMessage = "Failed to load movie details. Please try again." // To test error state

        return NavigationView {
            MovieDetailView(viewModel: mockViewModel, movieId: 1)
        }
    }
}
