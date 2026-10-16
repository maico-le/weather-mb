import 'package:flutter/material.dart';
import '../utils/weather_code_utils.dart';

/// Crisp 8-bit Pixel Weather Icon drawn on a discrete pixel grid
class PixelWeatherIcon extends StatelessWidget {
  final String weatherCode;
  final bool isNight;
  final double size;

  const PixelWeatherIcon({
    super.key,
    required this.weatherCode,
    this.isNight = false,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final category = WeatherCodeUtils.getCategory(weatherCode, isNight: isNight);

    return CustomPaint(
      size: Size(size, size),
      painter: _PixelWeatherPainter(category: category),
    );
  }
}

class _PixelWeatherPainter extends CustomPainter {
  final WeatherCategory category;

  _PixelWeatherPainter({required this.category});

  @override
  void paint(Canvas canvas, Size size) {
    const gridDim = 16;
    final pixelSize = size.width / gridDim;

    void drawPx(int x, int y, Color color) {
      if (x < 0 || x >= gridDim || y < 0 || y >= gridDim) return;
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }

    void drawRectBlock(int x1, int y1, int x2, int y2, Color color) {
      for (int x = x1; x <= x2; x++) {
        for (int y = y1; y <= y2; y++) {
          drawPx(x, y, color);
        }
      }
    }

    // Helper: draw cloud base
    void drawCloud({Color main = const Color(0xFFE2E8F0), Color outline = const Color(0xFF1E293B), int offsetY = 0}) {
      // Top hump
      drawRectBlock(6, 4 + offsetY, 10, 5 + offsetY, main);
      // Left hump
      drawRectBlock(3, 6 + offsetY, 5, 8 + offsetY, main);
      // Right hump
      drawRectBlock(11, 7 + offsetY, 13, 8 + offsetY, main);
      // Cloud body
      drawRectBlock(3, 7 + offsetY, 13, 10 + offsetY, main);

      // Cloud outline
      final outlinePoints = [
        // Top
        [6, 3 + offsetY], [7, 3 + offsetY], [8, 3 + offsetY], [9, 3 + offsetY], [10, 3 + offsetY],
        // Top left slope
        [5, 4 + offsetY], [4, 5 + offsetY], [3, 5 + offsetY], [2, 6 + offsetY], [2, 7 + offsetY], [2, 8 + offsetY], [2, 9 + offsetY],
        // Bottom flat
        [2, 11 + offsetY], [3, 11 + offsetY], [4, 11 + offsetY], [5, 11 + offsetY], [6, 11 + offsetY],
        [7, 11 + offsetY], [8, 11 + offsetY], [9, 11 + offsetY], [10, 11 + offsetY], [11, 11 + offsetY],
        [12, 11 + offsetY], [13, 11 + offsetY], [14, 11 + offsetY],
        // Right slope
        [14, 9 + offsetY], [14, 10 + offsetY], [14, 8 + offsetY], [13, 6 + offsetY], [12, 5 + offsetY], [11, 4 + offsetY],
      ];
      for (final pt in outlinePoints) {
        drawPx(pt[0], pt[1], outline);
      }
    }

    switch (category) {
      case WeatherCategory.sunny:
        const sunGold = Color(0xFFFFD800);
        const sunOrange = Color(0xFFFA520F);
        const sunDark = Color(0xFF1E1E1E);

        // Sun disk
        drawRectBlock(5, 5, 10, 10, sunGold);
        // Inner highlight
        drawRectBlock(6, 6, 8, 8, const Color(0xFFFFF9C4));

        // Border around core
        for (int i = 5; i <= 10; i++) {
          drawPx(i, 4, sunDark);
          drawPx(i, 11, sunDark);
          drawPx(4, i, sunDark);
          drawPx(11, i, sunDark);
        }

        // 4 Straight rays
        drawRectBlock(7, 1, 8, 2, sunOrange);
        drawRectBlock(7, 13, 8, 14, sunOrange);
        drawRectBlock(1, 7, 2, 8, sunOrange);
        drawRectBlock(13, 7, 14, 8, sunOrange);

        // 4 Diagonal rays
        drawPx(2, 2, sunOrange);
        drawPx(3, 3, sunOrange);
        drawPx(13, 2, sunOrange);
        drawPx(12, 3, sunOrange);
        drawPx(2, 13, sunOrange);
        drawPx(3, 12, sunOrange);
        drawPx(13, 13, sunOrange);
        drawPx(12, 12, sunOrange);
        break;

      case WeatherCategory.night:
        const moonColor = Color(0xFFFDE047);
        const moonShadow = Color(0xFFCA8A04);
        const moonOutline = Color(0xFF1E1E1E);

        // Crescent moon body
        drawRectBlock(5, 3, 9, 12, moonColor);
        drawRectBlock(3, 5, 5, 10, moonColor);
        // Cut out right inner curve
        drawRectBlock(7, 4, 11, 11, Colors.transparent);
        drawRectBlock(5, 4, 9, 11, moonColor);
        // Refined crescent
        drawPx(4, 3, moonColor);
        drawPx(3, 4, moonColor);
        drawPx(4, 12, moonColor);
        drawPx(3, 11, moonColor);

        // Moon outline
        drawPx(4, 2, moonOutline);
        drawPx(5, 2, moonOutline);
        drawPx(3, 3, moonOutline);
        drawPx(2, 4, moonOutline);
        drawPx(2, 5, moonOutline);
        drawPx(1, 6, moonOutline);
        drawPx(1, 7, moonOutline);
        drawPx(1, 8, moonOutline);
        drawPx(1, 9, moonOutline);
        drawPx(2, 10, moonOutline);
        drawPx(2, 11, moonOutline);
        drawPx(3, 12, moonOutline);
        drawPx(4, 13, moonOutline);
        drawPx(5, 13, moonOutline);

        // Inner contour
        drawPx(5, 4, moonShadow);
        drawPx(6, 5, moonShadow);
        drawPx(6, 6, moonShadow);
        drawPx(6, 7, moonShadow);
        drawPx(6, 8, moonShadow);
        drawPx(6, 9, moonShadow);
        drawPx(5, 10, moonShadow);

        // Star 1
        const starColor = Color(0xFFE2E8F0);
        drawPx(12, 4, starColor);
        drawPx(11, 5, starColor);
        drawPx(12, 5, Colors.white);
        drawPx(13, 5, starColor);
        drawPx(12, 6, starColor);

        // Star 2 (small)
        drawPx(13, 11, Colors.white);
        drawPx(14, 11, starColor);
        break;

      case WeatherCategory.partlyCloudy:
        // Sun peeking behind
        const sunGold = Color(0xFFFFD800);
        drawRectBlock(3, 2, 7, 6, sunGold);
        drawPx(4, 1, const Color(0xFFFA520F));
        drawPx(5, 1, const Color(0xFFFA520F));
        drawPx(1, 4, const Color(0xFFFA520F));
        drawPx(1, 5, const Color(0xFFFA520F));
        drawPx(2, 2, const Color(0xFFFA520F));

        // Cloud on foreground
        drawCloud(main: const Color(0xFFF8FAFC), outline: const Color(0xFF1E293B), offsetY: 2);
        break;

      case WeatherCategory.cloudy:
        drawCloud(main: const Color(0xFFCBD5E1), outline: const Color(0xFF1E293B), offsetY: 1);
        break;

      case WeatherCategory.foggy:
        const fogColor = Color(0xFF94A3B8);
        const fogDark = Color(0xFF334155);

        for (int y = 4; y <= 12; y += 3) {
          drawRectBlock(2, y, 13, y + 1, fogColor);
          drawPx(1, y, fogDark);
          drawPx(1, y + 1, fogDark);
          drawPx(14, y, fogDark);
          drawPx(14, y + 1, fogDark);
        }
        break;

      case WeatherCategory.rainy:
        drawCloud(main: const Color(0xFF94A3B8), outline: const Color(0xFF0F172A), offsetY: 0);

        // Rain drops (angled pixel dashes)
        const rainBlue = Color(0xFF0284C7);
        final drops = [
          [3, 12], [4, 13],
          [6, 13], [7, 14],
          [9, 12], [10, 13],
          [12, 13], [13, 14],
        ];
        for (final d in drops) {
          drawPx(d[0], d[1], rainBlue);
        }
        break;

      case WeatherCategory.thunder:
        drawCloud(main: const Color(0xFF64748B), outline: const Color(0xFF0F172A), offsetY: 0);

        // Lightning bolt
        const yellow = Color(0xFFFFD800);
        const orange = Color(0xFFFA520F);
        final bolt = [
          [8, 9], [7, 10], [8, 10],
          [6, 11], [7, 11], [8, 11],
          [7, 12], [8, 12],
          [5, 13], [6, 13],
          [5, 14],
        ];
        for (final b in bolt) {
          drawPx(b[0], b[1], yellow);
        }
        drawPx(6, 12, orange);
        break;

      case WeatherCategory.snowy:
        drawCloud(main: const Color(0xFFCBD5E1), outline: const Color(0xFF1E293B), offsetY: 0);

        // Snow flakes
        const snowColor = Color(0xFF38BDF8);
        final flakes = [
          [4, 12], [4, 14], [3, 13], [5, 13],
          [10, 13], [10, 15], [9, 14], [11, 14],
        ];
        for (final f in flakes) {
          drawPx(f[0], f[1], snowColor);
        }
        drawPx(4, 13, Colors.white);
        drawPx(10, 14, Colors.white);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PixelWeatherPainter oldDelegate) {
    return oldDelegate.category != category;
  }
}
