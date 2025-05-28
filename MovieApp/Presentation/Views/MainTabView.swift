import SwiftUI

struct MainTabView: View {
    @StateObject var movieListViewModel = MovieListViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Use VStack to stack error message and TabView
                // Display error message if it exists and not currently loading
                if let errorMessage = movieListViewModel.errorMessage, !movieListViewModel.isLoading {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity) // Ensure it takes available width
                        .background(Color.gray.opacity(0.1)) // Optional: subtle background for the error
                }

                // Display loading indicator if actively loading and no specific error shown yet
                // This is a general loading indicator for the whole view model state.
                // Individual lists might still be empty if their specific fetches are pending or failed.
                if movieListViewModel.isLoading && movieListViewModel.errorMessage == nil {
                    ProgressView("Loading movies...")
                        .padding()
                }
                
                TabView {
                    MovieListView(movies: movieListViewModel.nowPlayingMovies, title: "Now Playing")
                        .tabItem {
                            Label("Now Playing", systemImage: "play.circle.fill")
                        }
                        .tag(0)

                    MovieListView(movies: movieListViewModel.popularMovies, title: "Popular")
                        .tabItem {
                            Label("Popular", systemImage: "star.circle.fill")
                        }
                        .tag(1)

                    MovieListView(movies: movieListViewModel.upcomingMovies, title: "Upcoming")
                        .tabItem {
                            Label("Upcoming", systemImage: "calendar.circle.fill")
                        }
                        .tag(2)
                }
                // The navigationTitle for the TabView itself can be set on the TabView
                // or on the views inside if they don't have their own.
                // For this setup, MovieListView sets its own title, which is appropriate.
            }
            // .navigationTitle("Movie App") // Example if a root title was desired for the NavigationView
            // .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // Clear any previous errors when the view appears or re-appears.
            // This might be desirable if the user navigates away and back.
            // movieListViewModel.errorMessage = nil 
            // Decided against clearing error on appear for now, as it might hide persistent errors
            // until the next fetch attempt. The ViewModel should manage when to clear errors.
            
            movieListViewModel.fetchAllMovieLists()
        }
    }
}

// Preview (Optional)
/*
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        // Example with an error
        let viewModelWithError = MovieListViewModel()
        viewModelWithError.errorMessage = "Network connection failed. Please try again later."
        
        // Example while loading
        let viewModelLoading = MovieListViewModel()
        viewModelLoading.isLoading = true
        
        return Group {
            MainTabView() // Normal state
            
            MainTabView(movieListViewModel: viewModelWithError)
                .previewDisplayName("With Error Message")
            
            MainTabView(movieListViewModel: viewModelLoading)
                .previewDisplayName("Loading State")
        }
    }
}
*/
