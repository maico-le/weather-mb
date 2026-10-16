import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:weather_mb/services/weather_service.dart';

void main() {
  group('WttrWeatherService Tests', () {
    test('Successful API response parses WeatherData correctly', () async {
      final sampleJson = {
        'nearest_area': [
          {
            'areaName': [{'value': 'Ho Chi Minh City'}],
            'country': [{'value': 'Vietnam'}]
          }
        ],
        'current_condition': [
          {
            'temp_C': '28',
            'FeelsLikeC': '32',
            'humidity': '81',
            'windspeedKmph': '6',
            'winddir16Point': 'N',
            'uvIndex': '2',
            'visibility': '10',
            'pressure': '1012',
            'weatherCode': '176',
            'lang_vi': [{'value': 'Mưa rào nhẹ'}],
            'weatherDesc': [{'value': 'Light rain shower'}],
            'observation_time': '01:24 AM'
          }
        ],
        'weather': [
          {
            'date': '2026-10-18',
            'maxtempC': '33',
            'mintempC': '24',
            'astronomy': [{'sunrise': '05:43 AM', 'sunset': '05:35 PM'}],
            'hourly': [
              {
                'time': '300',
                'tempC': '24',
                'chanceofrain': '38',
                'weatherCode': '143',
                'lang_vi': [{'value': 'Sương mù'}]
              }
            ]
          }
        ]
      };

      final client = MockClient((request) async {
        expect(request.url.path, '/Ho+Chi+Minh+City');
        expect(request.url.queryParameters['format'], 'j1');
        expect(request.url.queryParameters['lang'], 'vi');
        return http.Response(jsonEncode(sampleJson), 200, headers: {
          'content-type': 'application/json; charset=utf-8',
        });
      });

      final service = WttrWeatherService(client: client);
      final data = await service.fetchWeather('Ho Chi Minh City');

      expect(data.displayName, 'Ho Chi Minh City');
      expect(data.current.tempC, 28.0);
      expect(data.current.weatherDesc, 'Mưa rào nhẹ');
      expect(data.days.length, 1);
      expect(data.days.first.hourly.length, 1);
      expect(data.isFromCache, isFalse);
    });

    test('HTTP 404 throws LocationNotFoundException', () async {
      final client = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      final service = WttrWeatherService(client: client);
      expect(
        () => service.fetchWeather('UnknownCity12345'),
        throwsA(isA<LocationNotFoundException>()),
      );
    });

    test('HTTP 500 throws WeatherServiceException', () async {
      final client = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final service = WttrWeatherService(client: client);
      expect(
        () => service.fetchWeather('Hanoi'),
        throwsA(isA<WeatherServiceException>()),
      );
    });

    test('Empty location throws WeatherServiceException', () async {
      final service = WttrWeatherService();
      expect(
        () => service.fetchWeather('   '),
        throwsA(isA<WeatherServiceException>()),
      );
    });
  });
}
