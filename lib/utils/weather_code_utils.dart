import 'package:flutter/material.dart';

enum WeatherCategory {
  sunny,
  partlyCloudy,
  cloudy,
  foggy,
  rainy,
  thunder,
  snowy,
  night,
}

/// Utility for translating weather codes, icons and dynamic pixel themes
class WeatherCodeUtils {
  /// Map of WWO weather codes to Vietnamese descriptions
  static const Map<String, String> _viDescriptions = {
    '113': 'Trời quang đãng / Nắng',
    '116': 'Có mây rải rác',
    '119': 'Nhiều mây',
    '122': 'Trời âm u',
    '143': 'Sương mù nhẹ',
    '176': 'Mưa rào rải rác',
    '179': 'Mưa tuyết rải rác',
    '182': 'Mưa đá rải rác',
    '185': 'Mưa phùn buốt giá',
    '200': 'Có dông sét rải rác',
    '227': 'Gió tuyết cuốn',
    '230': 'Bão tuyết lớn',
    '248': 'Sương mù dày đặc',
    '260': 'Sương giá đóng băng',
    '263': 'Mưa phùn nhẹ ngắt quãng',
    '266': 'Mưa phùn nhẹ',
    '281': 'Mưa phùn buốt giá',
    '284': 'Mưa phùn đóng băng hạt to',
    '293': 'Mưa nhẹ từng đợt',
    '296': 'Mưa nhẹ',
    '299': 'Mưa vừa từng đợt',
    '302': 'Mưa vừa',
    '305': 'Mưa to từng đợt',
    '308': 'Mưa to xối xả',
    '311': 'Mưa lạnh buốt',
    '314': 'Mưa buốt nặng hạt',
    '317': 'Mưa tuyết nhẹ',
    '320': 'Mưa tuyết dày',
    '323': 'Tuyết rơi nhẹ rải rác',
    '326': 'Tuyết nhẹ',
    '329': 'Tuyết vừa từng đợt',
    '332': 'Tuyết vừa',
    '335': 'Tuyết rơi dày từng đợt',
    '338': 'Bão tuyết nặng',
    '350': 'Mưa đá nhỏ',
    '353': 'Mưa rào nhẹ',
    '356': 'Mưa rào vừa và nặng',
    '359': 'Mưa rào rất lớn',
    '362': 'Mưa rào tuyết nhẹ',
    '365': 'Mưa rào tuyết vừa/nặng',
    '368': 'Mưa tuyết nhẹ',
    '371': 'Tuyết rơi dày',
    '374': 'Mưa đá nhẹ',
    '377': 'Mưa đá to',
    '386': 'Mưa rải rác có sấm chớp',
    '389': 'Mưa to kèm sấm sét dữ dội',
    '392': 'Tuyết rơi kèm dông sét',
    '395': 'Bão tuyết kèm dông sét',
  };

  /// Get localized Vietnamese description
  static String getVietnameseDescription(String code, [String fallback = '']) {
    if (_viDescriptions.containsKey(code)) {
      return _viDescriptions[code]!;
    }
    return fallback.isNotEmpty ? fallback : 'Thời tiết ổn định';
  }

  /// Classify weather code into general category
  static WeatherCategory getCategory(String code, {bool isNight = false}) {
    if (isNight && code == '113') {
      return WeatherCategory.night;
    }

    switch (code) {
      case '113':
        return isNight ? WeatherCategory.night : WeatherCategory.sunny;
      case '116':
        return WeatherCategory.partlyCloudy;
      case '119':
      case '122':
        return WeatherCategory.cloudy;
      case '143':
      case '248':
      case '260':
        return WeatherCategory.foggy;
      case '200':
      case '386':
      case '389':
      case '392':
      case '395':
        return WeatherCategory.thunder;
      case '179':
      case '182':
      case '227':
      case '230':
      case '323':
      case '326':
      case '329':
      case '332':
      case '335':
      case '338':
      case '368':
      case '371':
        return WeatherCategory.snowy;
      case '176':
      case '185':
      case '263':
      case '266':
      case '281':
      case '284':
      case '293':
      case '296':
      case '299':
      case '302':
      case '305':
      case '308':
      case '311':
      case '314':
      case '317':
      case '320':
      case '350':
      case '353':
      case '356':
      case '359':
      case '362':
      case '365':
      case '374':
      case '377':
      default:
        return WeatherCategory.rainy;
    }
  }

  /// Fallback Material Icon
  static IconData getMaterialIcon(String code, {bool isNight = false}) {
    final cat = getCategory(code, isNight: isNight);
    switch (cat) {
      case WeatherCategory.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherCategory.night:
        return Icons.nightlight_round;
      case WeatherCategory.partlyCloudy:
        return isNight ? Icons.nights_stay_rounded : Icons.wb_cloudy_rounded;
      case WeatherCategory.cloudy:
        return Icons.cloud_rounded;
      case WeatherCategory.foggy:
        return Icons.foggy;
      case WeatherCategory.rainy:
        return Icons.water_drop_rounded;
      case WeatherCategory.thunder:
        return Icons.flash_on_rounded;
      case WeatherCategory.snowy:
        return Icons.ac_unit_rounded;
    }
  }

  /// Emoji representation
  static String getEmoji(String code, {bool isNight = false}) {
    final cat = getCategory(code, isNight: isNight);
    switch (cat) {
      case WeatherCategory.sunny:
        return '☀️';
      case WeatherCategory.night:
        return '🌙';
      case WeatherCategory.partlyCloudy:
        return isNight ? '☁️🌙' : '⛅';
      case WeatherCategory.cloudy:
        return '☁️';
      case WeatherCategory.foggy:
        return '🌫️';
      case WeatherCategory.rainy:
        return '🌧️';
      case WeatherCategory.thunder:
        return '⛈️';
      case WeatherCategory.snowy:
        return '❄️';
    }
  }

  /// Theme color set for dynamic background based on weather category
  static PixelWeatherThemeColors getThemeColors(
    WeatherCategory category, {
    bool isDarkMode = false,
  }) {
    if (isDarkMode) {
      return _getDarkThemeColors(category);
    }
    return _getLightThemeColors(category);
  }

  static PixelWeatherThemeColors _getLightThemeColors(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.sunny:
        return const PixelWeatherThemeColors(
          background: Color(0xFFFFF7D6), // Warm yellow/cream
          surface: Color(0xFFFFFDF5),
          cardBackground: Color(0xFFFFFFFF),
          primary: Color(0xFFFA520F), // Mistral orange
          secondary: Color(0xFFFFAF00), // Amber
          border: Color(0xFF000000),
          textPrimary: Color(0xFF1E1E1E),
          textSecondary: Color(0xFF555555),
          accent: Color(0xFFFF9800),
          badgeColor: Color(0xFFFFE082),
        );
      case WeatherCategory.night:
        return const PixelWeatherThemeColors(
          background: Color(0xFF1F2438), // Deep twilight indigo
          surface: Color(0xFF282F48),
          cardBackground: Color(0xFF2D3552),
          primary: Color(0xFF818CF8), // Indigo violet
          secondary: Color(0xFFC084FC), // Lavender
          border: Color(0xFF000000),
          textPrimary: Color(0xFFF8FAFC),
          textSecondary: Color(0xFFCBD5E1),
          accent: Color(0xFFA5B4FC),
          badgeColor: Color(0xFF374151),
        );
      case WeatherCategory.rainy:
      case WeatherCategory.thunder:
        return const PixelWeatherThemeColors(
          background: Color(0xFFE2EAF4), // Muted rain blue
          surface: Color(0xFFEFF5FA),
          cardBackground: Color(0xFFFFFFFF),
          primary: Color(0xFF0284C7), // Sky/Rain blue
          secondary: Color(0xFF0369A1), // Deep blue
          border: Color(0xFF000000),
          textPrimary: Color(0xFF0F172A),
          textSecondary: Color(0xFF475569),
          accent: Color(0xFF38BDF8),
          badgeColor: Color(0xFFBAE6FD),
        );
      case WeatherCategory.cloudy:
      case WeatherCategory.foggy:
      case WeatherCategory.partlyCloudy:
      case WeatherCategory.snowy:
        return const PixelWeatherThemeColors(
          background: Color(0xFFECEFF1), // Cool grey mist
          surface: Color(0xFFF5F7F8),
          cardBackground: Color(0xFFFFFFFF),
          primary: Color(0xFF475569), // Slate
          secondary: Color(0xFF64748B),
          border: Color(0xFF000000),
          textPrimary: Color(0xFF1E293B),
          textSecondary: Color(0xFF64748B),
          accent: Color(0xFF94A3B8),
          badgeColor: Color(0xFFE2E8F0),
        );
    }
  }

  static PixelWeatherThemeColors _getDarkThemeColors(WeatherCategory category) {
    switch (category) {
      case WeatherCategory.sunny:
        return const PixelWeatherThemeColors(
          background: Color(0xFF1C1917), // Warm dark stone
          surface: Color(0xFF292524),
          cardBackground: Color(0xFF262220),
          primary: Color(0xFFFB923C), // Amber glow
          secondary: Color(0xFFFBBF24),
          border: Color(0xFF44403C),
          textPrimary: Color(0xFFFAFAF9),
          textSecondary: Color(0xFFA8A29E),
          accent: Color(0xFFF97316),
          badgeColor: Color(0xFF44403C),
        );
      case WeatherCategory.rainy:
      case WeatherCategory.thunder:
        return const PixelWeatherThemeColors(
          background: Color(0xFF0F172A), // Deep navy
          surface: Color(0xFF1E293B),
          cardBackground: Color(0xFF172033),
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFF0284C7),
          border: Color(0xFF334155),
          textPrimary: Color(0xFFF8FAFC),
          textSecondary: Color(0xFF94A3B8),
          accent: Color(0xFF0EA5E9),
          badgeColor: Color(0xFF1E293B),
        );
      case WeatherCategory.night:
      case WeatherCategory.cloudy:
      case WeatherCategory.foggy:
      case WeatherCategory.partlyCloudy:
      case WeatherCategory.snowy:
        return const PixelWeatherThemeColors(
          background: Color(0xFF121214), // Pure slate black
          surface: Color(0xFF1E1E24),
          cardBackground: Color(0xFF18181E),
          primary: Color(0xFFA78BFA),
          secondary: Color(0xFF818CF8),
          border: Color(0xFF3F3F46),
          textPrimary: Color(0xFFFAFAFA),
          textSecondary: Color(0xFFA1A1AA),
          accent: Color(0xFFC4B5FD),
          badgeColor: Color(0xFF27272A),
        );
    }
  }
}

class PixelWeatherThemeColors {
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color primary;
  final Color secondary;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color badgeColor;

  const PixelWeatherThemeColors({
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.primary,
    required this.secondary,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.badgeColor,
  });
}
