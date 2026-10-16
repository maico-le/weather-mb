import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/weather_models.dart';
import '../providers/update_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_code_utils.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/pixel_error_view.dart';
import '../widgets/pixel_loading_view.dart';
import '../widgets/pixel_weather_icon.dart';
import '../widgets/pixel_widgets.dart';
import '../widgets/weather_details_grid.dart';
import 'locations_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final unit = ref.watch(temperatureUnitProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

    return weatherState.when(
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: _buildAppBar(
          context,
          ref,
          title: selectedLocation,
          isOffline: false,
          updatedTime: null,
          themeColors: WeatherCodeUtils.getThemeColors(WeatherCategory.sunny),
        ),
        body: const PixelLoadingView(),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: _buildAppBar(
          context,
          ref,
          title: selectedLocation,
          isOffline: false,
          updatedTime: null,
          themeColors: WeatherCodeUtils.getThemeColors(WeatherCategory.cloudy),
        ),
        body: PixelErrorView(
          errorMessage: error.toString().replaceAll('Exception: ', ''),
          onRetry: () {
            ref.read(weatherNotifierProvider.notifier).loadWeather(forceRefresh: true);
          },
          onChangeLocation: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LocationsScreen()),
            );
          },
        ),
      ),
      data: (data) {
        final now = DateTime.now();
        final isNight = now.hour >= 18 || now.hour < 6;
        final category = WeatherCodeUtils.getCategory(data.current.weatherCode, isNight: isNight);
        final themeColors = WeatherCodeUtils.getThemeColors(
          category,
          isDarkMode: Theme.of(context).brightness == Brightness.dark,
        );

        final currentTemp = data.current.getTemperature(unit).round();
        final feelsLike = data.current.getFeelsLike(unit).round();
        final updateTimeStr = DateFormat('HH:mm').format(data.updatedAt);

        final updateAsync = ref.watch(appUpdateProvider);
        final updateInfo = updateAsync.value;

        final todayHourly = data.days.isNotEmpty ? data.days.first.hourly : <HourForecast>[];

        final desc = data.current.weatherDesc.isNotEmpty
            ? data.current.weatherDesc
            : WeatherCodeUtils.getVietnameseDescription(data.current.weatherCode);

        return Scaffold(
          backgroundColor: themeColors.background,
          appBar: _buildAppBar(
            context,
            ref,
            title: data.displayName,
            isOffline: data.isFromCache,
            updatedTime: updateTimeStr,
            themeColors: themeColors,
          ),
          body: RefreshIndicator(
            color: const Color(0xFFFA520F),
            backgroundColor: Colors.white,
            onRefresh: () async {
              await ref.read(weatherNotifierProvider.notifier).loadWeather(forceRefresh: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Update Available Banner
                  if (updateInfo != null && updateInfo.hasUpdate) ...[
                    PixelCard(
                      backgroundColor: const Color(0xFFEFF6FF),
                      borderColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.system_update_alt, size: 20, color: Color(0xFF2563EB)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CÓ BẢN MỚI v${updateInfo.latestVersion}!',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                                if (updateInfo.releaseNotes.isNotEmpty)
                                  Text(
                                    updateInfo.releaseNotes,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      color: Color(0xFF3B82F6),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PixelButton(
                            isSmall: true,
                            backgroundColor: const Color(0xFF2563EB),
                            onPressed: () {
                              ref.read(appUpdateProvider.notifier).launchDownload(updateInfo.downloadUrl);
                            },
                            child: const Text('TẢI VỀ'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Offline Cache Alert Banner
                  if (data.isFromCache) ...[
                    PixelCard(
                      backgroundColor: const Color(0xFFFFFBEB),
                      borderColor: const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Đang xem dữ liệu ngoại tuyến (Cập nhật lúc $updateTimeStr)',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Main Current Weather Card
                  PixelCard(
                    backgroundColor: themeColors.cardBackground,
                    shadowOffset: 4.0,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Location & Update
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Color(0xFFFA520F)),
                                const SizedBox(width: 4),
                                Text(
                                  data.displayName.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 0.8,
                                    color: Color(0xFF1E1E1E),
                                  ),
                                ),
                              ],
                            ),
                            PixelBadge(
                              text: 'LÚC $updateTimeStr',
                              backgroundColor: themeColors.badgeColor,
                              textColor: const Color(0xFF1E1E1E),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Big Temperature & Pixel Weather Graphic
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Big Temp (click to toggle C/F)
                            GestureDetector(
                              onTap: () {
                                ref.read(temperatureUnitProvider.notifier).toggle();
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$currentTemp',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 68,
                                      height: 1.0,
                                      color: themeColors.primary,
                                    ),
                                  ),
                                  Text(
                                    unit.symbol,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 24,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Pixel Weather Art
                            PixelWeatherIcon(
                              weatherCode: data.current.weatherCode,
                              isNight: isNight,
                              size: 72,
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Weather Description
                        Text(
                          desc.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: Color(0xFF1E1E1E),
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Feels like
                        Text(
                          'Cảm giác như $feelsLike${unit.symbol} • Gió ${data.current.windSpeedKmph.round()} km/h ${data.current.windDir16Point}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 1: Hourly Forecast
                  if (todayHourly.isNotEmpty) ...[
                    _buildSectionHeader('DỰ BÁO THEO GIỜ (HÔM NAY)', Icons.access_time),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 126,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: todayHourly.length,
                        itemBuilder: (context, index) {
                          final h = todayHourly[index];
                          return HourlyForecastCard(
                            hour: h,
                            unit: unit,
                            isSelected: index == 0,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Section 2: 3-Day Forecast
                  if (data.days.isNotEmpty) ...[
                    _buildSectionHeader('DỰ BÁO 3 NGÀY TỚI', Icons.calendar_today_outlined),
                    const SizedBox(height: 10),
                    Column(
                      children: data.days.asMap().entries.map((entry) {
                        return DailyForecastCard(
                          day: entry.value,
                          unit: unit,
                          isToday: entry.key == 0,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Section 3: Weather Details Grid
                  _buildSectionHeader('CHỈ SỐ KHÍ TƯỢNG', Icons.bar_chart_outlined),
                  const SizedBox(height: 10),
                  WeatherDetailsGrid(current: data.current, unit: unit),

                  const SizedBox(height: 24),

                  // Footer info
                  Center(
                    child: Text(
                      'Dữ liệu wttr.in • Chạm nhiệt độ để đổi °C/°F',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: themeColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required bool isOffline,
    required String? updatedTime,
    required PixelWeatherThemeColors themeColors,
  }) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      shape: const Border(
        bottom: BorderSide(color: Colors.black, width: 2),
      ),
      title: Row(
        children: [
          const Icon(Icons.wb_sunny_sharp, size: 20, color: Color(0xFFFA520F)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Color(0xFF1E1E1E),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF1E1E1E), size: 22),
          tooltip: 'Làm mới',
          onPressed: () {
            ref.read(weatherNotifierProvider.notifier).loadWeather(forceRefresh: true);
          },
        ),

        // Locations Button
        IconButton(
          icon: const Icon(Icons.location_on_outlined, color: Color(0xFF1E1E1E), size: 22),
          tooltip: 'Đổi địa điểm',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LocationsScreen()),
            );
          },
        ),

        // Settings Button
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF1E1E1E), size: 22),
          tooltip: 'Cài đặt',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF1E1E1E)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: Color(0xFF1E1E1E),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
