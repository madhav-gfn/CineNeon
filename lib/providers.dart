import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models_and_api.dart';
import 'config.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    setLoading(true);
    setError(null);

    try {
      // In a real app, this would validate against a backend
      await Future.delayed(Duration(seconds: 2)); // Simulate network delay
      
      if (email.isNotEmpty && password.isNotEmpty) {
        // Simulate successful login
        _currentUser = User(
          id: 'user1',
          username: email.split('@').first,
          email: email,
          watchlist: [],
          watchedMovies: [],
          movieRatings: {},
        );
        
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);
        
        setLoading(false);
        notifyListeners();
        return true;
      } else {
        setError('Invalid email or password');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('An error occurred: $e');
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    if (isLoggedIn) {
      final userEmail = prefs.getString('userEmail');
      if (userEmail != null) {
        _currentUser = User(
          id: 'user1',
          username: userEmail.split('@').first,
          email: userEmail,
          watchlist: [],
          watchedMovies: [],
          movieRatings: {},
        );
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}

class MoviesProvider extends ChangeNotifier {
  final TMDBApi _api = TMDBApi(apiKey: Config.tmdbApiKey);
  
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchTrendingMovies() async {
    setLoading(true);
    setError(null);
    
    try {
      _trendingMovies = await _api.getTrendingMovies();
      setLoading(false);
    } catch (e) {
      setError('Failed to load trending movies: $e');
      setLoading(false);
    }
  }

  Future<void> fetchPopularMovies() async {
    setLoading(true);
    setError(null);
    
    try {
      _popularMovies = await _api.getPopularMovies();
      setLoading(false);
    } catch (e) {
      setError('Failed to load popular movies: $e');
      setLoading(false);
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    try {
      return await _api.getMovieDetails(movieId);
    } catch (e) {
      setError('Failed to load movie details: $e');
      rethrow;
    }
  }

  Future<List<Review>> getMovieReviews(int movieId) async {
    try {
      return await _api.getMovieReviews(movieId);
    } catch (e) {
      setError('Failed to load movie reviews: $e');
      return [];
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    
    setLoading(true);
    setError(null);
    
    try {
      _searchResults = await _api.searchMovies(query);
      setLoading(false);
    } catch (e) {
      setError('Failed to search movies: $e');
      setLoading(false);
    }
  }
}

class UserListsProvider extends ChangeNotifier {
  final List<Movie> _watchlist = [];
  final List<Movie> _watchedMovies = [];
  final Map<int, double> _movieRatings = {};
  final AuthProvider _authProvider;

  UserListsProvider(this._authProvider);

  List<Movie> get watchlist => _watchlist;
  List<Movie> get watchedMovies => _watchedMovies;
  Map<int, double> get movieRatings => _movieRatings;

  // Get the number of rated movies
  int get ratedMoviesCount => _movieRatings.length;

  bool isInWatchlist(int movieId) {
    return _watchlist.any((movie) => movie.id == movieId);
  }

  bool isWatched(int movieId) {
    return _watchedMovies.any((movie) => movie.id == movieId);
  }

  double? getRating(int movieId) {
    return _movieRatings[movieId];
  }

  Future<void> toggleWatchlist(Movie movie) async {
    if (!_authProvider.isAuthenticated) {
      return;
    }

    if (isInWatchlist(movie.id)) {
      _watchlist.removeWhere((m) => m.id == movie.id);
    } else {
      _watchlist.add(movie);
    }
    
    notifyListeners();
    
    // In a real app, this would sync with a backend
    if (_authProvider.currentUser != null) {
      _authProvider.currentUser!.watchlist = List.from(_watchlist);
    }
  }

  Future<void> toggleWatched(Movie movie) async {
    if (!_authProvider.isAuthenticated) {
      return;
    }

    if (isWatched(movie.id)) {
      _watchedMovies.removeWhere((m) => m.id == movie.id);
      // When marking a movie as unwatched, also remove its rating
      _movieRatings.remove(movie.id);
    } else {
      _watchedMovies.add(movie);
    }
    
    notifyListeners();
    
    // In a real app, this would sync with a backend
    if (_authProvider.currentUser != null) {
      _authProvider.currentUser!.watchedMovies = List.from(_watchedMovies);
      _authProvider.currentUser!.movieRatings = Map.from(_movieRatings);
    }
  }

  Future<void> rateMovie(Movie movie, double rating) async {
    if (!_authProvider.isAuthenticated) {
      return;
    }

    // Ensure the rating is between 0 and 10
    rating = rating.clamp(0.0, 10.0);
    
    // Update the rating
    _movieRatings[movie.id] = rating;
    
    // Automatically mark the movie as watched when rated
    if (!isWatched(movie.id)) {
      _watchedMovies.add(movie);
    }
    
    notifyListeners();
    
    // In a real app, this would sync with a backend
    if (_authProvider.currentUser != null) {
      _authProvider.currentUser!.watchedMovies = List.from(_watchedMovies);
      _authProvider.currentUser!.movieRatings = Map.from(_movieRatings);
    }
  }
}
