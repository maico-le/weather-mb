import 'package:flutter/material.dart';
import 'pixel_widgets.dart';

class PixelErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onChangeLocation;

  const PixelErrorView({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.onChangeLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: PixelCard(
          backgroundColor: Colors.white,
          shadowOffset: 4.0,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),

              // Title
              const Text(
                'LỖI THỜI TIẾT',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFFEF4444),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PixelButton(
                    onPressed: onRetry,
                    backgroundColor: const Color(0xFFFA520F),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text('THỬ LẠI'),
                      ],
                    ),
                  ),
                  if (onChangeLocation != null) ...[
                    const SizedBox(width: 10),
                    PixelButton(
                      onPressed: onChangeLocation,
                      backgroundColor: const Color(0xFF475569),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text('ĐỊA ĐIỂM'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
