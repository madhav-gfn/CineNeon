import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'screens.dart';
import 'providers.dart';

class AppRouter {
  static const String home = '/';
  static const String login = '/login';
  static const String movieDetails = '/movie';
  static const String watchlist = '/watchlist';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
        
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
        
      case movieDetails:
        final movieId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => MovieDetailsScreen(movieId: movieId),
        );
        
      case watchlist:
        return MaterialPageRoute(builder: (_) => WatchlistScreen());
        
      case search:
        return MaterialPageRoute(builder: (_) => SearchScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Widget getInitialScreen(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isAuthenticated) {
      return HomeScreen();
    } else {
      return FutureBuilder<bool>(
        future: authProvider.checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (snapshot.data == true) {
            return HomeScreen();
          } else {
            return LoginScreen();
          }
        },
      );
    }
  }
}

class AppNavigator {
  static void navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRouter.home, 
      (route) => false,
    );
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRouter.login, 
      (route) => false,
    );
  }

  static void navigateToMovieDetails(BuildContext context, int movieId) {
    Navigator.pushNamed(
      context,
      AppRouter.movieDetails,
      arguments: movieId,
    );
  }

  static void navigateToWatchlist(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.watchlist);
  }

  static void navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.search);
  }
}
