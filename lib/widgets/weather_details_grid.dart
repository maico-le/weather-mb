import 'package:flutter/material.dart';
import '../models/weather_models.dart';
import 'pixel_widgets.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final CurrentCondition current;
  final TemperatureUnit unit;

  const WeatherDetailsGrid({
    super.key,
    required this.current,
    required this.unit,
  });

  String _getUvDescription(int uv) {
    if (uv <= 2) return 'Thấp';
    if (uv <= 5) return 'Trung bình';
    if (uv <= 7) return 'Cao';
    if (uv <= 10) return 'Rất cao';
    return 'Cực độ';
  }

  Color _getUvColor(int uv) {
    if (uv <= 2) return const Color(0xFF22C55E);
    if (uv <= 5) return const Color(0xFFEAB308);
    if (uv <= 7) return const Color(0xFFF97316);
    if (uv <= 10) return const Color(0xFFEF4444);
    return const Color(0xFFA855F7);
  }

  @override
  Widget build(BuildContext context) {
    final feelsLikeVal = current.getFeelsLike(unit).round();

    final items = [
      _DetailItem(
        icon: Icons.thermostat_outlined,
        label: 'CẢM GIÁC NHƯ',
        value: '$feelsLikeVal${unit.symbol}',
        subValue: 'Thực tế: ${current.getTemperature(unit).round()}${unit.symbol}',
        accentColor: const Color(0xFFFA520F),
      ),
      _DetailItem(
        icon: Icons.water_drop_outlined,
        label: 'ĐỘ ẨM',
        value: '${current.humidity}%',
        subValue: current.humidity > 80 ? 'Ẩm ướt cao' : 'Bình thường',
        accentColor: const Color(0xFF0284C7),
      ),
      _DetailItem(
        icon: Icons.air_outlined,
        label: 'TỐC ĐỘ GIÓ',
        value: '${current.windSpeedKmph.round()} km/h',
        subValue: 'Hướng: ${current.windDir16Point}',
        accentColor: const Color(0xFF0D9488),
      ),
      _DetailItem(
        icon: Icons.wb_sunny_outlined,
        label: 'CHỈ SỐ UV',
        value: '${current.uvIndex}',
        subValue: _getUvDescription(current.uvIndex),
        accentColor: _getUvColor(current.uvIndex),
      ),
      _DetailItem(
        icon: Icons.visibility_outlined,
        label: 'TẦM NHÌN',
        value: '${current.visibilityKm.toStringAsFixed(1)} km',
        subValue: current.visibilityKm >= 10 ? 'Rõ ràng' : 'Bị hạn chế',
        accentColor: const Color(0xFF6366F1),
      ),
      _DetailItem(
        icon: Icons.speed_outlined,
        label: 'ÁP SUẤT KHÍ QUYỂN',
        value: '${current.pressureHpa.round()} hPa',
        subValue: 'Chuẩn khí tượng',
        accentColor: const Color(0xFF8B5CF6),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return PixelCard(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Icon(item.icon, size: 14, color: item.accentColor),
                ],
              ),
              Text(
                item.value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: item.accentColor,
                ),
              ),
              Text(
                item.subValue,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailItem {
  final IconData icon;
  final String label;
  final String value;
  final String subValue;
  final Color accentColor;

  _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subValue,
    required this.accentColor,
  });
}
