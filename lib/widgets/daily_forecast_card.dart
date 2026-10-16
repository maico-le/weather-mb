import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import '../utils/weather_code_utils.dart';
import 'pixel_weather_icon.dart';
import 'pixel_widgets.dart';

class DailyForecastCard extends StatelessWidget {
  final DayForecast day;
  final TemperatureUnit unit;
  final bool isToday;

  const DailyForecastCard({
    super.key,
    required this.day,
    required this.unit,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final maxTemp = day.getMaxTemperature(unit).round();
    final minTemp = day.getMinTemperature(unit).round();

    final desc = day.weatherDesc.isNotEmpty
        ? day.weatherDesc
        : WeatherCodeUtils.getVietnameseDescription(day.weatherCode);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PixelCard(
        backgroundColor: isToday ? const Color(0xFFFFFAEB) : Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // Day name + Date
                SizedBox(
                  width: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.formattedDayName,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isToday ? const Color(0xFFFA520F) : const Color(0xFF1E1E1E),
                        ),
                      ),
                      Text(
                        day.formattedDateShort,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon
                PixelWeatherIcon(
                  weatherCode: day.weatherCode,
                  size: 36,
                ),
                const SizedBox(width: 10),

                // Description
                Expanded(
                  child: Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),

                // Min / Max
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward, size: 12, color: Color(0xFFEF4444)),
                        Text(
                          '$maxTemp${unit.symbol}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_downward, size: 12, color: Color(0xFF3B82F6)),
                        Text(
                          '$minTemp${unit.symbol}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 6),

            // Sun astronomy row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wb_sunny_outlined, size: 13, color: Color(0xFFFFA000)),
                    const SizedBox(width: 4),
                    Text(
                      'Mọc: ${day.sunrise}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.nights_stay_outlined, size: 13, color: Color(0xFF6366F1)),
                    const SizedBox(width: 4),
                    Text(
                      'Lặn: ${day.sunset}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
