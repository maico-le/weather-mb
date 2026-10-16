import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/weather_models.dart';
import '../providers/update_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/pixel_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUnit = ref.watch(temperatureUnitProvider);
    final defaultLocation = ref.watch(defaultLocationProvider);
    final cacheService = ref.watch(cacheServiceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const Border(
          bottom: BorderSide(color: Colors.black, width: 2),
        ),
        title: const Text(
          'CÀI ĐẶT',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: Color(0xFF1E1E1E),
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Temperature Unit Setting
            const Text(
              'ĐƠN VỊ NHIỆT ĐỘ',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            PixelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      backgroundColor: currentUnit == TemperatureUnit.celsius
                          ? const Color(0xFFFA520F)
                          : const Color(0xFFE2E8F0),
                      textColor: currentUnit == TemperatureUnit.celsius
                          ? Colors.white
                          : const Color(0xFF1E1E1E),
                      onPressed: () {
                        ref.read(temperatureUnitProvider.notifier).setUnit(TemperatureUnit.celsius);
                      },
                      child: const Center(child: Text('ĐỘ C (°C)')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PixelButton(
                      backgroundColor: currentUnit == TemperatureUnit.fahrenheit
                          ? const Color(0xFFFA520F)
                          : const Color(0xFFE2E8F0),
                      textColor: currentUnit == TemperatureUnit.fahrenheit
                          ? Colors.white
                          : const Color(0xFF1E1E1E),
                      onPressed: () {
                        ref.read(temperatureUnitProvider.notifier).setUnit(TemperatureUnit.fahrenheit);
                      },
                      child: const Center(child: Text('ĐỘ F (°F)')),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Default Location Setting
            const Text(
              'ĐỊA ĐIỂM KHỞI ĐỘNG',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            PixelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, size: 20, color: Color(0xFFFA520F)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mặc định mở khi khởi động:',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          defaultLocation,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Offline Cache Setting
            const Text(
              'BỘ NHỚ ĐỆM NGOẠI TUYẾN',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            PixelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Dữ liệu được lưu trữ cục bộ để xem lại khi mất mạng (giữ trong 30 phút trước khi tự động làm mới).',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  PixelButton(
                    backgroundColor: const Color(0xFFEF4444),
                    onPressed: () async {
                      await cacheService.clearAllWeatherCache();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã dọn dẹp sạch toàn bộ cache thời tiết.'),
                            backgroundColor: Color(0xFF1E1E1E),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline, size: 14, color: Colors.white),
                        SizedBox(width: 6),
                        Text('XÓA TOÀN BỘ CACHE'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // GitHub Auto Update Section
            const Text(
              'TỰ ĐỘNG CẬP NHẬT (GITHUB OTA)',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            _GithubUpdateCard(),
            const SizedBox(height: 20),

            // About App
            const Text(
              'THÔNG TIN ỨNG DỤNG',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 8),
            PixelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'WEATHER-MB (RETRO PIXEL)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: Color(0xFFFA520F),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Phiên bản: 1.0.0 (MVP)\n'
                    'Nguồn thời tiết: wttr.in API (format=j1&lang=vi)\n'
                    'Cập nhật: Tự động qua GitHub Releases (OTA)\n'
                    'Thiết kế: Phong cách Pixel 8-bit, viền phẳng, đổ bóng đặc không bo góc.',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF475569),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GithubUpdateCard extends ConsumerStatefulWidget {
  const _GithubUpdateCard();

  @override
  ConsumerState<_GithubUpdateCard> createState() => _GithubUpdateCardState();
}

class _GithubUpdateCardState extends ConsumerState<_GithubUpdateCard> {
  late final TextEditingController _repoController;

  @override
  void initState() {
    super.initState();
    final currentRepo = ref.read(githubRepoProvider);
    _repoController = TextEditingController(text: currentRepo);
  }

  @override
  void dispose() {
    _repoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateAsync = ref.watch(appUpdateProvider);

    return PixelCard(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Kho lưu trữ GitHub (username/repo):',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _repoController,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'VD: your-name/weather-mb',
                      hintStyle: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 9),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PixelButton(
                isSmall: true,
                backgroundColor: const Color(0xFF475569),
                onPressed: () {
                  final text = _repoController.text.trim();
                  ref.read(githubRepoProvider.notifier).setRepo(text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã lưu cấu hình repo: ${text.isEmpty ? "Mặc định" : text}'),
                      backgroundColor: const Color(0xFF1E1E1E),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('LƯU'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Check update status
          updateAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text(
                      'ĐANG KIỂM TRA BẢN MỚI...',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ),
            error: (err, _) => Text(
              'Lỗi kiểm tra cập nhật: ${err.toString().replaceAll("Exception: ", "")}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Color(0xFFEF4444)),
            ),
            data: (info) {
              if (info.hasUpdate) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 ĐÃ CÓ BẢN MỚI v${info.latestVersion} (Hiện tại: v${info.currentVersion})',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    PixelButton(
                      backgroundColor: const Color(0xFF16A34A),
                      onPressed: () {
                        ref.read(appUpdateProvider.notifier).launchDownload(info.downloadUrl);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, size: 14, color: Colors.white),
                          SizedBox(width: 6),
                          Text('TẢI CẬP NHẬT APK'),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phiên bản hiện tại: v${info.currentVersion}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Color(0xFF475569),
                    ),
                  ),
                  PixelButton(
                    isSmall: true,
                    backgroundColor: const Color(0xFFFA520F),
                    onPressed: () {
                      ref.read(appUpdateProvider.notifier).refresh();
                    },
                    child: const Text('KIỂM TRA'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

