import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import 'weather_provider.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

class DailyNotificationEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final cache = ref.watch(cacheServiceProvider);
    return cache.isDailyNotificationEnabled();
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final cache = ref.read(cacheServiceProvider);
    await cache.setDailyNotificationEnabled(enabled);

    final notificationService = ref.read(notificationServiceProvider);
    if (enabled) {
      final defaultLocation = ref.read(defaultLocationProvider);
      final weatherAsync = ref.read(weatherNotifierProvider);
      final unit = ref.read(temperatureUnitProvider);

      await notificationService.scheduleDailyMorningWeatherNotification(
        locationName: defaultLocation,
        weatherData: weatherAsync.value,
        unit: unit,
      );
    } else {
      await notificationService.cancelDailyNotification();
    }
  }

  Future<void> sendTestNotification() async {
    final notificationService = ref.read(notificationServiceProvider);
    final defaultLocation = ref.read(defaultLocationProvider);
    final weatherAsync = ref.read(weatherNotifierProvider);
    final unit = ref.read(temperatureUnitProvider);

    await notificationService.showTestNotification(
      locationName: defaultLocation,
      weatherData: weatherAsync.value,
      unit: unit,
    );
  }
}

final dailyNotificationEnabledProvider =
    NotifierProvider<DailyNotificationEnabledNotifier, bool>(DailyNotificationEnabledNotifier.new);
