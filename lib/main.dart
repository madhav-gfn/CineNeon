// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'app_router.dart';
import 'widgets.dart'; // For access to app theme

void main() {
  runApp(CineNeonApp());
}

class CineNeonApp extends StatelessWidget {
  const CineNeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<MoviesProvider>(
          create: (_) => MoviesProvider(),
        ),
        ChangeNotifierProvider<UserListsProvider>(
          create: (context) => UserListsProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'CineNeon',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
