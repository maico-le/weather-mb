import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_mb/models/weather_models.dart';
import 'package:weather_mb/services/cache_service.dart';

void main() {
  group('CacheService Test', () {
    late CacheService cacheService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      cacheService = CacheService(prefs);
    });

    test('Favorite locations management supports max 5 locations', () async {
      // Defaults
      final initial = cacheService.getFavoriteLocations();
      expect(initial, contains('Ho Chi Minh City'));
      expect(initial, contains('Hanoi'));

      // Add new locations
      expect(await cacheService.addFavoriteLocation('Hue'), isTrue);
      expect(await cacheService.addFavoriteLocation('Nha Trang'), isTrue);
      expect(await cacheService.addFavoriteLocation('Can Tho'), isTrue); // Reaches 5+
      expect(cacheService.getFavoriteLocations().length, lessThanOrEqualTo(5));

      // Duplicate add returns false
      expect(await cacheService.addFavoriteLocation('Hanoi'), isFalse);

      // Remove location
      expect(await cacheService.removeFavoriteLocation('Hanoi'), isTrue);
      expect(cacheService.getFavoriteLocations(), isNot(contains('Hanoi')));
    });

    test('Default location get and set works', () async {
      expect(cacheService.getDefaultLocation(), 'Ho Chi Minh City');
      await cacheService.setDefaultLocation('Tokyo');
      expect(cacheService.getDefaultLocation(), 'Tokyo');
    });

    test('Temperature unit get and set works', () async {
      expect(cacheService.getTemperatureUnit(), TemperatureUnit.celsius);
      await cacheService.setTemperatureUnit(TemperatureUnit.fahrenheit);
      expect(cacheService.getTemperatureUnit(), TemperatureUnit.fahrenheit);
    });

    test('Weather caching and staleness logic works', () async {
      final mockData = WeatherData(
        locationQuery: 'Da Nang',
        areaName: 'Da Nang',
        country: 'Vietnam',
        updatedAt: DateTime.now(),
        current: const CurrentCondition(
          tempC: 28,
          feelsLikeC: 30,
          humidity: 80,
          windSpeedKmph: 10,
          windDir16Point: 'E',
          uvIndex: 4,
          visibilityKm: 10,
          pressureHpa: 1012,
          weatherDesc: 'Sunny',
          weatherCode: '113',
          observationTime: '10:00 AM',
        ),
        days: const [],
        rawJson: {
          'nearest_area': [{'areaName': [{'value': 'Da Nang'}], 'country': [{'value': 'Vietnam'}]}],
          'current_condition': [{'temp_C': '28', 'FeelsLikeC': '30', 'humidity': '80', 'windspeedKmph': '10', 'winddir16Point': 'E', 'uvIndex': '4', 'visibility': '10', 'pressure': '1012', 'weatherCode': '113', 'weatherDesc': [{'value': 'Sunny'}]}],
          'weather': []
        },
      );

      // Initially no cache
      expect(cacheService.getCachedWeather('Da Nang'), isNull);
      expect(cacheService.isCacheStale('Da Nang'), isTrue);

      // Save cache
      await cacheService.saveWeatherCache('Da Nang', mockData);
      final cached = cacheService.getCachedWeather('Da Nang');
      expect(cached, isNotNull);
      expect(cached!.displayName, 'Da Nang');
      expect(cached.isFromCache, isTrue);
      expect(cacheService.isCacheStale('Da Nang'), isFalse);

      // Clear cache
      await cacheService.clearAllWeatherCache();
      expect(cacheService.getCachedWeather('Da Nang'), isNull);
    });
  });
}
