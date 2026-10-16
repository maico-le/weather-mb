import 'dart:developer' as developer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/weather_models.dart';

class NotificationService {
  static const int dailyNotificationId = 1001;
  static const int testNotificationId = 1002;
  static const String channelId = 'weather_daily_morning';
  static const String channelName = 'Thời tiết mỗi sáng (06:00)';
  static const String channelDescription = 'Thông báo tóm tắt thời tiết mỗi sáng lúc 6:00';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static final NotificationService instance = NotificationService._internal();

  NotificationService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Initialize timezone database
      tz.initializeTimeZones();
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
      } catch (e) {
        developer.log('Fallback to default timezone: $e', name: 'NotificationService');
        // Default to Asia/Ho_Chi_Minh if detection fails
        try {
          tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
        } catch (_) {}
      }

      // 2. Setup notification plugin initialization
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          developer.log('Notification tapped: ${response.payload}', name: 'NotificationService');
        },
      );

      // 3. Request permissions on Android 13+
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        try {
          await androidPlugin.requestExactAlarmsPermission();
        } catch (_) {}
      }

      _isInitialized = true;
    } catch (e, stack) {
      developer.log('Failed to initialize NotificationService: $e', name: 'NotificationService', error: e, stackTrace: stack);
    }
  }

  tz.TZDateTime _nextInstanceOfSixAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 6, 0);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  NotificationDetails _createNotificationDetails({required String summaryText, required String bigText}) {
    final bigTextStyleInformation = BigTextStyleInformation(
      bigText,
      htmlFormatBigText: false,
      contentTitle: summaryText,
      htmlFormatContentTitle: false,
      summaryText: 'Thời tiết 6:00 sáng',
      htmlFormatSummaryText: false,
    );

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: bigTextStyleInformation,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Schedule recurring morning notification at 6:00 AM daily
  Future<void> scheduleDailyMorningWeatherNotification({
    required String locationName,
    WeatherData? weatherData,
    TemperatureUnit unit = TemperatureUnit.celsius,
  }) async {
    if (!_isInitialized) await init();

    final scheduledDate = _nextInstanceOfSixAM();
    final unitSymbol = unit == TemperatureUnit.celsius ? '°C' : '°F';

    String title = '⛅ Thời tiết hôm nay tại $locationName';
    String body;
    String bigText;

    if (weatherData != null) {
      final current = weatherData.current;
      final temp = unit == TemperatureUnit.celsius ? current.tempC.round() : current.tempF.round();
      final feelsLike = unit == TemperatureUnit.celsius ? current.feelsLikeC.round() : current.feelsLikeF.round();
      final desc = current.weatherDesc.isNotEmpty ? current.weatherDesc : 'Trời đẹp';

      final today = weatherData.days.isNotEmpty ? weatherData.days.first : null;
      final minTemp = today != null
          ? (unit == TemperatureUnit.celsius ? today.minTempC.round() : today.minTempF.round())
          : temp;
      final maxTemp = today != null
          ? (unit == TemperatureUnit.celsius ? today.maxTempC.round() : today.maxTempF.round())
          : temp;

      body = '$temp$unitSymbol • $desc (Thấp nhất: $minTemp$unitSymbol, Cao nhất: $maxTemp$unitSymbol)';
      bigText = '$desc, nhiệt độ hiện tại là $temp$unitSymbol (cảm giác như $feelsLike$unitSymbol).\n'
          '🌡 Thấp nhất: $minTemp$unitSymbol | Cao nhất: $maxTemp$unitSymbol\n'
          '💧 Độ ẩm: ${current.humidity}% | 💨 Gió: ${current.windSpeedKmph.round()} km/h';
    } else {
      body = 'Bật ứng dụng để xem dự báo chi tiết nhiệt độ và mưa hôm nay!';
      bigText = 'Chào buổi sáng! Hãy mở Weather MB để kiểm tra nhiệt độ, độ ẩm và dự báo mưa cho cả ngày tại $locationName.';
    }

    try {
      await _plugin.zonedSchedule(
        id: dailyNotificationId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: _createNotificationDetails(summaryText: title, bigText: bigText),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      developer.log('Scheduled daily 6:00 AM notification for: $scheduledDate ($locationName)', name: 'NotificationService');
    } catch (e) {
      developer.log('Error scheduling daily notification: $e', name: 'NotificationService');
    }
  }

  /// Send an immediate notification for test purpose
  Future<void> showTestNotification({
    required String locationName,
    WeatherData? weatherData,
    TemperatureUnit unit = TemperatureUnit.celsius,
  }) async {
    if (!_isInitialized) await init();

    final unitSymbol = unit == TemperatureUnit.celsius ? '°C' : '°F';
    String title = '⛅ [Thử nghiệm] Thời tiết 06:00 tại $locationName';
    String body;
    String bigText;

    if (weatherData != null) {
      final current = weatherData.current;
      final temp = unit == TemperatureUnit.celsius ? current.tempC.round() : current.tempF.round();
      final feelsLike = unit == TemperatureUnit.celsius ? current.feelsLikeC.round() : current.feelsLikeF.round();
      final desc = current.weatherDesc.isNotEmpty ? current.weatherDesc : 'Trời quang mây tạnh';

      final today = weatherData.days.isNotEmpty ? weatherData.days.first : null;
      final minTemp = today != null
          ? (unit == TemperatureUnit.celsius ? today.minTempC.round() : today.minTempF.round())
          : temp;
      final maxTemp = today != null
          ? (unit == TemperatureUnit.celsius ? today.maxTempC.round() : today.maxTempF.round())
          : temp;

      body = '$temp$unitSymbol • $desc (Thấp nhất: $minTemp$unitSymbol, Cao nhất: $maxTemp$unitSymbol)';
      bigText = '$desc, nhiệt độ hiện tại là $temp$unitSymbol (cảm giác như $feelsLike$unitSymbol).\n'
          '🌡 Thấp nhất: $minTemp$unitSymbol | Cao nhất: $maxTemp$unitSymbol\n'
          '💧 Độ ẩm: ${current.humidity}% | 💨 Gió: ${current.windSpeedKmph.round()} km/h\n'
          '⏰ Thông báo mẫu mô phỏng lúc 6:00 sáng hàng ngày.';
    } else {
      body = 'Thời tiết hôm nay tại $locationName đã sẵn sàng!';
      bigText = 'Chào buổi sáng! Hãy kiểm tra dự báo thời tiết chi tiết hôm nay trên Weather MB.';
    }

    await _plugin.show(
      id: testNotificationId,
      title: title,
      body: body,
      notificationDetails: _createNotificationDetails(summaryText: title, bigText: bigText),
    );
  }

  /// Cancel scheduled notification
  Future<void> cancelDailyNotification() async {
    if (!_isInitialized) await init();
    await _plugin.cancel(id: dailyNotificationId);
    developer.log('Cancelled daily 6:00 AM notification', name: 'NotificationService');
  }
}
