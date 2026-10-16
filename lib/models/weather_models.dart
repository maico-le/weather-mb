import 'package:intl/intl.dart';

enum TemperatureUnit {
  celsius,
  fahrenheit,
}

extension TemperatureUnitX on TemperatureUnit {
  String get symbol => this == TemperatureUnit.celsius ? '°C' : '°F';
  String get label => this == TemperatureUnit.celsius ? 'Celsius (°C)' : 'Fahrenheit (°F)';
}

/// Helper safe converters for strings returned by wttr.in
double safeDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  final str = value.toString().trim();
  if (str.isEmpty) return fallback;
  return double.tryParse(str) ?? fallback;
}

int safeInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toInt();
  final str = value.toString().trim();
  if (str.isEmpty) return fallback;
  return int.tryParse(str) ?? fallback;
}

String safeString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  final str = value.toString().trim();
  return str.isEmpty ? fallback : str;
}

double celsiusToFahrenheit(double c) => (c * 9.0 / 5.0) + 32.0;

/// Represents weather condition at the current moment
class CurrentCondition {
  final double tempC;
  final double feelsLikeC;
  final int humidity;
  final double windSpeedKmph;
  final String windDir16Point;
  final int uvIndex;
  final double visibilityKm;
  final double pressureHpa;
  final String weatherDesc;
  final String weatherCode;
  final String observationTime;

  const CurrentCondition({
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windSpeedKmph,
    required this.windDir16Point,
    required this.uvIndex,
    required this.visibilityKm,
    required this.pressureHpa,
    required this.weatherDesc,
    required this.weatherCode,
    required this.observationTime,
  });

  double get tempF => celsiusToFahrenheit(tempC);
  double get feelsLikeF => celsiusToFahrenheit(feelsLikeC);

  double getTemperature(TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? tempC : tempF;

  double getFeelsLike(TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? feelsLikeC : feelsLikeF;

  factory CurrentCondition.fromJson(Map<String, dynamic> json) {
    // Description can be in lang_vi or weatherDesc
    String desc = '';
    if (json['lang_vi'] is List && (json['lang_vi'] as List).isNotEmpty) {
      desc = safeString(json['lang_vi'][0]['value']);
    }
    if (desc.isEmpty && json['weatherDesc'] is List && (json['weatherDesc'] as List).isNotEmpty) {
      desc = safeString(json['weatherDesc'][0]['value']);
    }

    return CurrentCondition(
      tempC: safeDouble(json['temp_C']),
      feelsLikeC: safeDouble(json['FeelsLikeC']),
      humidity: safeInt(json['humidity']),
      windSpeedKmph: safeDouble(json['windspeedKmph']),
      windDir16Point: safeString(json['winddir16Point'], 'N'),
      uvIndex: safeInt(json['uvIndex']),
      visibilityKm: safeDouble(json['visibility']),
      pressureHpa: safeDouble(json['pressure']),
      weatherDesc: desc,
      weatherCode: safeString(json['weatherCode'], '113'),
      observationTime: safeString(json['observation_time']),
    );
  }

  Map<String, dynamic> toJson() => {
        'temp_C': tempC.toString(),
        'FeelsLikeC': feelsLikeC.toString(),
        'humidity': humidity.toString(),
        'windspeedKmph': windSpeedKmph.toString(),
        'winddir16Point': windDir16Point,
        'uvIndex': uvIndex.toString(),
        'visibility': visibilityKm.toString(),
        'pressure': pressureHpa.toString(),
        'weatherDesc': [{'value': weatherDesc}],
        'weatherCode': weatherCode,
        'observation_time': observationTime,
      };
}

/// Hourly forecast item (typically 3-hour interval in wttr.in: 0, 300, 600, 900, 1200, 1500, 1800, 2100)
class HourForecast {
  final String rawTime;
  final double tempC;
  final int chanceOfRain;
  final String weatherCode;
  final String weatherDesc;

  const HourForecast({
    required this.rawTime,
    required this.tempC,
    required this.chanceOfRain,
    required this.weatherCode,
    required this.weatherDesc,
  });

  double get tempF => celsiusToFahrenheit(tempC);

  double getTemperature(TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? tempC : tempF;

  /// Formats raw time string like "0", "300", "1200" to "00:00", "03:00", "12:00"
  String get formattedTime {
    final intTime = safeInt(rawTime, 0);
    final hours = intTime ~/ 100;
    final mins = intTime % 100;
    return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  int get hourOfDay {
    final intTime = safeInt(rawTime, 0);
    return intTime ~/ 100;
  }

  bool get isNight => hourOfDay >= 18 || hourOfDay < 6;

  factory HourForecast.fromJson(Map<String, dynamic> json) {
    String desc = '';
    if (json['lang_vi'] is List && (json['lang_vi'] as List).isNotEmpty) {
      desc = safeString(json['lang_vi'][0]['value']);
    }
    if (desc.isEmpty && json['weatherDesc'] is List && (json['weatherDesc'] as List).isNotEmpty) {
      desc = safeString(json['weatherDesc'][0]['value']);
    }

    return HourForecast(
      rawTime: safeString(json['time'], '0'),
      tempC: safeDouble(json['tempC']),
      chanceOfRain: safeInt(json['chanceofrain']),
      weatherCode: safeString(json['weatherCode'], '113'),
      weatherDesc: desc,
    );
  }

  Map<String, dynamic> toJson() => {
        'time': rawTime,
        'tempC': tempC.toString(),
        'chanceofrain': chanceOfRain.toString(),
        'weatherCode': weatherCode,
        'weatherDesc': [{'value': weatherDesc}],
      };
}

/// Daily forecast for 1 day
class DayForecast {
  final String dateString;
  final double maxTempC;
  final double minTempC;
  final String sunrise;
  final String sunset;
  final String weatherCode;
  final String weatherDesc;
  final List<HourForecast> hourly;

  const DayForecast({
    required this.dateString,
    required this.maxTempC,
    required this.minTempC,
    required this.sunrise,
    required this.sunset,
    required this.weatherCode,
    required this.weatherDesc,
    required this.hourly,
  });

  double get maxTempF => celsiusToFahrenheit(maxTempC);
  double get minTempF => celsiusToFahrenheit(minTempC);

  double getMaxTemperature(TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? maxTempC : maxTempF;

  double getMinTemperature(TemperatureUnit unit) =>
      unit == TemperatureUnit.celsius ? minTempC : minTempF;

  DateTime? get date => DateTime.tryParse(dateString);

  String get formattedDayName {
    final parsed = date;
    if (parsed == null) return dateString;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff == 2) return 'Ngày kia';

    try {
      final weekday = DateFormat('EEEE', 'vi').format(parsed);
      return weekday.replaceFirst('Thứ ', 'T');
    } catch (_) {
      const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
      return weekdays[parsed.weekday - 1];
    }
  }

  String get formattedDateShort {
    final parsed = date;
    if (parsed == null) return dateString;
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}';
  }

  factory DayForecast.fromJson(Map<String, dynamic> json) {
    // astronomy
    String sunrise = '06:00 AM';
    String sunset = '06:00 PM';
    if (json['astronomy'] is List && (json['astronomy'] as List).isNotEmpty) {
      final astro = json['astronomy'][0] as Map<String, dynamic>;
      sunrise = safeString(astro['sunrise'], sunrise);
      sunset = safeString(astro['sunset'], sunset);
    }

    // hourly
    final hourlyList = <HourForecast>[];
    if (json['hourly'] is List) {
      for (final h in json['hourly'] as List) {
        if (h is Map<String, dynamic>) {
          hourlyList.add(HourForecast.fromJson(h));
        }
      }
    }

    // representative weatherCode from midday or first hourly
    String code = '113';
    String desc = '';
    if (hourlyList.isNotEmpty) {
      // Pick midday hour (e.g. 12:00 or closest)
      final mid = hourlyList.firstWhere(
        (h) => h.hourOfDay >= 12,
        orElse: () => hourlyList.first,
      );
      code = mid.weatherCode;
      desc = mid.weatherDesc;
    }

    return DayForecast(
      dateString: safeString(json['date']),
      maxTempC: safeDouble(json['maxtempC']),
      minTempC: safeDouble(json['mintempC']),
      sunrise: sunrise,
      sunset: sunset,
      weatherCode: code,
      weatherDesc: desc,
      hourly: hourlyList,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': dateString,
        'maxtempC': maxTempC.toString(),
        'mintempC': minTempC.toString(),
        'astronomy': [
          {'sunrise': sunrise, 'sunset': sunset}
        ],
        'hourly': hourly.map((h) => h.toJson()).toList(),
      };
}

/// Complete weather package for a location
class WeatherData {
  final String locationQuery;
  final String areaName;
  final String country;
  final CurrentCondition current;
  final List<DayForecast> days;
  final DateTime updatedAt;
  final bool isFromCache;
  final Map<String, dynamic> rawJson;

  const WeatherData({
    required this.locationQuery,
    required this.areaName,
    required this.country,
    required this.current,
    required this.days,
    required this.updatedAt,
    this.isFromCache = false,
    this.rawJson = const {},
  });

  /// Readable display name for location
  String get displayName {
    final cleanQuery = locationQuery.replaceAll('+', ' ').trim();
    if (cleanQuery.isNotEmpty) {
      return cleanQuery;
    }
    if (areaName.isNotEmpty) {
      return areaName;
    }
    return 'Thời tiết';
  }

  WeatherData copyWith({
    String? locationQuery,
    String? areaName,
    String? country,
    CurrentCondition? current,
    List<DayForecast>? days,
    DateTime? updatedAt,
    bool? isFromCache,
    Map<String, dynamic>? rawJson,
  }) {
    return WeatherData(
      locationQuery: locationQuery ?? this.locationQuery,
      areaName: areaName ?? this.areaName,
      country: country ?? this.country,
      current: current ?? this.current,
      days: days ?? this.days,
      updatedAt: updatedAt ?? this.updatedAt,
      isFromCache: isFromCache ?? this.isFromCache,
      rawJson: rawJson ?? this.rawJson,
    );
  }

  factory WeatherData.fromJson({
    required Map<String, dynamic> json,
    required String locationQuery,
    DateTime? updatedAt,
    bool isFromCache = false,
  }) {
    // Current condition
    CurrentCondition current;
    if (json['current_condition'] is List && (json['current_condition'] as List).isNotEmpty) {
      current = CurrentCondition.fromJson(json['current_condition'][0] as Map<String, dynamic>);
    } else {
      throw const FormatException('Missing current_condition in weather response');
    }

    // Days forecast (3 days)
    final days = <DayForecast>[];
    if (json['weather'] is List) {
      for (final d in json['weather'] as List) {
        if (d is Map<String, dynamic>) {
          days.add(DayForecast.fromJson(d));
        }
      }
    }

    // Nearest area
    String areaName = '';
    String country = '';
    if (json['nearest_area'] is List && (json['nearest_area'] as List).isNotEmpty) {
      final area = json['nearest_area'][0] as Map<String, dynamic>;
      if (area['areaName'] is List && (area['areaName'] as List).isNotEmpty) {
        areaName = safeString(area['areaName'][0]['value']);
      }
      if (area['country'] is List && (area['country'] as List).isNotEmpty) {
        country = safeString(area['country'][0]['value']);
      }
    }

    return WeatherData(
      locationQuery: locationQuery,
      areaName: areaName.isEmpty ? locationQuery.replaceAll('+', ' ') : areaName,
      country: country,
      current: current,
      days: days,
      updatedAt: updatedAt ?? DateTime.now(),
      isFromCache: isFromCache,
      rawJson: json,
    );
  }
}
