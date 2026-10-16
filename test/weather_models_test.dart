import 'package:flutter_test/flutter_test.dart';
import 'package:weather_mb/models/weather_models.dart';

void main() {
  group('Weather Models & Converters Test', () {
    test('safeDouble and safeInt handle edge cases without throwing', () {
      expect(safeDouble('32.5'), 32.5);
      expect(safeDouble('10'), 10.0);
      expect(safeDouble(null, 5.0), 5.0);
      expect(safeDouble('invalid', 0.0), 0.0);
      expect(safeDouble(''), 0.0);

      expect(safeInt('85'), 85);
      expect(safeInt(null, 10), 10);
      expect(safeInt('abc', -1), -1);
      expect(safeInt(''), 0);
    });

    test('celsiusToFahrenheit calculates correctly', () {
      expect(celsiusToFahrenheit(0), 32.0);
      expect(celsiusToFahrenheit(100), 212.0);
      expect(celsiusToFahrenheit(30).round(), 86);
    });

    test('CurrentCondition parses from JSON correctly', () {
      final json = {
        'temp_C': '28',
        'FeelsLikeC': '32',
        'humidity': '81',
        'windspeedKmph': '6',
        'winddir16Point': 'N',
        'uvIndex': '2',
        'visibility': '10',
        'pressure': '1012',
        'weatherCode': '176',
        'lang_vi': [
          {'value': 'Mưa rào rải rác'}
        ],
        'weatherDesc': [
          {'value': 'Patchy rain nearby'}
        ],
        'observation_time': '01:24 AM'
      };

      final current = CurrentCondition.fromJson(json);
      expect(current.tempC, 28.0);
      expect(current.tempF.round(), 82);
      expect(current.feelsLikeC, 32.0);
      expect(current.humidity, 81);
      expect(current.windSpeedKmph, 6.0);
      expect(current.windDir16Point, 'N');
      expect(current.uvIndex, 2);
      expect(current.visibilityKm, 10.0);
      expect(current.pressureHpa, 1012.0);
      expect(current.weatherCode, '176');
      expect(current.weatherDesc, 'Mưa rào rải rác');
    });

    test('HourForecast formats time and handles night detection', () {
      final hour1 = HourForecast.fromJson({
        'time': '300',
        'tempC': '24',
        'chanceofrain': '38',
        'weatherCode': '143',
        'weatherDesc': [{'value': 'Mist'}]
      });

      expect(hour1.formattedTime, '03:00');
      expect(hour1.hourOfDay, 3);
      expect(hour1.isNight, isTrue);
      expect(hour1.tempC, 24.0);
      expect(hour1.chanceOfRain, 38);

      final hour2 = HourForecast.fromJson({
        'time': '1200',
        'tempC': '33',
        'chanceofrain': '15',
        'weatherCode': '176'
      });

      expect(hour2.formattedTime, '12:00');
      expect(hour2.hourOfDay, 12);
      expect(hour2.isNight, isFalse);
    });

    test('DayForecast parses 3-day data with astronomy', () {
      final dayJson = {
        'date': '2026-10-18',
        'maxtempC': '33',
        'mintempC': '24',
        'astronomy': [
          {'sunrise': '05:43 AM', 'sunset': '05:35 PM'}
        ],
        'hourly': [
          {'time': '0', 'tempC': '25', 'chanceofrain': '50', 'weatherCode': '353'},
          {'time': '1200', 'tempC': '33', 'chanceofrain': '10', 'weatherCode': '113'}
        ]
      };

      final day = DayForecast.fromJson(dayJson);
      expect(day.dateString, '2026-10-18');
      expect(day.maxTempC, 33.0);
      expect(day.minTempC, 24.0);
      expect(day.sunrise, '05:43 AM');
      expect(day.sunset, '05:35 PM');
      expect(day.hourly.length, 2);
    });

    test('WeatherData parses full JSON hierarchy', () {
      final rootJson = {
        'nearest_area': [
          {
            'areaName': [{'value': 'Ho Chi Minh City'}],
            'country': [{'value': 'Vietnam'}]
          }
        ],
        'current_condition': [
          {
            'temp_C': '30',
            'FeelsLikeC': '34',
            'humidity': '75',
            'windspeedKmph': '10',
            'winddir16Point': 'SE',
            'uvIndex': '6',
            'visibility': '10',
            'pressure': '1010',
            'weatherCode': '113',
            'weatherDesc': [{'value': 'Sunny'}]
          }
        ],
        'weather': [
          {
            'date': '2026-10-16',
            'maxtempC': '32',
            'mintempC': '25',
            'astronomy': [{'sunrise': '05:43 AM', 'sunset': '05:35 PM'}],
            'hourly': []
          }
        ]
      };

      final weather = WeatherData.fromJson(
        json: rootJson,
        locationQuery: 'Ho+Chi+Minh+City',
      );

      expect(weather.displayName, 'Ho Chi Minh City');
      expect(weather.country, 'Vietnam');
      expect(weather.current.tempC, 30.0);
      expect(weather.days.length, 1);
      expect(weather.isFromCache, isFalse);
    });
  });
}
