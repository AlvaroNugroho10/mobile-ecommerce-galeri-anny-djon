# Activity Diagram — Mermaid Code (8 Diagram)

Cara pakai:
- **Mermaid Live**: https://mermaid.live → paste kode di editor
- **draw.io**: Extras → Edit Diagram → pilih format Mermaid → paste kode

---

## 1. Activity Diagram Login

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (User)"]
        A1["Membuka Halaman Login"]
        A2["Input Email dan Password"]
        A3["Klik Tombol Login"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Halaman Login"]
        B2{"Data Valid?"}
        B3["Menampilkan Homepage"]
        B4["Notifikasi Login Gagal"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> A3
    A3 --> B2
    B2 -->|Ya| B3
    B3 --> E(([⊙]))
    B2 -->|Tidak| B4
    B4 --> A2
```

---

## 2. Activity Diagram Register

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (User)"]
        A1["Membuka Halaman Sign Up"]
        A2["Input Email, Password,\ndan Confirm Password"]
        A3["Klik Tombol Sign Up"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Halaman Sign Up"]
        B2{"Data Valid?"}
        B3["Menyimpan Akun dan\nMenampilkan Homepage"]
        B4["Notifikasi Registrasi Gagal"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> A3
    A3 --> B2
    B2 -->|Ya| B3
    B3 --> E(([⊙]))
    B2 -->|Tidak| B4
    B4 --> A2
```

---

## 3. Activity Diagram Pemesanan Produk

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (User)"]
        A1["Membuka Halaman Produk"]
        A2["Memilih Produk"]
        A3["Klik Tombol Tambah ke Keranjang"]
        A4["Klik Tombol Checkout"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Daftar Produk"]
        B2["Menampilkan Detail Produk"]
        B3["Menyimpan Produk ke Keranjang"]
        B4{"Produk Berhasil\nDitambahkan?"}
        B5["Notifikasi Gagal\nMenambahkan Produk"]
        B6["Menampilkan Halaman Checkout"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> B2
    B2 --> A3
    A3 --> B3
    B3 --> B4
    B4 -->|Ya| A4
    A4 --> B6
    B6 --> E1(([⊙]))
    B4 -->|Tidak| B5
    B5 --> E2(([⊙]))
```

---

## 4. Activity Diagram Melakukan Pembayaran

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (User)"]
        A1["Membuka Halaman Checkout"]
        A2["Mengisi Data Pengiriman"]
        A3["Klik Tombol Bayar Sekarang"]
        A4["Melakukan Pembayaran"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Halaman Checkout"]
        B2["Memvalidasi Data Pengiriman"]
        B3{"Data Lengkap?"}
        B4["Menampilkan Pesan Error Data"]
        B5["Membuka WebView Midtrans"]
        B6["Memvalidasi Pembayaran"]
        B7{"Pembayaran Berhasil?"}
        B8["Menyimpan Data Pesanan"]
        B9["Menampilkan Halaman\nPembayaran Berhasil"]
        B10["Menampilkan Pesan\nPembayaran Gagal"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> A3
    A3 --> B2
    B2 --> B3
    B3 -->|Tidak| B4
    B4 --> A2
    B3 -->|Ya| B5
    B5 --> A4
    A4 --> B6
    B6 --> B7
    B7 -->|Ya| B8
    B8 --> B9
    B9 --> E1(([⊙]))
    B7 -->|Tidak| B10
    B10 --> E2(([⊙]))
```

---

## 5. Activity Diagram Riwayat Pesanan

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (User)"]
        A1["Membuka Menu Riwayat Pesanan"]
        A2["Memilih Riwayat Pesanan"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Halaman Riwayat"]
        B2["Mengambil Data Riwayat Pesanan"]
        B3{"Data Tersedia?"}
        B4["Menampilkan Riwayat Pesanan"]
        B5["Menampilkan Pesan Data Kosong"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> B2
    B2 --> B3
    B3 -->|Ya| B4
    B4 --> E1(([⊙]))
    B3 -->|Tidak| B5
    B5 --> E2(([⊙]))
```

---

## 6. Activity Diagram Mengelola Produk

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (Admin)"]
        A1["Membuka Menu Produk"]
        A2["Memilih Tambah, Edit,\natau Hapus Produk"]
        A3["Menginput Data Produk"]
        A4["Klik Tombol Simpan"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Daftar Produk"]
        B2["Menampilkan Form Produk"]
        B3["Validasi Data Produk"]
        B4{"Data Valid?"}
        B5["Menyimpan Perubahan Produk"]
        B6["Menampilkan Pesan Error"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> B2
    B2 --> A3
    A3 --> A4
    A4 --> B3
    B3 --> B4
    B4 -->|Ya| B5
    B5 --> E(([⊙]))
    B4 -->|Tidak| B6
    B6 --> A3
```

---

## 7. Activity Diagram Mengelola Pesanan

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (Admin)"]
        A1["Membuka Menu Pesanan"]
        A2["Memilih Pesanan"]
        A3["Mengubah Status Pesanan"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Daftar Pesanan"]
        B2["Menampilkan Detail Pesanan"]
        B3["Validasi Perubahan Status"]
        B4{"Status Valid?"}
        B5["Menyimpan Status Pesanan"]
        B6["Menampilkan Notifikasi\nStatus Berhasil Diupdate"]
        B7["Menampilkan Pesan Error"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> B2
    B2 --> A3
    A3 --> B3
    B3 --> B4
    B4 -->|Ya| B5
    B5 --> B6
    B6 --> E(([⊙]))
    B4 -->|Tidak| B7
    B7 --> A3
```

---

## 8. Activity Diagram Mengelola User

```mermaid
flowchart TD
    S([ ]) --> A1

    subgraph Aktor ["Aktor (Admin)"]
        A1["Membuka Menu User"]
        A2["Memilih Hapus User\natau Mengganti Role"]
        A3["Mengkonfirmasi Aksi"]
    end

    subgraph Sistem ["Sistem"]
        B1["Menampilkan Daftar User"]
        B2["Menampilkan Konfirmasi Aksi"]
        B3["Memproses Perubahan Data User"]
        B4{"Aksi Berhasil?"}
        B5["Menampilkan Notifikasi Berhasil"]
        B6["Tampilan Data User Berubah"]
        B7["Menampilkan Pesan Error"]
    end

    A1 --> B1
    B1 --> A2
    A2 --> B2
    B2 --> A3
    A3 --> B3
    B3 --> B4
    B4 -->|Ya| B5
    B5 --> B6
    B6 --> E(([⊙]))
    B4 -->|Tidak| B7
    B7 --> A2
```
