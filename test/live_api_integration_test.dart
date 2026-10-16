import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mb/services/weather_service.dart';

void main() {
  test('Live wttr.in integration test for Ho Chi Minh City', () async {
    final service = WttrWeatherService();
    final data = await service.fetchWeather('Ho Chi Minh City');

    expect(data.displayName, isNotEmpty);
    expect(data.current.tempC, isNotNull);
    expect(data.current.weatherCode, isNotEmpty);
    expect(data.days, isNotEmpty);
    expect(data.days.length, greaterThanOrEqualTo(1));
    expect(data.isFromCache, isFalse);

    // Print summary to test output
    // ignore: avoid_print
    print('✅ LIVE TEST SUCCESS: ${data.displayName} | ${data.current.tempC}°C | ${data.current.weatherDesc} | Days: ${data.days.length}');
  });
}
