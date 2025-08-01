# Dashboard - Ứng dụng Quản lý Tài sản

## Tổng quan

Dashboard đã được phát triển với các tính năng hiện đại và giao diện người dùng thân thiện, bao gồm:

### ✨ Tính năng chính

1. **Tổng quan tài chính**
   - Hiển thị tổng tài sản và tổng chi tiêu
   - Animated counters với hiệu ứng mượt mà
   - Cards với gradient và shadow đẹp mắt

2. **Thao tác nhanh**
   - Thêm tài sản mới
   - Thêm chi tiêu mới  
   - Xem báo cáo chi tiết

3. **Biểu đồ phân tích**
   - **Pie Chart**: Phân bổ tài sản theo loại
   - **Bar Chart**: Chi tiêu theo danh mục
   - **Line Chart**: Xu hướng chi tiêu theo thời gian

4. **Thông tin hữu ích (Insights)**
   - Đánh giá tình hình tài chính
   - Gợi ý cải thiện quản lý tài sản
   - Cảnh báo về quỹ khẩn cấp

5. **Giao dịch gần đây**
   - Hiển thị 5 giao dịch mới nhất
   - Thông tin chi tiết về từng giao dịch

### 🎨 Thiết kế UI/UX

- **Responsive Design**: Tự động điều chỉnh theo kích thước màn hình
- **Material Design 3**: Sử dụng design system hiện đại
- **Animations**: Hiệu ứng mượt mà và tự nhiên
- **Color Scheme**: Bảng màu hài hòa và chuyên nghiệp
- **Loading States**: Shimmer loading cho trải nghiệm tốt hơn

### 📱 Cấu trúc Dashboard

```
Dashboard
├── Welcome Header (Chào mừng + ngày hiện tại)
├── Quick Actions (Thao tác nhanh)
├── Date Range Selector (Chọn khoảng thời gian)
├── Overview Cards (Tổng quan tài sản & chi tiêu)
├── Charts Section (Các biểu đồ phân tích)
│   ├── Asset Distribution (Phân bổ tài sản)
│   ├── Expense by Category (Chi tiêu theo danh mục)
│   └── Expense Trend (Xu hướng chi tiêu)
├── Insights (Thông tin hữu ích)
└── Recent Transactions (Giao dịch gần đây)
```

## 🚀 Cách chạy Demo

### Chạy Demo Dashboard

```bash
# Đảm bảo đang ở thư mục dự án
cd quan_ly_tai_san

# Build và chạy web
flutter build web
```

Sau đó mở file `build/web/index.html` trong trình duyệt.

### Chuyển về App đầy đủ

Để chạy app đầy đủ với Firebase, sửa file `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Comment dòng này để chạy app đầy đủ
  // runApp(const DemoApp());
  // return;
  
  // Uncomment phần này
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirestoreService.enableOfflinePersistence();
  await di.init();
  
  runApp(const MyApp());
}
```

## 📊 Dữ liệu Demo

Dashboard demo sử dụng dữ liệu mẫu bao gồm:

### Tài sản (150 triệu VNĐ)
- Tài khoản thanh toán: 25 triệu VNĐ
- Tài khoản tiết kiệm: 80 triệu VNĐ  
- Vàng: 30 triệu VNĐ
- Bất động sản: 15 triệu VNĐ

### Chi tiêu (12 triệu VNĐ/tháng)
- Ăn uống: 4.5 triệu VNĐ (37.5%)
- Di chuyển: 2.8 triệu VNĐ (23.3%)
- Mua sắm: 2.2 triệu VNĐ (18.3%)
- Giải trí: 1.5 triệu VNĐ (12.5%)
- Khác: 1 triệu VNĐ (8.3%)

## 🛠️ Cấu trúc Code

### Widgets chính

1. **EnhancedDashboardScreen**: Dashboard chính với đầy đủ tính năng
2. **DemoDashboardScreen**: Dashboard demo với dữ liệu mẫu
3. **DashboardInsights**: Widget hiển thị thông tin hữu ích
4. **DashboardStatsCard**: Card hiển thị thống kê
5. **Chart Widgets**: Các widget biểu đồ (Pie, Bar, Line)

### Dữ liệu Demo

- `DemoDashboardData`: Class chứa dữ liệu mẫu
- `AssetSummary`: Entity tổng hợp tài sản
- `ExpenseSummary`: Entity tổng hợp chi tiêu
- `CategoryExpense`: Entity chi tiêu theo danh mục

## 🎯 Tính năng nâng cao

### Responsive Grid
```dart
ResponsiveGrid(
  children: [
    _buildAssetOverviewCard(),
    _buildExpenseOverviewCard(),
  ],
)
```

### Animated Counter
```dart
AnimatedCounter(
  value: 150000000,
  textStyle: TextStyle(fontSize: 24),
  suffix: ' VNĐ',
)
```

### Shimmer Loading
```dart
ShimmerLoading(
  child: Container(
    height: 100,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

## 📈 Kế hoạch phát triển

- [ ] Thêm filter và search cho giao dịch
- [ ] Export báo cáo PDF/Excel
- [ ] Thông báo push cho các sự kiện quan trọng
- [ ] Dark mode support
- [ ] Offline sync với local database
- [ ] Multi-currency support
- [ ] Budget planning và tracking

## 🤝 Đóng góp

Dashboard được xây dựng với kiến trúc Clean Architecture và có thể dễ dàng mở rộng. Các tính năng mới có thể được thêm vào thông qua:

1. Tạo entities mới trong `domain/entities/`
2. Implement use cases trong `domain/usecases/`
3. Tạo widgets mới trong `presentation/widgets/`
4. Cập nhật BLoC state management

---

**Lưu ý**: Dashboard hiện tại đang chạy ở chế độ demo. Để tích hợp với Firebase và dữ liệu thực, cần cấu hình lại `main.dart` và implement các repository classes.