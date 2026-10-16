# 🌦️ Weather-MB (Retro Pixel Weather)

Ứng dụng dự báo thời tiết cá nhân nhỏ gọn, viết bằng **Flutter (Material 3 + Riverpod)** với phong cách đồ họa **Retro Pixel Art** hoài cổ (viền đen phẳng 2px, đổ bóng đặc 3px không bo góc, font monospace, icon thời tiết 8-bit và màu nền biến đổi linh hoạt theo trạng thái thời tiết).

---

## 🚀 Tính năng nổi bật (MVP)

1. **Màn hình chính toàn diện**:
   - Tên địa điểm, nhiệt độ hiện tại siêu to nổi bật (chạm để chuyển nhanh giữa °C và °F).
   - Mô tả thời tiết tiếng Việt chuẩn hóa, icon thời tiết vẽ bằng pixel canvas 8-bit.
   - Các chỉ số khí tượng chi tiết: Cảm giác như, Độ ẩm (%), Tốc độ & hướng gió, Chỉ số UV (đánh giá mức độ nguy hại), Tầm nhìn (km), Áp suất (hPa).
2. **Dự báo theo giờ (Hourly)**:
   - Danh sách cuộn ngang 8 khung giờ (khoảng cách 3 tiếng: 00:00, 03:00, 06:00, 09:00, 12:00, 15:00, 18:00, 21:00) kèm icon thời tiết, nhiệt độ và xác suất mưa (%).
3. **Dự báo 3 ngày (Daily)**:
   - Thẻ dự báo Hôm nay, Ngày mai, Ngày kia với nhiệt độ Min/Max, icon và giờ mặt trời mọc / lặn.
4. **Quản lý địa điểm yêu thích**:
   - Tìm và thêm thành phố mới vào danh sách yêu thích (tối đa 5 địa điểm).
   - Đặt 1 địa điểm yêu thích làm mặc định khi mở app.
   - Chuyển đổi nhanh giữa các thành phố chỉ với 1 chạm.
5. **Cơ chế Cache Ngoại Tuyến (Offline-First)**:
   - Tự động lưu trữ phản hồi thô gần nhất vào `shared_preferences`.
   - Khi không có mạng (hoặc máy chủ không phản hồi), ứng dụng hiển thị dữ liệu cache gần nhất kèm thanh cảnh báo `⚡ Đang xem dữ liệu ngoại tuyến (Cập nhật lúc HH:mm)`.
   - Cơ chế tự động làm mới: Chỉ gọi lại API nếu cache cũ hơn 30 phút hoặc khi người dùng chủ động kéo xuống để làm mới (Pull-to-refresh) hoặc ấn nút Refresh.
6. **Phong cách Retro Pixel Art**:
   - Nút bấm cơ học stepped press (nhảy bước tức thì khi chạm).
   - Bảng màu nền thông minh tự đổi theo điều kiện: Nắng ấm (Cam/Vàng Mistral), Mưa/Dông (Xanh mưa Slate), Mây/Sương mù (Xám tro), Ban đêm (Xanh chàm huyền bí).
   - Hỗ trợ cả Light Mode và Dark Mode.

---

## 📁 Cấu trúc thư mục

```
weather-mb/
  android/                     # Cấu hình Android (đã bật quyền INTERNET)
  ios/                         # Cấu hình iOS
  lib/
    main.dart                  # Khởi tạo SharedPreferences & ProviderScope
    models/
      weather_models.dart      # WeatherData, CurrentCondition, DayForecast, HourForecast
    services/
      weather_service.dart     # WeatherServiceBase (interface) & WttrWeatherService
      cache_service.dart       # Quản lý lưu trữ Shared Preferences & cache 30 phút
    providers/
      weather_provider.dart    # Riverpod Notifier & AsyncNotifier quản lý state
    screens/
      home_screen.dart         # Màn hình chính
      locations_screen.dart    # Quản lý danh sách địa điểm yêu thích
      settings_screen.dart     # Đổi đơn vị °C/°F, xem và dọn dẹp cache
    widgets/
      pixel_widgets.dart       # PixelCard, PixelButton, PixelBadge
      pixel_weather_icon.dart  # CustomPainter vẽ icon pixel 8-bit (Nắng, Mây, Mưa, Sét...)
      hourly_forecast_card.dart# Thẻ dự báo theo giờ
      daily_forecast_card.dart # Thẻ dự báo 3 ngày
      weather_details_grid.dart# Lưới 6 chỉ số khí tượng
      pixel_loading_view.dart  # Màn hình skeleton 8-bit khi tải dữ liệu
      pixel_error_view.dart    # Màn hình thông báo lỗi và nút thử lại
    utils/
      weather_code_utils.dart  # Ánh xạ mã thời tiết sang tiếng Việt, icon & bảng màu
  test/
    cache_service_test.dart    # Kiểm thử logic cache & danh sách yêu thích
    weather_models_test.dart   # Kiểm thử parse JSON an toàn
    weather_service_test.dart  # Kiểm thử gọi API với MockClient
    widget_test.dart           # Kiểm thử giao diện HomeScreen
    live_api_integration_test.dart # Kiểm thử kết nối API wttr.in thực tế
```

---

## 🛠️ Hướng dẫn cài đặt & Chạy ứng dụng

### 1. Yêu cầu môi trường
- **Flutter SDK**: `>= 3.16.0` (Khuyến nghị 3.24+ / 3.47+)
- **Dart SDK**: `>= 3.12.0 < 4.0.0`
- Thiết bị hoặc máy ảo Android / iOS / Web / Desktop.

### 2. Cài đặt các gói phụ thuộc
```bash
cd weather-mb
flutter pub get
```

### 3. Kiểm tra mã nguồn (Analyze)
```bash
flutter analyze
```
*(Đạt chuẩn: 0 lỗi, 0 cảnh báo)*

### 4. Chạy bộ kiểm thử tự động (Unit & Widget Tests)
```bash
flutter test
```

### 5. Chạy ứng dụng
```bash
flutter run
```

---

## 🔄 Cách thay đổi nguồn dữ liệu API (ví dụ: sang Open-Meteo)

Dự án được thiết kế theo nguyên tắc phụ thuộc đảo ngược (Dependency Inversion) với giao diện trừu tượng `WeatherServiceBase`:

1. Mở file [lib/services/weather_service.dart](file:///C:/PetProject/weather-mb/lib/services/weather_service.dart).
2. Tạo một lớp mới hiện thực hóa `WeatherServiceBase`:
   ```dart
   class OpenMeteoWeatherService implements WeatherServiceBase {
     @override
     Future<WeatherData> fetchWeather(String location) async {
       // 1. Gọi geocoding API của Open-Meteo để lấy lat/long từ tên location
       // 2. Gọi https://api.open-meteo.com/v1/forecast?...
       // 3. Map dữ liệu về đối tượng chuẩn WeatherData
     }
   }
   ```
3. Mở file [lib/providers/weather_provider.dart](file:///C:/PetProject/weather-mb/lib/providers/weather_provider.dart) và cập nhật `weatherServiceProvider`:
   ```dart
   final weatherServiceProvider = Provider<WeatherServiceBase>((ref) {
     return OpenMeteoWeatherService(); // Thay thế WttrWeatherService()
   });
   ```
Toàn bộ tầng giao diện (UI), bộ nhớ đệm (Cache), và quản lý trạng thái (Riverpod) sẽ hoạt động bình thường mà không cần sửa đổi bất kỳ dòng code nào khác.
