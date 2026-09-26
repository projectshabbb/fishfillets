# Fish Fillets - SAB Group

Aplikasi kas, stok, opname, dan nota untuk usaha ikan frozen. Dibangun sebagai
satu halaman statis (`index.html`) dengan [Supabase](https://supabase.com)
sebagai database + login.

## Isi folder

```
├── index.html          <- seluruh aplikasi (HTML+CSS+JS jadi satu file)
├── assets/logo.png      <- logo brand
├── supabase/schema.sql  <- skema database, tinggal dijalankan di Supabase
└── README.md
```

## 1. Buat project Supabase

1. Daftar/masuk di [supabase.com](https://supabase.com) → **New project**.
2. Tunggu sampai project selesai dibuat (±2 menit).
3. Buka menu **SQL Editor** → **New query**, tempel seluruh isi file
   `supabase/schema.sql`, lalu klik **Run**. Ini akan membuat semua tabel
   (produk, transaksi, kas, opname, profil) beserta aturan keamanannya.
4. Buka **Authentication → Users → Invite user**, undang email kamu sendiri
   dulu sebagai pemilik akun.
5. Jalankan query berikut di SQL Editor (ganti emailnya) supaya akun kamu
   berstatus **owner**, bukan admin biasa:
   ```sql
   update public.profiles set role = 'owner'
   where id = (select id from auth.users where email = 'email-kamu@contoh.com');
   ```
6. Undang 4 admin lainnya dengan cara yang sama (**Invite user**). Mereka akan
   menerima email berisi link untuk membuat password sendiri — kamu tidak
   pernah tahu atau mengatur password mereka.
7. Buka **Project Settings → API**, salin dua nilai ini:
   - **Project URL**
   - **anon public key**

## 2. Isi kunci Supabase ke aplikasi

Buka `index.html`, cari baris berikut di dekat akhir file lalu ganti dengan
nilai dari langkah di atas:

```js
const SUPABASE_URL = "https://YOUR-PROJECT-REF.supabase.co";
const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
```

> Aman menaruh `anon key` langsung di kode sisi klien seperti ini — kunci ini
> memang didesain publik, keamanan datanya diatur lewat Row Level Security
> yang sudah dibuat di `schema.sql`.

## 3. Upload ke GitHub

1. Buka [github.com/new](https://github.com/new), buat repository baru
   (mis. `fish-fillets-app`), biarkan kosong (jangan centang "add README").
2. Di halaman repo yang baru dibuat, klik **uploading an existing file**,
   drag & drop semua isi folder ini (`index.html`, folder `assets`, folder
   `supabase`, `README.md`), lalu **Commit changes**.
   
   *(Alternatif lewat terminal kalau familiar dengan git:)*
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git branch -M main
   git remote add origin https://github.com/USERNAME/fish-fillets-app.git
   git push -u origin main
   ```

## 4. Deploy ke Vercel

1. Buka [vercel.com/new](https://vercel.com/new), masuk pakai akun GitHub.
2. Pilih repo `fish-fillets-app` yang baru diupload → **Import**.
3. Karena ini situs statis biasa, biarkan semua pengaturan default (Framework
   Preset: **Other**) → klik **Deploy**.
4. Setelah selesai (±30 detik), Vercel memberi URL live, misalnya
   `fish-fillets-app.vercel.app`. Setiap kali kamu update file di GitHub,
   Vercel otomatis deploy ulang.

## 5. Selesai — login

Buka URL Vercel kamu, login pakai email yang sudah diundang di langkah 1.
Owner (kamu) bisa hapus produk, admin biasa tidak bisa — pengaturan ini ada
di `supabase/schema.sql` bagian `products_delete_owner_only`.

## Menambah/menghapus admin nanti

Cukup lewat dashboard Supabase, tanpa ubah kode:
- **Tambah admin**: Authentication → Users → Invite user.
- **Hapus akses admin**: Authentication → Users → pilih user → Delete user.
- **Jadikan admin jadi owner**: jalankan query update role seperti langkah 1.5
  di atas dengan email admin tersebut.
