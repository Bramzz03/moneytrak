[README.md](https://github.com/user-attachments/files/29381330/README.md)
# 💰 MoneyTrak

> AI-powered personal finance tracker built with Flutter

---

## 📋 Daftar Isi

- [Instalasi di Windows](#-instalasi-di-windows)
- [Instalasi di macOS](#-instalasi-di-macos)
- [Menjalankan Aplikasi](#%EF%B8%8F-menjalankan-aplikasi)
- [Struktur Proyek](#-struktur-proyek)

---

## 🪟 Instalasi di Windows

### Prasyarat Sistem

- Windows 10 atau Windows 11 (64-bit)
- RAM minimal 8 GB (disarankan 16 GB)
- Ruang penyimpanan minimal 10 GB
- Koneksi internet aktif

---

### Langkah 1 — Install Flutter SDK

1. Download Flutter SDK terbaru di: https://docs.flutter.dev/get-started/install/windows
2. Ekstrak file `.zip` ke lokasi yang **tidak memiliki spasi**, misalnya:

   ```
   C:\flutter
   ```

   ⚠️ **Jangan** letakkan di `C:\Program Files\` karena ada spasi di path-nya.

3. Tambahkan Flutter ke PATH:
   - Buka **Start** → cari **"Environment Variables"** → klik **"Edit the system environment variables"**
   - Klik tombol **"Environment Variables..."**
   - Di bagian **"User variables"**, pilih `Path` → klik **Edit**
   - Klik **New** → masukkan path ke folder `bin` Flutter, contoh: `C:\flutter\bin`
   - Klik **OK** di semua jendela

4. Buka **PowerShell baru** dan verifikasi:
   ```bash
   flutter --version
   ```

---

### Langkah 2 — Install Android Studio

1. Download Android Studio di: https://developer.android.com/studio
2. Jalankan installer dan ikuti wizard instalasi
3. Setelah terbuka, masuk ke **SDK Manager** (ikon kunci inggris di toolbar)
4. Di tab **SDK Platforms**, centang **Android 14.0 (API 34)** atau versi terbaru
5. Di tab **SDK Tools**, pastikan yang berikut tercentang:
   - ✅ Android SDK Build-Tools
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools
6. Klik **Apply** dan tunggu proses download selesai

---

### Langkah 3 — Konfigurasi Android License

Buka **PowerShell** dan jalankan:

```bash
flutter doctor --android-licenses
```

Ketik `y` dan tekan **Enter** untuk menyetujui setiap lisensi yang muncul.

---

### Langkah 4 — Install Visual Studio (untuk Build Windows Desktop)

> Diperlukan jika ingin menjalankan aplikasi sebagai aplikasi desktop Windows.

1. Download Visual Studio Community 2022 di: https://visualstudio.microsoft.com/downloads/
2. Jalankan installer, pilih workload **"Desktop development with C++"**
3. Pastikan komponen berikut tercentang:
   - MSVC v143 (atau terbaru)
   - Windows 11 SDK
4. Klik **Install** dan tunggu hingga selesai

---

### Langkah 5 — Verifikasi Semua Instalasi

Jalankan perintah berikut di PowerShell:

```bash
flutter doctor
```

Pastikan tidak ada ❌ merah. Jika ada ⚠️ kuning, ikuti instruksi yang diberikan.

---

### Langkah 6 — Download & Setup Proyek

1. Download file proyek dari link Google Drive yang sudah dibagikan
2. Klik kanan file `.zip` → pilih **Extract All...** → pilih lokasi penyimpanan, misalnya `C:\Projects\moneytrak`
3. Buka **PowerShell**, lalu arahkan ke folder proyek:
   ```bash
   cd C:\Projects\moneytrak
   ```
4. Install semua dependencies:
   ```bash
   flutter pub get
   ```
5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## 🍎 Instalasi di macOS

### Prasyarat Sistem

- macOS 12 Monterey atau lebih baru
- RAM minimal 8 GB (disarankan 16 GB)
- Ruang penyimpanan minimal 15 GB
- Koneksi internet aktif

---

### Langkah 1 — Install Xcode

1. Buka **App Store** di Mac kamu
2. Cari **Xcode** dan klik **Install** (ukuran ~10 GB)
3. Setelah terinstall, buka Xcode sekali untuk menyetujui license agreement
4. Install **Xcode Command Line Tools** via Terminal:
   ```bash
   sudo xcode-select --install
   ```
5. Verifikasi:
   ```bash
   xcode-select -p
   ```
   Output: `/Applications/Xcode.app/Contents/Developer`

---

### Langkah 2 — Install Homebrew

Buka **Terminal** dan jalankan:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Ikuti instruksi yang muncul, mungkin diminta memasukkan password Mac kamu.

Verifikasi:

```bash
brew --version
```

---

### Langkah 3 — Install Flutter SDK

**Opsi A — Lewat Homebrew (Disarankan):**

```bash
brew install --cask flutter
```

**Opsi B — Manual:**

1. Download Flutter SDK di: https://docs.flutter.dev/get-started/install/macos
2. Ekstrak file `.zip` ke `~/development/flutter`
3. Edit `~/.zshrc`:
   ```bash
   nano ~/.zshrc
   ```
4. Tambahkan baris berikut di akhir file:
   ```bash
   export PATH="$HOME/development/flutter/bin:$PATH"
   ```
5. Simpan (Ctrl+X → Y → Enter) lalu reload:
   ```bash
   source ~/.zshrc
   ```

Verifikasi:

```bash
flutter --version
```

---

### Langkah 4 — Install CocoaPods (untuk iOS)

```bash
sudo gem install cocoapods
```

Atau via Homebrew:

```bash
brew install cocoapods
```

Verifikasi:

```bash
pod --version
```

---

### Langkah 5 — Install Android Studio (opsional, untuk build Android)

1. Download Android Studio di: https://developer.android.com/studio (pilih versi macOS)
2. Drag **Android Studio** ke folder **Applications**
3. Buka Android Studio → ikuti wizard setup awal
4. Masuk ke **SDK Manager** dan install:
   - ✅ Android SDK Platform (API 34 disarankan)
   - ✅ Android SDK Build-Tools
   - ✅ Android Emulator
   - ✅ Android SDK Platform-Tools

---

### Langkah 6 — Setup iOS Simulator

Buka Simulator langsung dari Terminal:

```bash
open -a Simulator
```

Atau lewat Xcode: **Xcode** → **Open Developer Tool** → **Simulator**

---

### Langkah 7 — Konfigurasi Android License

```bash
flutter doctor --android-licenses
```

Ketik `y` dan tekan **Enter** untuk menyetujui setiap lisensi.

---

### Langkah 8 — Verifikasi Semua Instalasi

```bash
flutter doctor
```

Pastikan semua item menampilkan ✅. Untuk item ⚠️, baca dan ikuti instruksi di Terminal.

---

### Langkah 9 — Download & Setup Proyek

1. Download file proyek dari link Google Drive yang sudah dibagikan
2. Klik kanan file `.zip` → pilih **"Extract All"** atau gunakan perintah di Terminal:
   ```bash
   unzip moneytrak.zip -d ~/Projects/
   ```
3. Masuk ke folder proyek di Terminal:
   ```bash
   cd ~/Projects/moneytrak
   ```
4. Install semua dependencies:
   ```bash
   flutter pub get
   ```
5. (Untuk iOS) Install pod dependencies:
   ```bash
   cd ios && pod install && cd ..
   ```
6. Jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## ▶️ Menjalankan Aplikasi

| Perintah                 | Keterangan                                  |
| ------------------------ | ------------------------------------------- |
| `flutter run`            | Jalankan di device/emulator yang terdeteksi |
| `flutter run -d windows` | Jalankan sebagai aplikasi desktop Windows   |
| `flutter run -d macos`   | Jalankan sebagai aplikasi desktop macOS     |
| `flutter run -d chrome`  | Jalankan di browser (web)                   |
| `flutter devices`        | Lihat daftar device yang tersedia           |
| `flutter build apk`      | Build APK untuk Android                     |
| `flutter build ios`      | Build untuk iOS (hanya di macOS)            |

---

## 📁 Struktur Proyek

```
moneytrak/
├── lib/                  # Source code utama (Dart)
│   └── main.dart         # Entry point aplikasi
├── android/              # Konfigurasi Android
├── ios/                  # Konfigurasi iOS
├── macos/                # Konfigurasi macOS desktop
├── windows/              # Konfigurasi Windows desktop
├── web/                  # Konfigurasi web
├── pubspec.yaml          # Dependencies & metadata proyek
└── README.md             # Dokumentasi ini
```

---

## 📦 Dependencies Utama

| Package              | Versi   | Kegunaan                               |
| -------------------- | ------- | -------------------------------------- |
| `hive`               | ^2.2.3  | Database lokal (NoSQL)                 |
| `hive_flutter`       | ^1.1.0  | Integrasi Hive dengan Flutter          |
| `fl_chart`           | ^0.68.0 | Grafik & visualisasi data keuangan     |
| `http`               | ^1.2.0  | HTTP requests                          |
| `shared_preferences` | ^2.3.0  | Penyimpanan preferensi pengguna        |
| `intl`               | ^0.19.0 | Format angka & tanggal (currency, dll) |

---

## 🆘 Troubleshooting

- Dokumentasi Flutter resmi: https://docs.flutter.dev/
- Jika error saat `flutter pub get`, coba `flutter clean` terlebih dahulu lalu ulangi
- Forum komunitas: https://stackoverflow.com/questions/tagged/flutter
