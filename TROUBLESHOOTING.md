# Hướng dẫn khắc phục sự cố

## Vấn đề hiện tại

### 1. Firebase không tương thích với Windows
- **Triệu chứng**: Lỗi linking khi build cho Windows
- **Nguyên nhân**: Firebase C++ SDK có vấn đề với Visual Studio 2022
- **Giải pháp tạm thời**: Sử dụng Chrome để phát triển

### 2. Cách chạy app

#### Chạy trên Chrome (Khuyến nghị)
```bash
flutter run -d chrome
```

#### Chạy phiên bản test trên Windows
```bash
flutter run -d windows -t lib/main_test.dart
```

#### Chạy phiên bản đơn giản trên Windows
```bash
# Sao lưu pubspec.yaml gốc
copy pubspec.yaml pubspec_backup.yaml

# Sử dụng pubspec đơn giản
copy pubspec_temp.yaml pubspec.yaml

# Clean và get dependencies
flutter clean
flutter pub get

# Chạy app
flutter run -d windows -t lib/main_test.dart

# Khôi phục pubspec gốc
copy pubspec_backup.yaml pubspec.yaml
```

## Giải pháp lâu dài

### 1. Cập nhật Firebase
- Chờ Firebase team khắc phục vấn đề Windows
- Hoặc sử dụng Firebase Web SDK thay vì native

### 2. Phát triển trên Web
- Sử dụng Chrome để phát triển
- Deploy lên Firebase Hosting
- Tạo PWA (Progressive Web App)

### 3. Alternative cho Windows
- Sử dụng Supabase thay vì Firebase
- Hoặc tạo REST API riêng

## Lệnh hữu ích

```bash
# Kiểm tra devices
flutter devices

# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Build for web
flutter build web

# Check Flutter doctor
flutter doctor
```

## Liên hệ hỗ trợ
- Nếu cần hỗ trợ thêm, vui lòng tạo issue mới với thông tin chi tiết về lỗi.