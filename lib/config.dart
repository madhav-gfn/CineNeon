// Configuration constants for the app
class Config {
  // IMPORTANT: Replace this with your actual TMDB API key
  // Get your API key from: https://www.themoviedb.org/settings/api
  static const String tmdbApiKey = '10f2eb6c12a12d071188f5aa660fc7d6';

  // Base URLs
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  // Validate configuration
  static void validate() {
    if (tmdbApiKey.isEmpty) {
      throw Exception('TMDB API key is not configured. '
          'Please set the TMDB_API_KEY environment variable.');
    }
  }
}
