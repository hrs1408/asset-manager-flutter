# Hướng dẫn Deploy Dashboard lên Firebase Hosting

## Cách 1: Deploy thủ công qua Firebase Console

### Bước 1: Chuẩn bị files
1. Đảm bảo đã build thành công: `flutter build web --release --base-href "/"`
2. Thư mục `build/web` chứa tất cả files cần deploy

### Bước 2: Truy cập Firebase Console
1. Mở https://console.firebase.google.com/
2. Tạo project mới hoặc chọn project có sẵn
3. Vào **Hosting** từ menu bên trái

### Bước 3: Deploy
1. Click **Get started** (nếu lần đầu) hoặc **Add another site**
2. Chọn **Upload files manually**
3. Kéo thả toàn bộ nội dung thư mục `build/web` vào
4. Click **Deploy**

## Cách 2: Sử dụng Firebase CLI (cần Node.js >= 20)

### Cài đặt Node.js mới
1. Tải Node.js >= 20 từ https://nodejs.org/
2. Cài đặt và restart terminal

### Deploy với CLI
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Đăng nhập
firebase login

# Khởi tạo project (nếu chưa có)
firebase init hosting

# Deploy
firebase deploy
```

## Cách 3: Sử dụng GitHub Actions (Tự động)

Tạo file `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches: [ main ]

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.29.2'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build web
      run: flutter build web --release --base-href "/"
    
    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        projectId: 'quan-ly-tai-san-demo'
```

## Cấu hình đã sẵn sàng

✅ **firebase.json** - Cấu hình hosting
✅ **.firebaserc** - Project ID  
✅ **build/web** - Files đã build
✅ **SEO Meta tags** - Tối ưu SEO
✅ **PWA Manifest** - Progressive Web App

## Kiểm tra sau khi deploy

1. **Functionality**: Tất cả tính năng dashboard hoạt động
2. **Responsive**: Hiển thị tốt trên mobile/tablet
3. **Performance**: Tốc độ tải nhanh
4. **SEO**: Meta tags hiển thị đúng
5. **PWA**: Có thể cài đặt như app

## Tối ưu hóa

### Caching
- Static assets: 1 năm
- Images/JSON: 1 ngày
- HTML: Không cache

### Performance
- Tree-shaking fonts đã enable
- Minified JavaScript
- Compressed assets

### Security
- HTTPS mặc định
- Content Security Policy
- Safe redirects

## Troubleshooting

### Lỗi thường gặp:
1. **404 Error**: Kiểm tra `rewrites` trong firebase.json
2. **Blank page**: Kiểm tra `base-href` và console errors
3. **Slow loading**: Optimize images và enable caching

### Debug:
```bash
# Test local
flutter run -d chrome

# Build và test
flutter build web --release
# Mở build/web/index.html trong browser
```

## URLs sau khi deploy

- **Production**: https://quan-ly-tai-san-demo.web.app
- **Preview**: https://quan-ly-tai-san-demo.firebaseapp.com

---

**Lưu ý**: Dashboard hiện đang chạy ở chế độ demo với dữ liệu mẫu. Để sử dụng dữ liệu thực, cần cấu hình Firebase Authentication và Firestore.