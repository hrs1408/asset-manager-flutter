# Hướng dẫn các loại giao dịch

## Tổng quan
Ứng dụng quản lý tài sản hỗ trợ 3 loại giao dịch chính:

## 1. Giao dịch Chi tiêu (Expense) 🔴
- **Mô tả**: Giao dịch trừ tiền từ tài sản để chi tiêu
- **Biểu tượng**: ➖ (dấu trừ màu đỏ)
- **Màu sắc**: Đỏ
- **Cách hoạt động**: 
  - Trừ số tiền từ tài sản được chọn
  - Ghi nhận vào danh mục chi tiêu
  - Hiển thị với dấu "-" và màu đỏ
- **Thông tin hiển thị**:
  - Tiêu đề: Tên danh mục chi tiêu
  - Phụ đề: Mô tả giao dịch (nếu có)
  - Số tiền: -XX.XXX ₫ (màu đỏ)

## 2. Giao dịch Nộp tiền (Deposit) 🟢
- **Mô tả**: Giao dịch cộng tiền vào tài sản từ nguồn bên ngoài
- **Biểu tượng**: ➕ (dấu cộng màu xanh)
- **Màu sắc**: Xanh lá
- **Cách hoạt động**:
  - Cộng số tiền vào tài sản được chọn
  - Ghi nhận nguồn nộp tiền (lương, thưởng, bán hàng, etc.)
  - Hiển thị với dấu "+" và màu xanh
- **Thông tin hiển thị**:
  - Tiêu đề: "Nộp tiền"
  - Phụ đề: "Từ [Nguồn nộp tiền]" (VD: "Từ Lương")
  - Số tiền: +XX.XXX ₫ (màu xanh)

## 3. Giao dịch Chuyển tiền (Transfer) 🔵
- **Mô tả**: Giao dịch chuyển tiền giữa các tài sản
- **Biểu tượng**: ↔️ (mũi tên đôi màu xanh dương)
- **Màu sắc**: Xanh dương
- **Cách hoạt động**:
  - Tạo 2 giao dịch liên kết:
    - Giao dịch trừ tiền từ tài sản nguồn (số âm, màu đỏ)
    - Giao dịch cộng tiền vào tài sản đích (số dương, màu xanh)
- **Thông tin hiển thị**:
  - Tiêu đề: "Chuyển tiền"
  - Phụ đề: 
    - Tài sản nguồn: "Chuyển đến [Tên tài sản đích]"
    - Tài sản đích: "Nhận từ [Tên tài sản nguồn]"
  - Số tiền: 
    - Tài sản nguồn: -XX.XXX ₫ (màu đỏ)
    - Tài sản đích: +XX.XXX ₫ (màu xanh)

## Cách phân biệt trong giao diện

### Icon và màu sắc
- **Chi tiêu**: Icon ➖ với nền đỏ nhạt
- **Nộp tiền**: Icon ➕ với nền xanh nhạt  
- **Chuyển tiền**: Icon ↔️ với nền xanh dương nhạt

### Hiển thị số tiền
- **Chi tiêu**: `-XX.XXX ₫` (màu đỏ)
- **Nộp tiền**: `+XX.XXX ₫` (màu xanh)
- **Chuyển tiền**: 
  - Tài sản nguồn: `-XX.XXX ₫` (màu đỏ)
  - Tài sản đích: `+XX.XXX ₫` (màu xanh)

### Thông tin bổ sung
- **Chi tiêu**: Hiển thị tên danh mục và mô tả
- **Nộp tiền**: Hiển thị nguồn nộp tiền
- **Chuyển tiền**: Hiển thị tài sản liên quan (nguồn/đích)

## Xử lý khi xóa giao dịch

### Chi tiêu
- Cộng lại số tiền vào tài sản

### Nộp tiền  
- Trừ số tiền khỏi tài sản

### Chuyển tiền
- Hoàn nguyên cả 2 tài sản:
  - Cộng lại tiền cho tài sản nguồn
  - Trừ tiền khỏi tài sản đích

## Ví dụ thực tế

### Chi tiêu
```
🔴 Ăn uống               SeaBank
   Ăn trưa hôm nay       -70.000 ₫
   01/08/2025 10:59
```

### Nộp tiền
```
🟢 Nộp tiền             SeaBank  
   Từ Lương             +10.000.000 ₫
   01/08/2025 10:59
```

### Chuyển tiền
```
🔵 Chuyển tiền          Test1
   Chuyển đến Test2     -10.000.000 ₫
   01/08/2025 10:59

🔵 Chuyển tiền          Test2
   Nhận từ Test1        +10.000.000 ₫
   01/08/2025 10:59
```