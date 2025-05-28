import SwiftUI

struct MovieListView: View {
    let movies: [Movie]
    let title: String

    var body: some View {
        List(movies) { movie in
            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                HStack(alignment: .top, spacing: 12) {
                    AsyncImage(url: movie.posterURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Placeholder while loading
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill) // Fill the frame
                        case .failure:
                            Image(systemName: "photo.artframe") // System icon for failure
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray.opacity(0.7))
                        @unknown default:
                            EmptyView() // Fallback for unknown states
                        }
                    }
                    .frame(width: 80, height: 120) // Fixed frame for the image
                    .background(Color.gray.opacity(0.1)) // Background for the frame
                    .clipped() // Clip the image to the frame
                    .cornerRadius(8) // Rounded corners for the image frame

                    VStack(alignment: .leading, spacing: 5) { // Increased spacing slightly
                        Text(movie.title)
                            .font(.headline)
                        
                        Text(movie.releaseDate ?? "N/A") // Use "N/A" for nil releaseDate
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if let overview = movie.overview, !overview.isEmpty {
                            Text(overview)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(3) // Limit overview to 3 lines
                                .padding(.top, 2)
                        }
                    }
                }
                .padding(.vertical, 6) // Slightly increased vertical padding for the row
            }
        }
        .navigationTitle(title)
    }
}

// Preview (Optional - for development in Xcode)
struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample data for preview
        let sampleMovies = [
            Movie(id: 1, title: "Epic Adventure Movie", releaseDate: "2023-03-15", posterPath: "/uS1AIL7I1Ycgs8PTfqUeN6jYNsQ.jpg", overview: "A thrilling journey through mountains and valleys, full of action and suspense. The hero faces many challenges.", genres: [Genre(id: 28, name: "Action")], runtime: 145, popularity: 123.45, voteAverage: 8.1, voteCount: 2034),
            Movie(id: 2, title: "Mystery of the Lost City", releaseDate: "2023-05-20", posterPath: "/sMP3VlYpccMPhVybmlLhY8PvK40.jpg", overview: "Detectives try to solve the disappearance of an ancient artifact from a legendary lost city. Twists and turns await.", genres: [Genre(id: 9648, name: "Mystery")], runtime: 110, popularity: 98.76, voteAverage: 7.5, voteCount: 980),
            Movie(id: 3, title: "Comedy Nights", releaseDate: nil, posterPath: nil, overview: "A hilarious series of sketches and stand-up comedy that will leave you in stitches.", genres: [Genre(id: 35, name: "Comedy")], runtime: 90, popularity: 75.30, voteAverage: 6.9, voteCount: 450)
        ]
        
        NavigationView {
            MovieListView(
                movies: sampleMovies,
                title: "Popular Movies"
            )
        }
    }
}
