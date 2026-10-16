import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_models.dart';
import '../services/cache_service.dart';
import '../services/notification_service.dart';
import '../services/weather_service.dart';

// --- Base Services Providers ---
final cacheServiceProvider = Provider<CacheService>((ref) {
  throw UnimplementedError('cacheServiceProvider must be overridden in main() with initialized instance');
});

final weatherServiceProvider = Provider<WeatherServiceBase>((ref) {
  return WttrWeatherService();
});

// --- Temperature Unit Provider ---
class TemperatureUnitNotifier extends Notifier<TemperatureUnit> {
  @override
  TemperatureUnit build() {
    final cache = ref.watch(cacheServiceProvider);
    return cache.getTemperatureUnit();
  }

  Future<void> setUnit(TemperatureUnit unit) async {
    state = unit;
    await ref.read(cacheServiceProvider).setTemperatureUnit(unit);
  }

  void toggle() {
    setUnit(state == TemperatureUnit.celsius ? TemperatureUnit.fahrenheit : TemperatureUnit.celsius);
  }
}

final temperatureUnitProvider =
    NotifierProvider<TemperatureUnitNotifier, TemperatureUnit>(TemperatureUnitNotifier.new);

// --- Default Location Provider ---
class DefaultLocationNotifier extends Notifier<String> {
  @override
  String build() {
    final cache = ref.watch(cacheServiceProvider);
    return cache.getDefaultLocation();
  }

  Future<void> setDefaultLocation(String location) async {
    state = location.trim();
    await ref.read(cacheServiceProvider).setDefaultLocation(state);
  }
}

final defaultLocationProvider =
    NotifierProvider<DefaultLocationNotifier, String>(DefaultLocationNotifier.new);

// --- Favorite Locations Provider ---
class FavoriteLocationsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    final cache = ref.watch(cacheServiceProvider);
    return cache.getFavoriteLocations();
  }

  Future<bool> addLocation(String location) async {
    final cache = ref.read(cacheServiceProvider);
    final success = await cache.addFavoriteLocation(location);
    if (success) {
      state = cache.getFavoriteLocations();
    }
    return success;
  }

  Future<void> removeLocation(String location) async {
    final cache = ref.read(cacheServiceProvider);
    await cache.removeFavoriteLocation(location);
    state = cache.getFavoriteLocations();
  }
}

final favoriteLocationsProvider =
    NotifierProvider<FavoriteLocationsNotifier, List<String>>(FavoriteLocationsNotifier.new);

// --- Selected Location Provider ---
class SelectedLocationNotifier extends Notifier<String> {
  @override
  String build() {
    return ref.watch(defaultLocationProvider);
  }

  void selectLocation(String location) {
    if (location.trim().isNotEmpty && location.trim() != state) {
      state = location.trim();
    }
  }
}

final selectedLocationProvider =
    NotifierProvider<SelectedLocationNotifier, String>(SelectedLocationNotifier.new);

// --- Weather AsyncNotifier ---
class WeatherNotifier extends AsyncNotifier<WeatherData> {
  @override
  FutureOr<WeatherData> build() async {
    final location = ref.watch(selectedLocationProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final weatherService = ref.watch(weatherServiceProvider);

    final cached = cacheService.getCachedWeather(location);
    final isStale = cacheService.isCacheStale(location);

    // If cache is fresh, return it immediately
    if (cached != null && !isStale) {
      return cached;
    }

    try {
      final fresh = await weatherService.fetchWeather(location);
      await cacheService.saveWeatherCache(location, fresh);
      _syncScheduledNotification(cacheService, location, fresh);
      return fresh;
    } catch (e) {
      // If network fails but cache exists (even stale), return cache marked with isFromCache
      if (cached != null) {
        return cached.copyWith(isFromCache: true);
      }
      rethrow;
    }
  }

  void _syncScheduledNotification(CacheService cacheService, String location, WeatherData data) {
    if (cacheService.isDailyNotificationEnabled() &&
        location.trim().toLowerCase() == cacheService.getDefaultLocation().trim().toLowerCase()) {
      final unit = cacheService.getTemperatureUnit();
      NotificationService.instance.scheduleDailyMorningWeatherNotification(
        locationName: location,
        weatherData: data,
        unit: unit,
      );
    }
  }

  Future<void> loadWeather({bool forceRefresh = false}) async {
    final location = ref.read(selectedLocationProvider);
    final cacheService = ref.read(cacheServiceProvider);
    final weatherService = ref.read(weatherServiceProvider);

    final cached = cacheService.getCachedWeather(location);

    if (forceRefresh) {
      state = const AsyncLoading();
      try {
        final fresh = await weatherService.fetchWeather(location);
        await cacheService.saveWeatherCache(location, fresh);
        _syncScheduledNotification(cacheService, location, fresh);
        state = AsyncData(fresh);
      } catch (e, stack) {
        if (cached != null) {
          state = AsyncData(cached.copyWith(isFromCache: true));
        } else {
          state = AsyncError(e, stack);
        }
      }
    } else {
      ref.invalidateSelf();
    }
  }
}

final weatherNotifierProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherData>(WeatherNotifier.new);
