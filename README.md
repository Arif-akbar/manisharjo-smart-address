# Manisharjo Smart Address 🏡🌍

Aplikasi **Portal Cerdas Alamat Desa Manisharjo**, dikembangkan dengan **Flutter Web** dan **Supabase**. Sistem ini ditujukan untuk memodernisasi pengelolaan dan pencarian alamat warga desa, memudahkan kurir ekspedisi, serta mendigitalisasi pemetaan desa ke dalam platform portal pemerintahan modern yang mudah diakses.

---

## 🌟 Fitur Utama

### 1. Manajemen Data Rumah (Admin)
- Menambahkan, mengedit, dan menghapus data rumah penduduk.
- Integrasi penentuan lokasi (Latitude & Longitude) langsung melalui peta digital interaktif.
- Pengaturan status rumah (Aktif dihuni / Kosong).

### 2. Pencarian Cerdas (Public & Admin)
- Mesin pencari instan (Full-text search) tanpa perlu menekan tombol submit.
- Optimasi *debouncing* dan efisiensi memori dengan algoritma pencarian lokal.

### 3. Peta Digital Desa Interaktif
- Implementasi `flutter_map` dengan data OpenStreetMap gratis.
- Menampilkan seluruh rumah dalam bentuk *Cluster Markers* untuk menghindari layar penuh dengan ikon.
- Terdapat dua versi peta: Peta Admin (dengan fitur edit) dan Peta Publik (bersih dan fokus pada informasi).

### 4. Smart QR Code System
- Setiap rumah yang didaftarkan akan otomatis memiliki **QR Code Unik**.
- Mendukung fitur unduh QR Code (Download PNG), lihat langsung, atau **Cetak Stiker A4** khusus yang mencantumkan detail rumah secara otomatis untuk ditempelkan di depan rumah warga.
- *Scan* QR akan mengarahkan pengguna langsung ke informasi mendetail mengenai rumah tersebut.

### 5. UI/UX "Modern Government Portal"
- Desain *human-centered*, kontras tinggi, elegan, bebas komponen berlebihan.
- Mendukung **Light Mode** dan **Dark Mode** secara otomatis mengikuti sistem OS pengguna.
- Responsif penuh (*Mobile First*, Tablet, dan Desktop PC).

---

## 🛠️ Stack Teknologi

- **Frontend:** [Flutter Web](https://flutter.dev/multi-platform/web) (SDK Stable)
- **State Management:** Provider
- **Routing:** GoRouter (Dikonfigurasi untuk kompatibilitas SPA / Single Page Application)
- **Backend & Database:** [Supabase](https://supabase.com/) (PostgreSQL, Auth, Storage)
- **Map Engine:** `flutter_map` & `latlong2`

---

## 🚀 Panduan Instalasi Lokal

1. **Clone repositori ini:**
   ```bash
   git clone https://github.com/username/manisharjo-smart-address.git
   cd manisharjo-smart-address
   ```

2. **Install Dependensi:**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Konfigurasi Environment (Supabase):**
   Buat file bernama `.env` di *root* proyek (sejajar dengan `pubspec.yaml`), dan isi dengan kredensial Supabase Anda:
   ```env
   SUPABASE_URL=https://xxxxxxxxxxxxxxxx.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

4. **Jalankan Aplikasi:**
   ```bash
   flutter run -d chrome
   ```

---

## 🌐 Panduan Deployment (Vercel / Firebase Hosting)

Aplikasi ini sangat siap untuk *production deployment*. Flutter Web akan dikompilasi menjadi Single Page Application (SPA).

### Langkah Build Production:
1. Pastikan Anda telah menaruh konfigurasi `.env` Anda dengan benar.
2. Jalankan perintah kompilasi:
   ```bash
   flutter build web --release
   ```
   *(Secara default, Flutter menggunakan CanvasKit untuk performa rendering UI maksimal).*

### Setup Routing SPA (Khusus Vercel):
Karena aplikasi ini menggunakan `GoRouter` tanpa hash (URL bersih seperti `/admin` atau `/house/M-001`), server hosting harus diatur agar me-*redirect* semua rute kembali ke `index.html`.

Jika Anda mendeploy menggunakan **Vercel**, buat file `vercel.json` di dalam root project:
```json
{
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```
Atau Anda bisa memastikan file tersebut disertakan saat meng-upload folder `build/web` ke Vercel.

---

## 🔒 Skema Keamanan & Optimasi
- **RLS (Row Level Security):** Data `houses` dan `village_maps` di Supabase dapat dibaca publik (SELECT), namun hanya `Authenticated User` yang dapat mengubah, menambah, atau menghapus data.
- **Client Caching:** Data diunduh dan disimpan di Provider `HouseRepository` untuk meminimalisasi query berulang ke database Supabase, mempercepat navigasi instan aplikasi < 1 detik.
- **Client-side Compression:** Gambar denah desa dikompresi di sisi browser sebelum diunggah ke *Supabase Storage* untuk efisiensi *bandwidth*.

---
*Didesain dan dikembangkan khusus untuk modernisasi layanan informasi kependudukan dan pemetaan.* 🚀