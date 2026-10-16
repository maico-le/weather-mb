import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import 'pixel_weather_icon.dart';
import 'pixel_widgets.dart';

class HourlyForecastCard extends StatelessWidget {
  final HourForecast hour;
  final TemperatureUnit unit;
  final bool isSelected;
  final VoidCallback? onTap;

  const HourlyForecastCard({
    super.key,
    required this.hour,
    required this.unit,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tempVal = hour.getTemperature(unit).round();
    final tempStr = '$tempVal${unit.symbol}';

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: PixelCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: isSelected ? const Color(0xFFFFFAEB) : Colors.white,
        shadowOffset: isSelected ? 4.0 : 2.5,
        onTap: onTap,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Time
              Text(
                hour.formattedTime,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 6),
              // Pixel Icon
              PixelWeatherIcon(
                weatherCode: hour.weatherCode,
                isNight: hour.isNight,
                size: 34,
              ),
              const SizedBox(height: 6),
              // Temperature
              Text(
                tempStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 4),
              // Rain chance
              if (hour.chanceOfRain > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop, size: 10, color: Color(0xFF0284C7)),
                    Text(
                      '${hour.chanceOfRain}%',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  '0%',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
