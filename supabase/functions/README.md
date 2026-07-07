# Deploy Edge Function: Create User

## 📋 Prerequisites

1. **Deno** terinstall di komputer
2. **Supabase CLI** terinstall
3. Project sudah di-link ke Supabase

## 🚀 Cara Deploy

### Option 1: Deploy via Supabase CLI (Rekomendasi)

```bash
# 1. Masuk ke folder project
cd "C:/MATKUL/SEMESTER-4/Mobile Praktikum/434241056_Muhammad Raka Razzani_B2_UTS"

# 2. Link ke Supabase (kalau belum)
supabase link --project-ref cvmzoczzdqpiucpedghp

# 3. Deploy function
supabase functions deploy create-user
```

### Option 2: Deploy via Supabase Dashboard

1. Buka **Supabase Dashboard**
2. Pilih project **TendriZ**
3. Masuk ke **Edge Functions**
4. Klik **"New Function"**
5. Name: `create-user`
6. Copy-paste isi dari `supabase/functions/create-user/index.ts`
7. Klik **"Save"** lalu **"Deploy"**

## ✅ Verifikasi Deploy

Setelah deploy, test di terminal:

```bash
# Test function
curl -X POST 'https://cvmzoczzdqpiucpedghp.supabase.co/functions/v1/create-user' \
  -H 'Content-Type: application/json' \
  -H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2bXpvY3p6ZHFpaXVjcGVkZ2hwIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3NjA1ODI5MSwiZXhwIjoyMDkxNjM0MjkxfQ.ayR9pnJRy1vOBK3MiOMjhRwHQZHD70pn4Sq87fsKC50' \
  -d '{
    "name": "Test User",
    "username": "testuser001",
    "password": "Test123!",
    "role": "user"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "User created successfully",
  "user": {
    "id": "...",
    "email": "testuser001@helpdesk.com",
    "name": "Test User",
    "username": "testuser001",
    "role": "user"
  }
}
```

## 🎯 Setelah Deploy

1. **Rebuild Flutter app**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Test sebagai Admin**
   - Login sebagai admin
   - Masuk ke Manajemen Pengguna
   - Tambah user baru
   - ✅ Admin TETAP login sebagai admin (tidak berubah jadi user baru)

## 🔧 Troubleshooting

### Error: "Function not found"
- Pastikan nama function `create-user` sesuai dengan yang di-deploy
- Cek di Supabase Dashboard → Edge Functions

### Error: "Permission denied"
- Pastikan menggunakan API key yang benar
- Edge functions by default bisa diakses dengan anon key

### Error: "Failed to create user"
- Cek log di Supabase Dashboard → Edge Functions → Logs
- Pastikan service role environment variables tersedia

## 📝 Notes

- Edge Function menggunakan **Service Role Key** secara otomatis
- Service role bypass RLS policies
- Admin session TIDAK terpengaruh saat create user baru
- Setiap user baru otomatis email-confirmed

---

*Created for E-Ticketing Helpdesk Project*
*Universitas Airlangga - 2026*
