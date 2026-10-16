import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_models.dart';

class CacheService {
  static const String keyFavoriteLocations = 'favorite_locations';
  static const String keyDefaultLocation = 'default_location';
  static const String keyTempUnit = 'temperature_unit';
  static const String keyPrefixCache = 'weather_cache_';
  static const String keyPrefixTime = 'weather_cache_time_';

  static const String fallbackDefaultLocation = 'Ho Chi Minh City';
  static const List<String> defaultFavorites = [
    'Ho Chi Minh City',
    'Hanoi',
    'Da Nang',
  ];

  final SharedPreferences _prefs;

  CacheService(this._prefs);

  static Future<CacheService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return CacheService(prefs);
  }

  // --- Normalization helper ---
  String _normalizeLocationKey(String loc) =>
      loc.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  // --- Cache Weather Data ---
  Future<void> saveWeatherCache(String location, WeatherData data) async {
    final norm = _normalizeLocationKey(location);
    final jsonStr = jsonEncode(data.rawJson);
    final timestamp = data.updatedAt.millisecondsSinceEpoch;

    await _prefs.setString('$keyPrefixCache$norm', jsonStr);
    await _prefs.setInt('$keyPrefixTime$norm', timestamp);
  }

  WeatherData? getCachedWeather(String location) {
    final norm = _normalizeLocationKey(location);
    final jsonStr = _prefs.getString('$keyPrefixCache$norm');
    final timeMillis = _prefs.getInt('$keyPrefixTime$norm');

    if (jsonStr == null || timeMillis == null) return null;

    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is! Map<String, dynamic>) return null;

      final updatedAt = DateTime.fromMillisecondsSinceEpoch(timeMillis);
      return WeatherData.fromJson(
        json: decoded,
        locationQuery: location,
        updatedAt: updatedAt,
        isFromCache: true,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? getCacheTimestamp(String location) {
    final norm = _normalizeLocationKey(location);
    final timeMillis = _prefs.getInt('$keyPrefixTime$norm');
    if (timeMillis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timeMillis);
  }

  bool isCacheStale(String location, {Duration threshold = const Duration(minutes: 30)}) {
    final timestamp = getCacheTimestamp(location);
    if (timestamp == null) return true;
    final age = DateTime.now().difference(timestamp);
    return age > threshold;
  }

  Future<void> clearAllWeatherCache() async {
    final keys = _prefs.getKeys();
    for (final k in keys) {
      if (k.startsWith(keyPrefixCache) || k.startsWith(keyPrefixTime)) {
        await _prefs.remove(k);
      }
    }
  }

  // --- Favorite Locations (Max 5) ---
  List<String> getFavoriteLocations() {
    final list = _prefs.getStringList(keyFavoriteLocations);
    if (list == null || list.isEmpty) {
      return List.from(defaultFavorites);
    }
    return list;
  }

  Future<bool> addFavoriteLocation(String location) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty) return false;

    final current = getFavoriteLocations();
    // Check if already in favorites (case-insensitive)
    final existingIndex = current.indexWhere((l) => l.toLowerCase() == trimmed.toLowerCase());
    if (existingIndex >= 0) {
      return false; // Already present
    }

    if (current.length >= 5) {
      // Limit to 5 favorites
      current.removeLast();
    }
    current.insert(0, trimmed);
    return await _prefs.setStringList(keyFavoriteLocations, current);
  }

  Future<bool> removeFavoriteLocation(String location) async {
    final current = getFavoriteLocations();
    current.removeWhere((l) => l.toLowerCase() == location.trim().toLowerCase());
    return await _prefs.setStringList(keyFavoriteLocations, current);
  }

  // --- Default Location ---
  String getDefaultLocation() {
    final def = _prefs.getString(keyDefaultLocation);
    if (def == null || def.trim().isEmpty) {
      return fallbackDefaultLocation;
    }
    return def;
  }

  Future<void> setDefaultLocation(String location) async {
    await _prefs.setString(keyDefaultLocation, location.trim());
  }

  // --- Temperature Unit ---
  TemperatureUnit getTemperatureUnit() {
    final val = _prefs.getString(keyTempUnit);
    if (val == 'F') return TemperatureUnit.fahrenheit;
    return TemperatureUnit.celsius;
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await _prefs.setString(keyTempUnit, unit == TemperatureUnit.fahrenheit ? 'F' : 'C');
  }

  // --- GitHub Repository for Auto Update ---
  static const String keyGithubRepo = 'github_repo';

  String getGithubRepo() {
    return _prefs.getString(keyGithubRepo) ?? '';
  }

  Future<void> setGithubRepo(String repo) async {
    await _prefs.setString(keyGithubRepo, repo.trim());
  }
}
