import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../widgets/pixel_widgets.dart';

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMsg;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addLocation() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _errorMsg = 'Vui lòng nhập tên thành phố.');
      return;
    }

    final success = await ref.read(favoriteLocationsProvider.notifier).addLocation(text);
    if (!mounted) return;

    if (!success) {
      setState(() => _errorMsg = 'Địa điểm đã có trong danh sách hoặc vượt quá 5.');
    } else {
      _controller.clear();
      setState(() => _errorMsg = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "$text" vào danh sách yêu thích.'),
          backgroundColor: const Color(0xFF1E1E1E),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _setDefaultLocation(String loc) async {
    await ref.read(defaultLocationProvider.notifier).setDefaultLocation(loc);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã đặt "$loc" làm địa điểm mặc định.'),
        backgroundColor: const Color(0xFF1E1E1E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoriteLocationsProvider);
    final defaultLocation = ref.watch(defaultLocationProvider);
    final selectedLocation = ref.watch(selectedLocationProvider);

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
          'ĐỊA ĐIỂM YÊU THÍCH',
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
            // Add Location Input Box
            PixelCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'THÊM ĐỊA ĐIỂM MỚI (TỐI ĐA 5)',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextField(
                            controller: _controller,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                            decoration: const InputDecoration(
                              hintText: 'VD: Hanoi, Da Nang, Tokyo...',
                              hintStyle: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 11),
                            ),
                            onSubmitted: (_) => _addLocation(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PixelButton(
                        onPressed: _addLocation,
                        backgroundColor: const Color(0xFFFA520F),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        child: const Text('THÊM'),
                      ),
                    ],
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorMsg!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Favorites List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DANH SÁCH ĐÃ LƯU',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  '${favorites.length}/5',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Favorites List items
            if (favorites.isEmpty)
              const PixelCard(
                backgroundColor: Colors.white,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'Chưa có địa điểm nào trong danh sách.',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              )
            else
              ...favorites.map((loc) {
                final isDefault = loc.toLowerCase() == defaultLocation.toLowerCase();
                final isCurrent = loc.toLowerCase() == selectedLocation.toLowerCase();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PixelCard(
                    backgroundColor: isCurrent ? const Color(0xFFFFFAEB) : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    onTap: () {
                      ref.read(selectedLocationProvider.notifier).selectLocation(loc);
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: isCurrent ? const Color(0xFFFA520F) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: isCurrent ? const Color(0xFFFA520F) : const Color(0xFF1E1E1E),
                                ),
                              ),
                              if (isDefault)
                                const Text(
                                  '⭐ Mặc định khi mở app',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 10,
                                    color: Color(0xFFD97706),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Action: Set Default
                        IconButton(
                          icon: Icon(
                            isDefault ? Icons.star : Icons.star_border,
                            color: isDefault ? const Color(0xFFFFA000) : const Color(0xFF94A3B8),
                            size: 20,
                          ),
                          tooltip: 'Đặt làm mặc định',
                          onPressed: () => _setDefaultLocation(loc),
                        ),

                        // Action: Delete (if > 1 location)
                        if (favorites.length > 1)
                          IconButton(
                            icon: const Icon(Icons.close, color: Color(0xFFEF4444), size: 18),
                            tooltip: 'Xóa địa điểm',
                            onPressed: () async {
                              await ref.read(favoriteLocationsProvider.notifier).removeLocation(loc);
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
            // Quick suggestions
            const Text(
              'GỢI Ý PHỔ BIẾN',
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Ho Chi Minh City',
                'Hanoi',
                'Da Nang',
                'Hue',
                'Nha Trang',
                'Can Tho',
                'Da Lat',
              ].map((sug) {
                return PixelButton(
                  isSmall: true,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF1E1E1E),
                  onPressed: () {
                    ref.read(selectedLocationProvider.notifier).selectLocation(sug);
                    Navigator.of(context).pop();
                  },
                  child: Text(sug),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
