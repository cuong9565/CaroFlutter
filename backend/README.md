# 🧠 Backend – Caro Online

## 📌 Giới thiệu
Backend của dự án **Caro Online** được xây dựng bằng **NestJS**, chịu trách nhiệm:
- Xác thực người dùng
- Quản lý phòng chơi
- Xử lý game realtime qua WebSocket
- Kiểm tra luật chơi và chống gian lận
- Lưu trữ dữ liệu (PostgreSQL, Redis)

---

## 🛠️ Công nghệ sử dụng
- NestJS
- TypeScript
- REST API
- Socket.IO
- PostgreSQL
- Redis

---

## 📂 Cấu trúc thư mục
```
src/
├── auth/           # Xác thực (login, register, JWT)
│
├── users/          # Quản lý thông tin người dùng
│
├── game/           # Logic game Caro (quan trọng nhất)
│   ├── game.gateway.ts   # WebSocket gateway (Socket.IO)
│   ├── game.service.ts   # Xử lý phòng, lượt chơi
│   └── game.logic.ts     # Luật Caro: check win, validate move
│
├── chat/           # Chat realtime trong phòng chơi
│
├── common/         # Code dùng chung (guard, decorator, utils)
│
├── app.module.ts   # Module gốc
└── main.ts         # Entry point

```

---

## 🔄 Luồng hoạt động game (Game Flow)

1. **Người dùng đăng nhập** thông qua REST API
2. **Client kết nối WebSocket** tới server
3. Người chơi **tạo phòng** hoặc **tham gia phòng hiện có**
4. Người chơi thực hiện **nước đi**
5. **Server xử lý nước đi**:

   * Kiểm tra tính hợp lệ
   * Cập nhật trạng thái ván đấu
   * Phát (broadcast) trạng thái mới cho các client trong phòng
6. **Kết thúc ván đấu**:

   * Xác định thắng / thua / hòa
   * Lưu lịch sử trận đấu vào database

> 📌 Mọi trạng thái game đều được quản lý và quyết định bởi server.

---

## 🔐 Nguyên tắc bảo mật

* **Server là nguồn sự thật duy nhất (Single Source of Truth)**
* Không tin bất kỳ dữ liệu nào gửi từ client
* Mọi nước đi đều phải được server **validate**:

  * Đúng lượt chơi
  * Ô cờ còn trống
  * Người chơi thuộc phòng hợp lệ
* Client **không xử lý logic thắng / thua**

---

## ⚠️ Lưu ý kiến trúc quan trọng

* Không viết logic game trực tiếp trong `Gateway`
* `Gateway` chỉ đóng vai trò:

  * Nhận sự kiện (event)
  * Gọi service xử lý
  * Phát kết quả về client
* Logic luật chơi phải nằm trong **service / game logic layer**

---

## 🧠 Vai trò của Redis

Redis được sử dụng để:

* Lưu **trạng thái phòng chơi** (room state)
* Quản lý **phiên realtime** (session, player connection)
* Hỗ trợ xử lý nhanh trong môi trường realtime
* Database (PostgreSQL) chỉ dùng cho dữ liệu lâu dài
* Redis dùng cho dữ liệu **tạm thời, realtime**

---

## 🚀 Cách chạy project

### Yêu cầu
- Cài đặt NodeJS nếu sài lệnh node --version không hiện phiên bản (Tải và chạy file .msi trên trang của nodejs)
- Sau khi cài NodeJS, có thể chạy lệnh npm --version hoặc npx --version

### Cài đặt
```bash
cd backend
npm install
```

### Chạy
```bash
npm run start
```