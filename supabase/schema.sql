-- ============================================================
-- Fish Fillets - SAB Group — Skema Database Supabase
-- Jalankan seluruh file ini di: Supabase Dashboard > SQL Editor > New query
-- ============================================================

-- ---------- PROFIL USER (role: owner / admin) ----------
create table public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  full_name text,
  role text not null default 'admin' check (role in ('owner','admin')),
  created_at timestamptz not null default now()
);

-- Otomatis buat baris profil setiap ada user baru daftar/diundang
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', new.email), 'admin');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ---------- PRODUK ----------
create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'fillet',
  unit text not null default 'kg',
  price numeric not null default 0,
  stock numeric not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- TRANSAKSI PENJUALAN (untuk nota) ----------
create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null default now(),
  buyer_name text not null,
  buyer_phone text not null,
  payment text not null check (payment in ('cash','transfer')),
  items jsonb not null,
  subtotal numeric not null default 0,
  discount numeric not null default 0,
  shipping numeric not null default 0,
  total numeric not null default 0,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ---------- KAS (pemasukan / pengeluaran, per bulan via kolom date) ----------
create table public.cashflow (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null default now(),
  type text not null check (type in ('in','out')),
  description text not null,
  amount numeric not null,
  payment text not null check (payment in ('cash','transfer')),
  source text not null default 'manual' check (source in ('manual','transaction')),
  ref uuid,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ---------- STOCK OPNAME ----------
create table public.opname (
  id uuid primary key default gen_random_uuid(),
  date timestamptz not null default now(),
  note text,
  items jsonb not null,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

-- ============================================================
-- ROW LEVEL SECURITY — semua tabel hanya bisa diakses user yang login
-- ============================================================
alter table public.profiles enable row level security;
alter table public.products enable row level security;
alter table public.transactions enable row level security;
alter table public.cashflow enable row level security;
alter table public.opname enable row level security;

-- profiles: setiap user boleh lihat semua profil (untuk badge nama/role),
-- tapi hanya boleh mengubah profilnya sendiri
create policy "profiles_select_all_authenticated" on public.profiles
  for select using (auth.role() = 'authenticated');
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

-- products: semua yang login boleh lihat & tambah/ubah, hapus hanya owner
create policy "products_select" on public.products
  for select using (auth.role() = 'authenticated');
create policy "products_insert" on public.products
  for insert with check (auth.role() = 'authenticated');
create policy "products_update" on public.products
  for update using (auth.role() = 'authenticated');
create policy "products_delete_owner_only" on public.products
  for delete using (exists (select 1 from public.profiles where id = auth.uid() and role = 'owner'));

-- transactions: semua yang login boleh lihat & tambah (tidak ada edit/hapus dari UI)
create policy "transactions_select" on public.transactions
  for select using (auth.role() = 'authenticated');
create policy "transactions_insert" on public.transactions
  for insert with check (auth.role() = 'authenticated');

-- cashflow: sama seperti transactions
create policy "cashflow_select" on public.cashflow
  for select using (auth.role() = 'authenticated');
create policy "cashflow_insert" on public.cashflow
  for insert with check (auth.role() = 'authenticated');

-- opname: sama seperti transactions
create policy "opname_select" on public.opname
  for select using (auth.role() = 'authenticated');
create policy "opname_insert" on public.opname
  for insert with check (auth.role() = 'authenticated');

-- ============================================================
-- Setelah menjalankan file ini:
-- 1. Buka Authentication > Users > Invite user, undang email owner dulu.
-- 2. Jalankan query di bawah (ganti email) untuk menjadikan akun itu 'owner':
--
--    update public.profiles set role = 'owner'
--    where id = (select id from auth.users where email = 'email-owner@contoh.com');
--
-- 3. Undang 4 admin lainnya dengan cara yang sama (Invite user) —
--    mereka otomatis dapat role 'admin' dan bikin password sendiri
--    lewat link di email undangan.
-- ============================================================
