# Hướng dẫn chuyển đổi giữa Demo Data và Production Data

## 📊 Tổng quan

Dashboard hiện hỗ trợ 2 chế độ dữ liệu:

1. **Demo Mode** 🎭: Sử dụng dữ liệu mẫu (hiện tại)
2. **Production Mode** 🏭: Sử dụng dữ liệu thực từ Firebase

## 🔧 Cấu hình chế độ dữ liệu

### File cấu hình: `lib/core/config/app_config.dart`

```dart
class AppConfig {
  // Thay đổi giá trị này để chuyển đổi chế độ
  static const bool _useDemoData = true; // false = Production mode
  
  // Cấu hình Firebase Emulator (cho development)
  static const bool _useFirebaseEmulator = false;
  
  // Các cấu hình khác...
}
```

## 🎭 Demo Mode (Hiện tại)

### Đặc điểm:
- ✅ Không cần Firebase setup
- ✅ Dữ liệu nhất quán và đẹp
- ✅ Hoạt động offline hoàn toàn
- ✅ Nhanh và ổn định
- ❌ Dữ liệu không thay đổi
- ❌ Không có tính năng thực tế

### Dữ liệu Demo:
```
📊 Tài sản: 150 triệu VNĐ
├── Tài khoản thanh toán: 25M (16.7%)
├── Tài khoản tiết kiệm: 80M (53.3%)
├── Vàng: 30M (20.0%)
└── Bất động sản: 15M (10.0%)

💰 Chi tiêu: 12 triệu VNĐ/tháng
├── Ăn uống: 4.5M (37.5%) - 18 giao dịch
├── Di chuyển: 2.8M (23.3%) - 12 giao dịch
├── Mua sắm: 2.2M (18.3%) - 8 giao dịch
├── Giải trí: 1.5M (12.5%) - 5 giao dịch
└── Khác: 1.0M (8.3%) - 2 giao dịch
```

## 🏭 Production Mode

### Yêu cầu:
1. Firebase project đã setup
2. Firestore database đã tạo
3. Authentication đã cấu hình
4. Dữ liệu thực đã có trong Firestore

### Cách chuyển sang Production:

#### Bước 1: Cập nhật cấu hình
```dart
// lib/core/config/app_config.dart
static const bool _useDemoData = false; // Chuyển thành false
```

#### Bước 2: Cấu hình Firebase
Đảm bảo các file sau đã có:
- `firebase_options.dart`
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)

#### Bước 3: Cấu hình Firestore Collections

**Assets Collection:**
```json
{
  "userId": "user_id",
  "name": "Tài khoản VCB",
  "type": "payment_account",
  "balance": 25000000,
  "isActive": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Transactions Collection:**
```json
{
  "userId": "user_id",
  "amount": 85000,
  "type": "expense",
  "categoryId": "category_id",
  "assetId": "asset_id",
  "description": "Cà phê Highlands",
  "date": "timestamp",
  "createdAt": "timestamp"
}
```

**Expense Categories Collection:**
```json
{
  "userId": "user_id",
  "name": "Ăn uống",
  "description": "Chi phí ăn uống",
  "icon": "🍽️",
  "isDefault": true,
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### Bước 4: Build và Deploy
```bash
flutter build web --release
```

## 🧪 Development Mode (Firebase Emulator)

Để test với Firebase Emulator:

```dart
// lib/core/config/app_config.dart
static const bool _useDemoData = false;
static const bool _useFirebaseEmulator = true;
```

### Setup Firebase Emulator:
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Khởi tạo emulator
firebase init emulators

# Chạy emulator
firebase emulators:start
```

## 🔄 Chuyển đổi nhanh

### Demo → Production:
1. Set `_useDemoData = false` trong `app_config.dart`
2. Đảm bảo Firebase đã setup
3. Build lại: `flutter build web --release`

### Production → Demo:
1. Set `_useDemoData = true` trong `app_config.dart`
2. Build lại: `flutter build web --release`

## 🎯 Kiểm tra chế độ hiện tại

### Trong app:
- Nhấn icon ℹ️ trên app bar
- Xem thông tin "Nguồn dữ liệu"

### Trong code:
```dart
print('Current mode: ${AppConfig.dataSourceInfo}');
print('Is demo: ${AppConfig.useDemoData}');
print('Is production: ${AppConfig.isProduction}');
```

## 📈 So sánh các chế độ

| Tính năng | Demo Mode | Production Mode |
|-----------|-----------|-----------------|
| Setup phức tạp | ❌ Không | ✅ Có |
| Dữ liệu thực | ❌ Không | ✅ Có |
| Offline | ✅ Hoàn toàn | ⚠️ Có cache |
| Tốc độ | ✅ Rất nhanh | ⚠️ Phụ thuộc mạng |
| Tính năng đầy đủ | ❌ Hạn chế | ✅ Đầy đủ |
| Phù hợp cho | Demo, Test UI | Sản phẩm thực |

## 🚨 Lưu ý quan trọng

### Khi deploy Production:
1. **Kiểm tra cấu hình**: Đảm bảo `_useDemoData = false`
2. **Test kỹ**: Test với dữ liệu thực trước khi deploy
3. **Backup**: Backup dữ liệu Firebase trước khi thay đổi
4. **Monitor**: Theo dõi logs và performance sau deploy

### Security:
- Cấu hình Firestore Security Rules
- Kiểm tra Authentication rules
- Không expose sensitive data

### Performance:
- Enable Firestore offline persistence
- Cấu hình cache hợp lý
- Optimize queries

---

**Hiện tại**: Dashboard đang chạy ở **Demo Mode** với dữ liệu mẫu đẹp và nhất quán, phù hợp cho demo và presentation.