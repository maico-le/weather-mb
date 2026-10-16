import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_mb/models/weather_models.dart';
import 'package:weather_mb/providers/weather_provider.dart';
import 'package:weather_mb/screens/home_screen.dart';
import 'package:weather_mb/services/cache_service.dart';
import 'package:weather_mb/services/weather_service.dart';

class FakeWeatherService implements WeatherServiceBase {
  @override
  Future<WeatherData> fetchWeather(String location) async {
    return WeatherData(
      locationQuery: location,
      areaName: 'Ho Chi Minh City',
      country: 'Vietnam',
      updatedAt: DateTime(2026, 10, 16, 9, 30),
      current: const CurrentCondition(
        tempC: 32,
        feelsLikeC: 36,
        humidity: 78,
        windSpeedKmph: 12,
        windDir16Point: 'SE',
        uvIndex: 7,
        visibilityKm: 10,
        pressureHpa: 1011,
        weatherDesc: 'Nắng ấm',
        weatherCode: '113',
        observationTime: '09:30 AM',
      ),
      days: [
        DayForecast(
          dateString: '2026-10-16',
          maxTempC: 33,
          minTempC: 25,
          sunrise: '05:43 AM',
          sunset: '05:35 PM',
          weatherCode: '113',
          weatherDesc: 'Trời quang đãng',
          hourly: [
            const HourForecast(
              rawTime: '900',
              tempC: 32,
              chanceOfRain: 10,
              weatherCode: '113',
              weatherDesc: 'Nắng',
            ),
            const HourForecast(
              rawTime: '1200',
              tempC: 34,
              chanceOfRain: 20,
              weatherCode: '116',
              weatherDesc: 'Có mây rải rác',
            ),
          ],
        ),
      ],
    );
  }
}

void main() {
  testWidgets('HomeScreen renders weather data correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'weather_mb',
      packageName: 'com.example.weather_mb',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    final prefs = await SharedPreferences.getInstance();
    final cacheService = CacheService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cacheServiceProvider.overrideWithValue(cacheService),
          weatherServiceProvider.overrideWithValue(FakeWeatherService()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial loading or immediate data
    await tester.pumpAndSettle();

    // Verify location title
    expect(find.text('HO CHI MINH CITY'), findsWidgets);

    // Verify temperature
    expect(find.text('32'), findsOneWidget);
    expect(find.text('°C'), findsWidgets);

    // Verify weather description
    expect(find.text('NẮNG ẤM'), findsOneWidget);

    // Verify hourly and 3-day section titles
    expect(find.text('DỰ BÁO THEO GIỜ (HÔM NAY)'), findsOneWidget);
    expect(find.text('DỰ BÁO 3 NGÀY TỚI'), findsOneWidget);
    expect(find.text('CHỈ SỐ KHÍ TƯỢNG'), findsOneWidget);
  });
}
