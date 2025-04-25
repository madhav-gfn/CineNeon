# CineNeon

A Flutter movie app using The Movie Database (TMDB) API.

## Setup Instructions

1. Get a free API key from [The Movie Database](https://www.themoviedb.org/)
2. Set the API key as an environment variable:
   ```bash
   export TMDB_API_KEY=your_api_key_here
   ```
3. Run the app with Flutter:
   ```bash
   flutter run
   ```

## Configuration

The app uses the following environment variables:
- `TMDB_API_KEY`: Your TMDB API key (required)

## Features

- Browse trending and popular movies
- View movie details and reviews
- Save movies to watchlist (requires login)

## Technical Details

- Flutter framework
- Provider for state management
- TMDB API integration
- SharedPreferences for local storage
