CARA MENGGUNAKAN LAPORAN UTS
=============================

1. FILE YANG TERSEDIA:
   - LAPORAN_UTS_TEORI.md    : Laporan lengkap dalam format Markdown
   - README_LAPORAN.txt      : File ini (instruksi)

2. CARA KONVERSI KE WORD/PDF:

   Opsi A: Menggunakan Online Converter (Direkomendasikan)
   ------------------------------------------------------
   1. Buka browser dan akses: https://pandoc.org/try/
      atau https://www.vertopal.com/convert/md-to-docx
   2. Copy isi file LAPORAN_UTS_TEORI.md
   3. Paste ke converter
   4. Download hasil konversi (.docx atau .pdf)
   5. Edit formatting jika diperlukan di Microsoft Word

   Opsi B: Menggunakan VS Code
   ---------------------------
   1. Install ekstensi "Markdown PDF" atau "Markdown to Word"
   2. Buka file .md
   3. Klik kanan → Export to PDF/Word

   Opsi C: Menggunakan Pandoc (Command Line)
   ------------------------------------------
   1. Install Pandoc dari: https://pandoc.org/installing.html
   2. Buka terminal di folder laporan_uts
   3. Jalankan command:
      pandoc LAPORAN_UTS_TEORI.md -o LAPORAN_UTS.docx
   4. Atau untuk PDF:
      pandoc LAPORAN_UTS_TEORI.md -o LAPORAN_UTS.pdf --pdf-engine=xelatex

3. STRUKTUR LAPORAN:
   - Cover (Nama, NIM, Kelas, Matkul)
   - Daftar Isi
   - Bab 1: Pendahuluan
   - Bab 2: Deskripsi Proyek
   - Bab 3: Palet Warna
   - Bab 4: Tipografi dan Font
   - Bab 5: Wireframe Desain
   - Bab 6: Prototipe Desain
   - Bab 7: Arsitektur Aplikasi
   - Bab 8: Fitur dan Fungsionalitas
   - Bab 9: Kesimpulan
   - Daftar Pustaka

4. CHECKLIST SEBELUM UPLOAD KE E-LEARNING:
   [ ] Nama dan NIM sudah benar di cover
   [ ] Format sudah .docx, .pdf, atau sesuai ketentuan
   [ ] Semua bab lengkap
   [ ] Gambar/screenshot ditambahkan jika diperlukan
   [ ] File berhasil dibuka tanpa error

5. CATATAN TAMBAHAN:
   - Laporan ini mencakup detail lengkap projek E-Ticketing Helpdesk
   - Semua kode warna sudah dalam format Hex untuk referensi desain
   - Wireframe disertakan dalam format ASCII untuk kejelasan
   - Arsitektur dijelaskan dengan diagram dan penjelasan

Selamat mengerjakan!
