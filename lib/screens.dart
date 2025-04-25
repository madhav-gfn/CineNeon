import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models_and_api.dart';
import 'providers.dart';
import 'widgets.dart';
import 'app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    MoviesScreen(),
    SearchScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF121212),
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_outlined),
            activeIcon: Icon(Icons.movie),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    // Load movies when the screen is first created
    Future.microtask(() {
      Provider.of<MoviesProvider>(context, listen: false).fetchTrendingMovies();
      Provider.of<MoviesProvider>(context, listen: false).fetchPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Consumer<MoviesProvider>(
        builder: (context, moviesProvider, child) {
          if (moviesProvider.isLoading && 
              moviesProvider.trendingMovies.isEmpty &&
              moviesProvider.popularMovies.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.redAccent,
              ),
            );
          }

          if (moviesProvider.error != null &&
              moviesProvider.trendingMovies.isEmpty &&
              moviesProvider.popularMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading movies',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      moviesProvider.fetchTrendingMovies();
                      moviesProvider.fetchPopularMovies();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await moviesProvider.fetchTrendingMovies();
              await moviesProvider.fetchPopularMovies();
            },
            color: Colors.redAccent,
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Color(0xFF212121),
                  floating: true,
                  title: Row(
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'CineNeon',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.notifications_outlined),
                      color: Colors.white,
                      onPressed: () {
                        // TODO: Implement notifications
                      },
                    ),
                  ],
                ),
                
                // Trending Movies Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Trending This Week',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 300,
                    child: moviesProvider.trendingMovies.isEmpty
                        ? Center(
                            child: Text(
                              'No trending movies available',
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            itemCount: moviesProvider.trendingMovies.length,
                            itemBuilder: (context, index) {
                              final movie = moviesProvider.trendingMovies[index];
                              return Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: FeatureMovieCard(
                                  movie: movie,
                                  onTap: () => AppNavigator.navigateToMovieDetails(
                                    context, 
                                    movie.id,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                
                // Popular Movies Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text(
                      'Popular Movies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                SliverPadding(
                  padding: EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final movie = moviesProvider.popularMovies[index];
                        return MovieCard(
                          movie: movie,
                          onTap: () => AppNavigator.navigateToMovieDetails(
                            context, 
                            movie.id,
                          ),
                        );
                      },
                      childCount: moviesProvider.popularMovies.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MovieDetailsScreen extends StatefulWidget {
  final int movieId;
  
  const MovieDetailsScreen({
    super.key,
    required this.movieId,
  });

  @override
  _MovieDetailsScreenState createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  late Future<Movie> _movieFuture;
  late Future<List<Review>> _reviewsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    _movieFuture = moviesProvider.getMovieDetails(widget.movieId);
    _reviewsFuture = moviesProvider.getMovieReviews(widget.movieId);
  }
  
  @override
  Widget build(BuildContext context) {
    final userListsProvider = Provider.of<UserListsProvider>(context);
    
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: FutureBuilder<Movie>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.redAccent,
              ),
            );
          }
          
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading movie details',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadData();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          final movie = snapshot.data!;
          
          return CustomScrollView(
            slivers: [
              // Backdrop and Movie Info
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Backdrop Image
                      Image.network(
                        movie.fullBackdropPath,
                        fit: BoxFit.cover,
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Title and Rating
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Poster
                            Container(
                              width: 100,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: NetworkImage(movie.fullPosterPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            // Title and Year
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    movie.title,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (movie.releaseDate.isNotEmpty)
                                    Text(
                                      movie.releaseDate.split('-')[0],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  SizedBox(height: 8),
                                  // Rating
                                  Row(
                                    children: [
                                      RatingStars(rating: movie.voteAverage),
                                      SizedBox(width: 8),
                                      Text(
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Color(0xFF212121),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      userListsProvider.isWatched(movie.id)
                          ? Icons.visibility
                          : Icons.visibility_outlined,
                      color: userListsProvider.isWatched(movie.id)
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                    onPressed: () {
                      userListsProvider.toggleWatched(movie);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            userListsProvider.isWatched(movie.id)
                                ? 'Marked as watched'
                                : 'Removed from watched',
                          ),
                          backgroundColor: Color(0xFF212121),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      userListsProvider.isInWatchlist(movie.id)
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: userListsProvider.isInWatchlist(movie.id)
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                    onPressed: () {
                      userListsProvider.toggleWatchlist(movie);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            userListsProvider.isInWatchlist(movie.id)
                                ? 'Added to watchlist'
                                : 'Removed from watchlist',
                          ),
                          backgroundColor: Color(0xFF212121),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share_outlined),
                    color: Colors.white,
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
              ),
              
              // Genres
              if (movie.genres.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: movie.genres.map((genre) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              
              // Overview
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        movie.overview,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // User Rating Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: UserRatingWidget(
                    movie: movie,
                    initialRating: userListsProvider.getRating(movie.id),
                    onRatingChanged: (rating) {
                      userListsProvider.rateMovie(movie, rating);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Your rating has been saved'),
                          backgroundColor: Color(0xFF212121),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Divider
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(color: Colors.white24),
                ),
              ),
              
              // Reviews Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Reviews',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: FutureBuilder<List<Review>>(
                  future: _reviewsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    }
                    
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Error loading reviews',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    
                    final reviews = snapshot.data!;
                    
                    if (reviews.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No reviews available',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: reviews.length > 3 ? 3 : reviews.length,
                      padding: EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return ReviewCard(review: review);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _hasSearched = false;
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);
    
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF212121),
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search for movies...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: Colors.white54),
              onPressed: () {
                _searchController.clear();
                moviesProvider.searchResults.clear();
                setState(() {
                  _hasSearched = false;
                });
              },
            ),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              moviesProvider.searchMovies(query);
              setState(() {
                _hasSearched = true;
              });
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                moviesProvider.searchMovies(_searchController.text);
                setState(() {
                  _hasSearched = true;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (moviesProvider.isLoading)
            LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
            ),
          
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 80,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for movies',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : moviesProvider.searchResults.isEmpty && !moviesProvider.isLoading
                    ? Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: moviesProvider.searchResults.length,
                        itemBuilder: (context, index) {
                          final movie = moviesProvider.searchResults[index];
                          return MovieCard(
                            movie: movie,
                            onTap: () => AppNavigator.navigateToMovieDetails(
                              context, 
                              movie.id,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF212121),
        title: Text(
          'My Watchlist',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<UserListsProvider>(
        builder: (context, userListsProvider, child) {
          final watchlist = userListsProvider.watchlist;
          
          if (watchlist.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_outline,
                    size: 80,
                    color: Colors.white24,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your watchlist is empty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Movies you bookmark will appear here',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      AppNavigator.navigateToHome(context);
                    },
                    child: Text('Explore Movies'),
                  ),
                ],
              ),
            );
          }
          
          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final movie = watchlist[index];
              return MovieCard(
                movie: movie,
                onTap: () => AppNavigator.navigateToMovieDetails(
                  context, 
                  movie.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Color(0xFF212121),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined),
            color: Colors.white,
            onPressed: () {
              // TODO: Implement settings screen
            },
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not logged in',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    onPressed: () {
                      AppNavigator.navigateToLogin(context);
                    },
                    child: Text('Log In'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      user.username[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Username
                  Text(
                    user.username,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  
                  // Email
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 32),
                  
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(
                        context,
                        Icons.bookmark,
                        'Watchlist',
                        user.watchlist.length.toString(),
                      ),
                      _buildStatColumn(
                        context,
                        Icons.star,
                        'Rated',
                        Provider.of<UserListsProvider>(context).ratedMoviesCount.toString(),
                      ),
                      _buildStatColumn(
                        context,
                        Icons.visibility,
                        'Watched',
                        Provider.of<UserListsProvider>(context).watchedMovies.length.toString(),
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  
                  // Divider
                  Divider(color: Colors.white24),
                  SizedBox(height: 16),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        await authProvider.logout();
                        AppNavigator.navigateToLogin(context);
                      },
                      icon: Icon(Icons.logout, color: Colors.white70),
                      label: Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildStatColumn(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.redAccent,
          size: 28,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF212121),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.author,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                RatingStars(rating: review.rating),
                SizedBox(width: 8),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              review.content,
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
