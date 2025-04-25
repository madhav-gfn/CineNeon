import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<String> genres;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genres,
  });

  String get fullPosterPath =>
      posterPath.isNotEmpty
          ? '${Config.tmdbImageBaseUrl}$posterPath'
          : 'https://via.placeholder.com/500x750?text=No+Poster';

  String get fullBackdropPath =>
      backdropPath.isNotEmpty
          ? '${Config.tmdbImageBaseUrl}$backdropPath'
          : 'https://via.placeholder.com/500x281?text=No+Backdrop';

  factory Movie.fromJson(Map<String, dynamic> json, {List<Genre>? allGenres}) {
    List<String> movieGenres = [];

    if (allGenres != null && json['genre_ids'] != null) {
      List<dynamic> genreIds = json['genre_ids'];
      movieGenres =
          genreIds.map((id) {
            return allGenres
                .firstWhere(
                  (genre) => genre.id == id,
                  orElse: () => Genre(id: -1, name: 'Unknown'),
                )
                .name;
          }).toList();
    }

    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genres: movieGenres,
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
}

class Review {
  final String author;
  final String content;
  final double rating;

  Review({required this.author, required this.content, required this.rating});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      rating:
          json['author_details'] != null
              ? (json['author_details']['rating'] ?? 0.0).toDouble()
              : 0.0,
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  List<Movie> watchlist;
  List<Movie> watchedMovies;
  Map<int, double> movieRatings; // Map of movie IDs to user ratings

  User({
    required this.id,
    required this.username,
    required this.email,
    this.watchlist = const [],
    this.watchedMovies = const [],
    this.movieRatings = const {},
  });
}

class TMDBApi {
  final http.Client _client;
  final String apiKey;

  TMDBApi({http.Client? client, String? apiKey}) 
      : _client = client ?? http.Client(),
        apiKey = apiKey ?? Config.tmdbApiKey;

  List<Genre>? _genres;

  Future<List<Genre>> getGenres() async {
    if (_genres != null) return _genres!;

    final url = '${Config.tmdbBaseUrl}/genre/movie/list?api_key=$apiKey';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _genres =
          (data['genres'] as List)
              .map((genre) => Genre.fromJson(genre))
              .toList();
      return _genres!;
    } else {
      throw Exception('Failed to load genres');
    }
  }

  Future<List<Movie>> getTrendingMovies() async {
    final genres = await getGenres();
    final url = '${Config.tmdbBaseUrl}/trending/movie/week?api_key=$apiKey';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movie) => Movie.fromJson(movie, allGenres: genres))
          .toList();
    } else {
      throw Exception('Failed to load trending movies');
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    final genres = await getGenres();
    final url = '${Config.tmdbBaseUrl}/movie/popular?api_key=$apiKey';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movie) => Movie.fromJson(movie, allGenres: genres))
          .toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final genres = await getGenres();
    final url = '${Config.tmdbBaseUrl}/movie/$movieId?api_key=$apiKey';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> movieGenres = [];

      if (data['genres'] != null) {
        movieGenres =
            (data['genres'] as List)
                .map((genre) => genre['name'] as String)
                .toList();
      }

      return Movie(
        id: data['id'],
        title: data['title'] ?? '',
        overview: data['overview'] ?? '',
        posterPath: data['poster_path'] ?? '',
        backdropPath: data['backdrop_path'] ?? '',
        voteAverage: (data['vote_average'] ?? 0.0).toDouble(),
        releaseDate: data['release_date'] ?? '',
        genres: movieGenres,
      );
    } else {
      throw Exception('Failed to load movie details');
    }
  }

  Future<List<Review>> getMovieReviews(int movieId) async {
    final url = '${Config.tmdbBaseUrl}/movie/$movieId/reviews?api_key=$apiKey';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((review) => Review.fromJson(review))
          .toList();
    } else {
      throw Exception('Failed to load movie reviews');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    final genres = await getGenres();
    final url =
        '${Config.tmdbBaseUrl}/search/movie?api_key=$apiKey&query=${Uri.encodeComponent(query)}';
    final response = await _client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((movie) => Movie.fromJson(movie, allGenres: genres))
          .toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }
}
