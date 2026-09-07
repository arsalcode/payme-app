# 📋 PLAN PROJECT: PAYME FINTECH & E-WALLET

Dokumen ini berisi rencana pengembangan menyeluruh (*end-to-end roadmap*) untuk menyempurnakan aplikasi **Payme** menjadi proyek portofolio kelas industri (*production-ready*) yang siap dipresentasikan kepada recruiter, klien, atau perusahaan teknologi.

---

## 🎯 Tujuan Akhir Proyek
1. **Fungsional Nyata**: Mengubah aplikasi dari status *mockup/dummy UI* menjadi sistem finansial yang terhubung ke database cloud (**Supabase**).
2. **Kredibilitas Portofolio**: Memiliki arsitektur bersih (*Clean Architecture* + *BLoC Pattern*), keamanan data (KYC & PIN), serta penanganan transaksi uang secara dinamis.
3. **Multi-Platform Showcase**:
   - **Aplikasi Mobile (Android/iOS)**: Aplikasi utama pengguna.
   - **Live Web Demo**: Akses demo langsung di browser tanpa perlu mengunduh file `.apk`.
   - **Web Admin Dashboard**: Panel operasional back-office untuk verifikasi KTP/KYC dan audit transaksi keuangan.

---

## 🗺️ Roadmap Pengembangan (Fase 1 s/d Fase 5)

```
[ FASE 1: Quick Fixes & Code Cleanup ]
       │
       ▼
[ FASE 2: Backend Setup & Real Authentication ]
       │
       ▼
[ FASE 3: Dynamic Wallet & Transaction Engine ]
       │
       ▼
[ FASE 4: Sisi Web (Live Demo & Back-Office Admin) ]
       │
       ▼
[ FASE 5: Packaging Portofolio & Showcasing ]
```

---

### 🟢 FASE 1: Pembersihan Kode & Perbaikan Bug Kritis (Foundation)
Fokus pada merapikan kodingan yang sudah ada agar tidak ada error logika dasar.

- [ ] **1.1 Perbaikan Bug Validasi PIN**:
  - Memperbaiki pengecekan panjang PIN di `sign_up_set_profile_page.dart` dari `pinController.text != 6` menjadi `pinController.text.length != 6`.
- [ ] **1.2 Dinamisasi Otentikasi PIN**:
  - Mengubah validasi PIN hardcoded `'123123'` di `pin_page.dart` agar mencocokkan PIN asli pengguna.
- [ ] **1.3 Perbaikan Typo Penamaan File & Teks UI**:
  - Mengoreksi teks seperti `WithRow` ➔ `Withdraw`, `Lates Tranction` ➔ `Latest Transactions`.
  - Mengaktifkan kembali helper fungsi di `shared_methods.dart` (seperti `formatCurrency` dan `showCustomSnackbar`).
- [ ] **1.4 Instalasi Dependency Supabase**:
  - Menambahkan package `supabase_flutter` ke `pubspec.yaml`.

---

### 🔵 FASE 2: Backend Cloud & Autentikasi Nyata (Supabase Integration)
Fokus pada integrasi database PostgreSQL dan sistem login/register nyata.

- [ ] **2.1 Setup Database Supabase**:
  - Membuat tabel `users` (id, name, email, username, pin, profile_image, ktp_image, is_verified, created_at).
  - Membuat tabel `wallets` (id, user_id, card_number, balance).
  - Membuat tabel `transactions` (id, user_id, transaction_type, title, amount, status, created_at).
  - Membuat Storage Bucket di Supabase untuk `avatars` (foto profil) dan `documents` (foto KTP).
- [ ] **2.2 Inisialisasi Supabase di Flutter**:
  - Menghubungkan `Project URL` dan `anon key` di `main.dart`.
- [ ] **2.3 Alur Autentikasi & Registrasi Penuh**:
  - Implementasi pendaftaran akun asli (Supabase Auth).
  - Upload otomatis foto profil dan foto KTP ke Supabase Storage.
  - Penyimpanan sesi login (Local Session Persistence) sehingga user tidak logout saat aplikasi ditutup.
- [ ] **2.4 Alur Sign In & Sign Out**:
  - Pengguna bisa login menggunakan email & password yang sudah terdaftar.

---

### 🟡 FASE 3: Sistem Saldo & Mesin Transaksi Dinamis
Fokus membuat saldo dompet dan mutasi keuangan benar-benar hidup.

- [ ] **3.1 Arsitektur State Management Transaksi**:
  - Membuat `WalletBloc` / `TransactionBloc` untuk mengelola saldo dan daftar riwayat mutasi.
- [ ] **3.2 Fitur Top Up Dinamis**:
  - Saldo di Virtual Card otomatis bertambah secara real-time setelah proses top up sukses.
  - Item mutasi "Top Up" otomatis masuk ke daftar *Latest Transactions*.
- [ ] **3.3 Fitur Transfer Uang Antar Pengguna**:
  - Pencarian pengguna penerima berdasarkan username asli di database.
  - Saldo pengirim berkurang dan saldo penerima bertambah.
  - Validasi proteksi PIN 6 digit sebelum pemotongan saldo.
- [ ] **3.4 Pembelian Layanan (Paket Data)**:
  - Saldo berkurang sesuai nominal paket data yang dibeli.
  - Tercatat di riwayat mutasi sebagai transaksi pengeluaran.

---

### 🟣 FASE 4: Sisi Web (Live Demo & Admin Dashboard)
Fokus menyediakan platform web untuk melengkapi portofolio.

- [ ] **4.1 Web Admin Back-Office (Review KYC & Audit Transaksi)**:
  - Halaman web khusus admin untuk melihat data user yang mendaftar.
  - Fitur peninjauan foto KTP dengan tombol aksi **[Approve]** atau **[Reject]**.
  - Jika di-approve, status verifikasi di aplikasi mobile berubah menjadi *Verified* (muncul centang hijau).
  - Tabel audit seluruh transaksi real-time.
- [ ] **4.2 Build & Deploy Flutter Web (Showcase Preview)**:
  - Mengonfigurasi build web Flutter agar bisa diakses langsung via URL browser.
  - Menempatkan tampilan aplikasi di dalam frame mockup smartphone agar interaktif bagi siapa pun yang membukanya di laptop/PC.

---

### 🔴 FASE 5: Pengemasan Portofolio & Publikasi Industri
Fokus menyiapkan aset presentasi agar dilirik recruiter & koneksi profesional.

- [ ] **5.1 Dokumentasi Repositori GitHub**:
  - Membuat `README.md` berstandar profesional:
    - Deskripsi & Arsitektur sistem (Mermaid Diagram).
    - Cuplikan GIF demo animasi fitur utama.
    - Tech stack badges & instruksi instalasi.
    - Tautan ke Live Demo Web & Video Demo.
- [ ] **5.2 Video Demo Showcase**:
  - Merekam screen recording alur lengkap (Registrasi KYC -> Top Up -> Transfer -> Web Admin Approval).
- [ ] **5.3 Materi Unggahan LinkedIn / CV**:
  - Menyiapkan rangkuman postingan LinkedIn yang menjelaskan masalah yang diselesaikan, teknologi yang dipakai, dan link demo proyek.

---

## 📊 Matriks Status Pelaksanaan Proyek

| Modul / Fitur | Status | Target Penyelesaian |
| :--- | :---: | :---: |
| UI Design & Layout Screens | Selesai (95%) | Selesai |
| Pembersihan Bug & Validasi PIN | Belum | Fase 1 |
| Setup Cloud Database Supabase | Belum | Fase 2 |
| Real Auth & Storage KYC KTP | Belum | Fase 2 |
| Saldo & Mutasi Transaksi Dinamis | Belum | Fase 3 |
| Web Admin KYC & Audit | Belum | Fase 4 |
| Live Web Demo Hosting | Belum | Fase 4 |
| Dokumentasi Portofolio README | Belum | Fase 5 |
