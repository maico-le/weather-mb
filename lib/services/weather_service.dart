import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_models.dart';

/// Custom exception for weather service errors
class WeatherServiceException implements Exception {
  final String message;
  final int? statusCode;

  const WeatherServiceException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class LocationNotFoundException extends WeatherServiceException {
  const LocationNotFoundException([super.message = 'Không tìm thấy địa điểm này. Vui lòng kiểm tra lại tên thành phố.'])
      : super(statusCode: 404);
}

class NetworkException extends WeatherServiceException {
  const NetworkException([super.message = 'Không có kết nối mạng hoặc máy chủ không phản hồi.']);
}

/// Abstract base interface for weather services.
/// Allows swapping wttr.in with Open-Meteo or another provider in the future.
abstract class WeatherServiceBase {
  Future<WeatherData> fetchWeather(String location);
}

/// Weather service implementation using https://wttr.in/{location}?format=j1&lang=vi
class WttrWeatherService implements WeatherServiceBase {
  final http.Client _client;
  final Duration timeout;

  WttrWeatherService({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _client = client ?? http.Client();

  @override
  Future<WeatherData> fetchWeather(String location) async {
    final trimmed = location.trim();
    if (trimmed.isEmpty) {
      throw const WeatherServiceException('Tên địa điểm không được để trống.');
    }

    // Convert spaces to '+' as required by wttr.in
    final formattedQuery = trimmed.replaceAll(RegExp(r'\s+'), '+');
    final uri = Uri.parse('https://wttr.in/$formattedQuery?format=j1&lang=vi');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; WeatherMb/1.0; +https://github.com)',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 404) {
        throw LocationNotFoundException('Không tìm thấy địa điểm "$trimmed".');
      }

      if (response.statusCode != 200) {
        throw WeatherServiceException(
          'Lỗi máy chủ wttr.in (${response.statusCode}). Vui lòng thử lại sau.',
          statusCode: response.statusCode,
        );
      }

      final body = utf8.decode(response.bodyBytes);
      if (body.isEmpty || body.startsWith('<')) {
        // wttr.in returned an HTML error page or empty response
        throw LocationNotFoundException('Không tìm thấy địa điểm "$trimmed".');
      }

      final dynamic decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        throw const WeatherServiceException('Dữ liệu thời tiết trả về sai định dạng.');
      }

      // Check essential keys
      if (!decoded.containsKey('current_condition') ||
          decoded['current_condition'] is! List ||
          (decoded['current_condition'] as List).isEmpty) {
        throw LocationNotFoundException('Không tìm thấy thông tin thời tiết cho "$trimmed".');
      }

      return WeatherData.fromJson(
        json: decoded,
        locationQuery: trimmed,
        updatedAt: DateTime.now(),
        isFromCache: false,
      );
    } on SocketException catch (_) {
      throw const NetworkException('Không có kết nối Internet. Vui lòng kiểm tra lại mạng.');
    } on TimeoutException catch (_) {
      throw const NetworkException('Kết nối quá thời gian chờ (10s). Vui lòng thử lại.');
    } on FormatException catch (e) {
      throw WeatherServiceException('Lỗi đọc dữ liệu thời tiết: ${e.message}');
    } on WeatherServiceException {
      rethrow;
    } catch (e) {
      throw WeatherServiceException('Đã xảy ra lỗi: $e');
    }
  }
}
