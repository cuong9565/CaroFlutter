# 🎮 CARO ONLINE – Multiplayer Cross-Platform Game

## 📌 Giới thiệu

**CARO ONLINE** là dự án game cờ Caro (Gomoku) chơi trực tuyến, hỗ trợ **Android, iOS và Web**, cho phép người chơi:

* Đăng nhập, kết bạn
* Chơi với bạn bè theo thời gian thực
* Chơi với robot (AI)
* Chat realtime trong phòng chơi
* Xem lịch sử và xếp hạng

Dự án được xây dựng theo định hướng **MVP → sản phẩm thực tế**, phù hợp cho **đồ án lớn / đồ án tốt nghiệp / portfolio kỹ thuật**.

---

## 🎯 Mục tiêu dự án

* Xây dựng hệ thống **multiplayer realtime** ổn định
* Áp dụng kiến trúc **Client – Server – Realtime Socket**
* Đảm bảo tính mở rộng, bảo mật và dễ bảo trì
* Mang lại trải nghiệm chơi mượt mà trên đa nền tảng

---

## 👥 Thành viên (5 người)

Dự án được thực hiện bởi **team 5 người**

### 🔹 Thành viên

| Họ và tên         | MSSV       |
| ----------------- | ---------- |
| Lê Mạnh Cường     | 3123410039 |
| Nguyễn Thanh Phú  | 3123410269 | 
| Từ Tăng Cơ Nghiệp | 3123410237 |
| Vũ Mai Bằng       | 3123410032 | 
| Đỗ Trọng Tín      | 3123410379 | 

---

## 🛠️ Công nghệ sử dụng

### Frontend

* Flutter (Android, iOS, Web)
* Material Design 3
* Riverpod (State Management)
* go_router (Navigation)
* WebSocket

### Backend

* NestJS
* REST API
* Socket.IO
* PostgreSQL
* Redis

---

## 🏗️ Kiến trúc hệ thống

```
Flutter Client
   │
   ├─ REST API (Auth, User, History)
   │
   └─ WebSocket (Game Move, Chat)
           │
        Backend Server (NestJS)
           │
     PostgreSQL / Redis
```

---

## 📂 Cấu trúc thư mục

### Backend

```
src/
 ├ auth/
 ├ users/
 ├ game/
 │   ├ room.service.ts
 │   ├ game.logic.ts
 │   └ game.gateway.ts
 ├ chat/
 └ common/
```

### Frontend

```
lib/
 ├ screens/
 ├ widgets/
 ├ services/
 ├ providers/
 ├ models/
 └ main.dart
```

---

## 🔐 Bảo mật

* Xác thực JWT cho REST API
* Xác thực người dùng cho Socket
* Server validate toàn bộ nước đi
* Không tin dữ liệu từ client

---

## ⚠️ Các lỗi thường gặp cần tránh

* Làm AI trước khi có multiplayer
* Để client tự xử lý thắng/thua
* Không test realtime sớm
* Mỗi người học một công nghệ khác nhau

---

## Cài đặt

* Chạy lệnh dưới đây
```bash
git clone https://github.com/cuong9565/CaroFlutter.git
```

* Vào CaroFlutter
* Vào frontend, backend và thực hiện theo README của folder đó