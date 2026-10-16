import 'package:flutter/material.dart';
import 'pixel_widgets.dart';

class PixelLoadingView extends StatefulWidget {
  final String message;

  const PixelLoadingView({
    super.key,
    this.message = 'ĐANG TẢI DỮ LIỆU THỜI TIẾT...',
  });

  @override
  State<PixelLoadingView> createState() => _PixelLoadingViewState();
}

class _PixelLoadingViewState extends State<PixelLoadingView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
        final step = (_controller.value * 3).floor() + 1;
        if (step != _dotCount) {
          setState(() {
            _dotCount = step;
          });
        }
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Loading banner
          PixelCard(
            backgroundColor: const Color(0xFFFFFAEB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFFA520F),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.message}${"." * _dotCount}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFFFA520F),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skeleton Header card
          PixelCard(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 140,
                  height: 18,
                  color: const Color(0xFFE2E8F0),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 180,
                  height: 48,
                  color: const Color(0xFFCBD5E1),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 110,
                  height: 14,
                  color: const Color(0xFFE2E8F0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Skeleton Hourly cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: PixelCard(
                    backgroundColor: Colors.white,
                    child: SizedBox(
                      width: 68,
                      height: 90,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(width: 40, height: 10, color: const Color(0xFFE2E8F0)),
                          Container(width: 28, height: 28, color: const Color(0xFFCBD5E1)),
                          Container(width: 46, height: 12, color: const Color(0xFFE2E8F0)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Skeleton 3-day cards
          Column(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: PixelCard(
                  backgroundColor: Colors.white,
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 80, height: 14, color: const Color(0xFFE2E8F0)),
                        Container(width: 32, height: 32, color: const Color(0xFFCBD5E1)),
                        Container(width: 60, height: 14, color: const Color(0xFFE2E8F0)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
