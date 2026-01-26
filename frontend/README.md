# 🎨 Frontend – Caro Online

## 📌 Giới thiệu
Frontend của dự án **Caro Online** được xây dựng bằng **Flutter**, hỗ trợ đa nền tảng:
- Android
- Web

Frontend chịu trách nhiệm:
- Giao diện người dùng
- Điều hướng màn hình
- Giao tiếp với Backend qua REST API và WebSocket
- Đồng bộ trạng thái game realtime

---

## 🛠️ Công nghệ sử dụng
- Flutter
- Dart
- Material Design 3
- Riverpod (State Management)
- go_router (Navigation)
- WebSocket

---

## 📂 Cấu trúc thư mục

**Lưu ý:** sau này ta sẽ code Frontend trên thư mục frontend/lib

```
lib/
├── screens/        # Các màn hình chính của ứng dụng
│   ├── login/      # Màn hình đăng nhập / đăng ký
│   ├── home/       # Trang chủ
│   └── game/       # Phòng chơi Caro
│
├── widgets/        # Các widget dùng chung (button, dialog, board cell...)
│
├── models/         # Model dữ liệu (User, Room, Move...)
│
├── services/       # Giao tiếp với backend
│   ├── api_service.dart     # REST API (login, user, history)
│   └── socket_service.dart  # WebSocket (move, chat, room)
│
├── providers/      # Riverpod providers (state, controller)
│
├── routes/         # Cấu hình điều hướng (go_router)
│
└── main.dart       # Entry point của ứng dụng
```

---

## 🚀 Cách chạy project

### Chạy ứng dụng
- Cài đặt Flutter SDK (Nếu chưa có)
   1. https://docs.flutter.dev/install/manual
   2. Tải bản flutter_windows_3.xx.x-stable.zip
   3. Tạo tư mục và giải nén (**Ví dụ** D:\FileSetUp\flutter)
   4. Thêm vào **SYSTEM PATH** đường dẫn: `D:\FileSetUp\flutter\bin`
   5. Kiểm tra bằng `flutter --version`

- Nếu sử dụng VSCode
   1. Cài Flutter và Dart Extension

- Vào thư mục CaroFlutter và chạy các lệnh sau:
```bash
cd frontend # Vào thư mục frontend
flutter pub get # Cài đặt các thư viện cho Flutter
flutter doctor # Nếu báo lỗi tức là thiếu công cụ chạy android hay web, hãy fix từng lỗi tương ứng
flutter run # Nếu sử dụng web, nhấn 2 để chạy Chrome; Nếu sử dụng android có dây, cắm dây vào và chạy lệnh này
```