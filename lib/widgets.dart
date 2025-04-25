import 'package:flutter/material.dart';
import 'models_and_api.dart';

// App Theme
class AppTheme {
  static final ThemeData lightTheme = ThemeData.light();
  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF121212),
    primaryColor: Colors.redAccent,
    colorScheme: ColorScheme.dark(
      primary: Colors.redAccent,
      secondary: Colors.redAccent,
      surface: Color(0xFF212121),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF212121),
      elevation: 0,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF212121),
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.white54,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}

// Movie Card (Standard Card)
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Color(0xFF212121),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Image.network(
              movie.fullPosterPath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie.title,
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Feature Movie Card (Large horizontal card for trending section)
class FeatureMovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;

  const FeatureMovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        margin: EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Color(0xFF212121),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Backdrop
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                movie.fullBackdropPath,
                width: 250,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                movie.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  RatingStars(rating: movie.voteAverage),
                  SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final double spacing;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16.0,
    this.spacing = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    int totalStars = 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalStars, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }
      }).map((icon) => Padding(
        padding: EdgeInsets.only(right: spacing),
        child: icon,
      )).toList(),
    );
  }
}

class UserRatingWidget extends StatefulWidget {
  final Movie movie;
  final double? initialRating;
  final Function(double) onRatingChanged;

  const UserRatingWidget({
    super.key,
    required this.movie,
    this.initialRating,
    required this.onRatingChanged,
  });

  @override
  _UserRatingWidgetState createState() => _UserRatingWidgetState();
}

class _UserRatingWidgetState extends State<UserRatingWidget> {
  double _rating = 0.0;
  bool _isRating = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Rating',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_rating > 0 && !_isRating)
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRating = true;
                  });
                },
                child: Text(
                  'Edit',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        if (_rating > 0 && !_isRating) ...[  
          Row(
            children: [
              RatingStars(rating: _rating / 2), // Convert to 5-star scale for display
              SizedBox(width: 8),
              Text(
                _rating.toStringAsFixed(1),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ] else ...[  
          Text(
            'Tap to rate:',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              final starValue = (index + 1).toDouble();
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starValue;
                    _isRating = false;
                  });
                  widget.onRatingChanged(starValue);
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    starValue.toInt().toString(),
                    style: TextStyle(
                      color: _rating >= starValue ? Colors.amber : Colors.white70,
                      fontSize: 18,
                      fontWeight: _rating >= starValue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
