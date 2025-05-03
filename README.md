# Chatbox

**Chatbox** là một ứng dụng Flutter đơn giản để trò chuyện, tích hợp API và lưu lịch sử chat bằng SQLite.

## ⚙️ Tính năng

- Giao diện chat dễ dùng  
- Gọi API qua `http`  
- Cấu hình bằng file `.env`  
- Lưu dữ liệu cục bộ bằng `sqflite`  

## 🚀 Cài đặt

### 1. Yêu cầu

- Cài Flutter: [flutter.dev/docs](https://flutter.dev/docs/get-started/install)

### 2. Clone dự án

```bash
git clone <repository-url>
cd chatbox
```

### 3. Cài thư viện

```bash
flutter pub get
```

### 4. Tạo file môi trường `.env`

- Vào thư mục `assets/`
- Tạo file `.env` hoặc sao chép từ mẫu:

```bash
cp assets/.env.example assets/.env
```

- Mở `assets/.env` và điền thông tin thật, ví dụ:

```env
API_OPENAI_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
```

### 5. Chạy ứng dụng

```bash
flutter run
```

## 📁 Cấu trúc thư mục

- `lib/` – Mã nguồn chính
  - `main.dart` – Điểm khởi đầu ứng dụng
  - `widgets/` – Widget dùng chung 
  - `screens/` – Các màn hình 
  - `utils/` – Tiện ích và hằng số 
  - `services/` – Gọi API từ assets
  - `database/` – Xử lý SQLite
  - `models/` – Mô hình dữ liệu 

## 📦 Các thư viện sử dụng

- `http`  
- `flutter_dotenv`  
- `sqflite`  
- `path_provider`  
- `path`  
