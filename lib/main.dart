import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/weather_provider.dart';
import 'screens/home_screen.dart';
import 'services/cache_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline cache service
  final cacheService = await CacheService.create();

  runApp(
    ProviderScope(
      overrides: [
        cacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const WeatherMbApp(),
    ),
  );
}

class WeatherMbApp extends StatelessWidget {
  const WeatherMbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather MB (Retro Pixel)',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFA520F), // Mistral orange
          secondary: Color(0xFFFFAF00),
          surface: Colors.white,
          error: Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSurface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121214),
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFB923C),
          secondary: Color(0xFFFBBF24),
          surface: Color(0xFF1E1E24),
          error: Color(0xFFEF4444),
          onPrimary: Colors.black,
          onSurface: Color(0xFFFAFAFA),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF18181E),
          foregroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Color(0xFFFAFAFA),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
