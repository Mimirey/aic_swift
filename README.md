# Swift — Courier Delivery App

Aplikasi Flutter untuk kurir pengiriman paket dengan optimasi rute otomatis, navigasi real-time, dan pelacakan posisi kurir secara live.

## Fitur

- Optimasi dan re-prioritisasi urutan pengiriman secara otomatis berdasarkan posisi kurir saat ini
- Navigasi turn-by-turn secara real-time melalui WebSocket
- Deteksi kurir keluar dari rute dan auto-reroute
- Live GPS tracking posisi kurir ke backend
- Bukti pengiriman berupa foto sebelum paket dapat dikonfirmasi selesai
- Dukungan COD (*Cash on Delivery*) dengan badge dan informasi tagihan
- Notifikasi kedatangan menggunakan getar dan suara

## Tech Stack

- **Framework:** Flutter
- **State Management:** GetX
- **Map & Routing:** `flutter_map`, `flutter_polyline_points`, `latlong2`
- **Realtime:** `web_socket_channel`
- **Location:** `geolocator`
- **Media:** `image_picker`, `audioplayers`, `vibration`

## Prasyarat

Sebelum menjalankan aplikasi, pastikan telah tersedia:

- Flutter SDK
- Backend Swift yang sedang berjalan
- URL backend yang dapat diakses oleh aplikasi
- Perangkat atau emulator dengan akses jaringan
- Izin lokasi dan kamera

Backend Swift menyediakan endpoint berikut.

### REST API

- `POST /api/v1/auth/login`
- `GET /api/v1/shipments`
- `POST /api/v1/pathfinding/find-optimized-delivery-route`

### WebSocket

WebSocket menggunakan autentikasi JWT melalui query parameter:

```text
?token=<jwt>
```

Endpoint yang digunakan:

- `/api/v1/ws/navigation`
- `/api/v1/ws/driver/position`

---

## Akun Demo
Berikut merupakan akun kurir dari seed backend yang dapat diakses
| Username | Password |
|---|---|
| `sari` | `rahasia123` |
| `joko` | `rahasia123` |
| `budi` | `rahasia123` |

Catatan: Penyebaran paket setiap akun kurir berlokasi secara spesifik di area Besito, Kudus, Jawa Tengah. Testing menggunakan aplikasi FakeGPS pihak ketiga memungkinkan perpindahan lokasi.

# Konfigurasi Backend URL

Aplikasi tidak menghardcode alamat backend secara langsung di dalam source code.

Seluruh komunikasi dengan backend, baik melalui REST API maupun WebSocket, menggunakan satu konfigurasi dasar bernama `API_BASE_URL`.

Nilai tersebut dikirim saat aplikasi dijalankan atau dibangun menggunakan `--dart-define`.

Konfigurasi berada pada:

```text
lib/core/network/api_constants.dart
```

Dengan nilai default:

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000/',
);
```

Nilai default tersebut digunakan untuk mempermudah development menggunakan Android Emulator dengan backend yang berjalan pada port `8000`.

---

## Menggunakan Backend melalui Cloudflare Tunnel

Backend Swift dapat diakses secara remote melalui Cloudflare Tunnel.

Gunakan URL tunnel yang dihasilkan atau dikonfigurasi pada backend sebagai nilai `API_BASE_URL`.

Contoh:

```bash
flutter run --dart-define=API_BASE_URL=https://<backend-tunnel-url>/
```

Misalnya backend dapat diakses melalui:

```text
https://swift-api.example.com/
```

Maka jalankan aplikasi dengan:

```bash
flutter run --dart-define=API_BASE_URL=https://swift-api.example.com/
```

Aplikasi akan menggunakan URL tersebut untuk seluruh request REST API.

Contohnya:

```text
https://swift-api.example.com/api/v1/auth/login

https://swift-api.example.com/api/v1/shipments

https://swift-api.example.com/api/v1/pathfinding/find-optimized-delivery-route
```

---

## Konfigurasi WebSocket

URL WebSocket tidak perlu dikonfigurasi secara terpisah.

Aplikasi secara otomatis membentuk URL WebSocket berdasarkan `API_BASE_URL`.

Konversi skema dilakukan sebagai berikut:

```text
http  → ws
https → wss
```

Sebagai contoh:

```text
API_BASE_URL:

https://swift-api.example.com/
```

Akan menghasilkan koneksi WebSocket:

```text
wss://swift-api.example.com/api/v1/ws/navigation

wss://swift-api.example.com/api/v1/ws/driver/position
```

Dengan demikian, cukup mengatur satu environment variable:

```text
API_BASE_URL
```

untuk REST API dan WebSocket.

---

# Development dengan Backend Lokal

Selain menggunakan Cloudflare Tunnel, aplikasi juga dapat dijalankan menggunakan backend lokal.

## Android Emulator

Jika backend berjalan pada komputer host di:

```text
http://localhost:8000/
```

Android Emulator dapat mengaksesnya melalui:

```text
http://10.0.2.2:8000/
```

Jalankan:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/
```

---

## iOS Simulator

Untuk iOS Simulator, gunakan:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/
```

---

## Physical Device

Jika aplikasi dijalankan pada perangkat fisik, perangkat dan komputer yang menjalankan backend harus berada dalam jaringan yang sama.

Gunakan alamat IP lokal komputer.

Contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/
```

Ganti:

```text
192.168.x.x
```

dengan IP lokal komputer yang menjalankan backend.

Ganti port `8000` apabila backend menggunakan port yang berbeda.

---

# Menjalankan Aplikasi

Install dependency:

```bash
flutter pub get
```

Kemudian jalankan aplikasi menggunakan URL backend yang sesuai.

## Menggunakan Cloudflare Tunnel

```bash
flutter run \
  --dart-define=API_BASE_URL=https://<backend-tunnel-url>/
```

## Menggunakan Backend Lokal pada Android Emulator

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/
```

---

# Build Release

Untuk membuat APK release:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://<backend-tunnel-url>/
```

Contoh:

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://swift-api.example.com/
```

Pastikan URL backend yang digunakan dapat diakses dari perangkat yang menjalankan aplikasi.

---

# Catatan

- Aplikasi membutuhkan izin lokasi untuk fitur live tracking dan navigasi.
- Aplikasi membutuhkan izin kamera untuk mengambil bukti foto pengiriman.
- Autentikasi menggunakan JWT yang disimpan secara lokal setelah proses login.
- Token JWT digunakan saat membuat koneksi WebSocket melalui query parameter:

```text
?token=<jwt>
```

- REST API dan WebSocket menggunakan `API_BASE_URL` yang sama.
- Jika `API_BASE_URL` menggunakan `https`, koneksi WebSocket akan menggunakan `wss`.
- Jika `API_BASE_URL` menggunakan `http`, koneksi WebSocket akan menggunakan `ws`.
- Untuk testing menggunakan backend yang telah diekspos melalui Cloudflare Tunnel, gunakan URL tunnel sebagai `API_BASE_URL`.
