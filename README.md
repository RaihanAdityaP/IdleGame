# Idle Warung

Idle clicker game sederhana yang dibangun dengan Flutter. Kamu tap, kamu upgrade, warungmu berkembang sendiri.

Proyek ini dibuat sebagai studi kasus game development dengan Flutter — fokus pada arsitektur yang bersih, game loop yang efisien, dan persistensi data lokal.

---

## Stack

| Teknologi | Kegunaan |
|---|---|
| Flutter | UI dan rendering |
| Dart | Bahasa pemrograman |
| Provider + ChangeNotifier | State management |
| SharedPreferences | Persistensi data lokal |

---

## Fitur

- **Auto income** — koin bertambah otomatis setiap 100ms berdasarkan total CPS dari upgrade yang dimiliki
- **8 upgrade** dengan harga scaling (naik 15% tiap pembelian), dibagi dua kategori: IDLE (auto CPS) dan TAP (manual CPC)
- **4 tipe random event** — Airdrop, Rush Hour, Pelanggan VIP, dan Bencana — dipicu secara acak setiap 30–90 detik
- **Milestone reward** — event positif otomatis terpicu saat koin mencapai 1K, 10K, 50K, 200K, dan 1M
- **Animasi tap** — scale press, pulse border, dan floating number dengan offset horizontal acak
- **Auto-save** setiap 5 detik dan langsung setelah beli upgrade

---

## Arsitektur

```
Widget Flutter  →  GameState (ChangeNotifier)  →  SharedPreferences
   (UI layer)        (single source of truth)        (local storage)
```

Semua widget memanggil `context.watch<GameState>()` dan rebuild otomatis setiap kali state berubah. Tidak ada state lokal di widget selain animasi.

### Komponen utama

- `MainScreen` — root screen, menyatukan semua panel
- `TapZone` — area tap utama, mengelola `AnimationController` untuk scale dan pulse
- `ShopPanel` — daftar upgrade yang bisa dibeli
- `StatsPanel` — menampilkan statistik real-time
- `ActiveEventBar` — menampilkan event yang sedang aktif beserta countdown
- `GameState` — semua logika game: timer, upgrade, event, save/load

---

## Sistem Timer

Game berjalan dengan tiga timer yang berjalan paralel sejak `GameState` diinisialisasi:

| Timer | Interval | Fungsi |
|---|---|---|
| Tick | 100ms | Tambah koin otomatis, cek milestone |
| Save | 5 detik | Auto-save ke SharedPreferences |
| Event | 30–90 detik (acak) | Picu random event, jadwal ulang rekursif |

---

## Upgrade

| Nama | Base Cost | Bonus | Tipe |
|---|---|---|---|
| Gelas Plastik | 10 | +0.5/s | IDLE |
| Gerobak Baru | 100 | +3/s | IDLE |
| Menu Tambahan | 500 | +12/s | IDLE |
| Pelayan | 2.000 | +40/s | IDLE |
| Dapur Express | 10.000 | +150/s | IDLE |
| Spatula Pro | 50 | +5/tap | TAP |
| Tangan Cepat | 300 | +20/tap | TAP |
| Resep Rahasia | 1.500 | +80/tap | TAP |

Formula harga: `baseCost × 1.15^owned`

---

## Event

| Event | Efek | Durasi |
|---|---|---|
| Airdrop | Bonus koin instan (`max(value, cps × 10)`) | 4 detik |
| Rush Hour | CPS ×2 | 15 detik |
| Pelanggan VIP | Tap ×5 | 20 detik |
| Bencana | Bayar atau CPS turun 30% | 10 detik |

---

## Persistensi Data

Data yang disimpan ke SharedPreferences:

- `coins` — jumlah koin saat ini
- `upgrades` — `owned` count per upgrade dalam format `id:owned,id:owned,...`
- `milestones` — daftar milestone yang sudah dicapai

> Catatan desain: yang disimpan adalah nilai `owned` per upgrade, bukan nilai `_baseCps` atau `_baseCpc` secara langsung. Saat `load()`, kedua nilai tersebut dihitung ulang dari `owned`. Ini mencegah data corrupt jika definisi upgrade berubah di versi berikutnya.

---

## Download & Menjalankan Proyek

### Install APK (Android)

Download file APK dari halaman rilis:

[github.com/RaihanAdityaP/IdleGame/releases/tag/v1.0.0](https://github.com/RaihanAdityaP/IdleGame/releases/tag/v1.0.0)

Extract file `.zip`, lalu install `IdleWarungv1.0.0.apk` di perangkat Android. Pastikan opsi **Install from unknown sources** sudah diaktifkan di pengaturan perangkat.

### Jalankan dari Source

Pastikan Flutter SDK sudah terinstall, lalu:

```bash
git clone https://github.com/RaihanAdityaP/IdleGame.git
cd IdleGame
flutter pub get
flutter run
```

---

## Lisensi

MIT
