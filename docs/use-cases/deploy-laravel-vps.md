# Deploy Laravel ke VPS

Panduan lengkap untuk deploy aplikasi Laravel ke VPS Ubuntu 22.04.

## Ringkasan

Panduan ini akan memandu Anda untuk deploy aplikasi Laravel ke VPS menggunakan Ansible. Deployment mencakup:

- Server web Nginx
- PHP 8.2 dengan semua ekstensi yang dibutuhkan
- Database MySQL
- SSL/TLS via Let's Encrypt
- Konfigurasi firewall
- Supervisor untuk queue workers

## Arsitektur

```
┌─────────────────┐
│  User/Browser   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      Nginx      │ ← Terminasi SSL
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    PHP 8.2      │ ← Aplikasi Laravel
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     MySQL       │ ← Database
└─────────────────┘
```

## Kebutuhan

### Kebutuhan Server

- **OS**: Ubuntu 22.04 LTS
- **RAM**: Minimal 1GB (2GB direkomendasikan)
- **Penyimpanan**: Minimal 20GB
- **Akses**: SSH dengan hak sudo

### Kebutuhan Lokal

- **Git**: Untuk clone repository
- **Ansible**: 2.9+ (untuk menjalankan playbook)
- **SSH Key**: Untuk koneksi ke server

### Kebutuhan Aplikasi

- **Laravel**: 8.x atau lebih baru
- **Ekstensi PHP**: mbstring, xml, curl, zip, gd, bcmath, intl
- **Database**: MySQL 8.0

## Instalasi

### Langkah 1: Clone Repository

```bash
git clone https://github.com/ujgsp/OpenOpsToolkit.git
cd OpenOpsToolkit
```

### Langkah 2: Konfigurasi Inventory

Edit `ansible/inventories/production/hosts.yml`:

```yaml
webservers:
  hosts:
    web1:
      ansible_host: IP_SERVER_ANDA
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Langkah 3: Konfigurasi Aplikasi

Edit `ansible/inventories/production/group_vars/all.yml`:

```yaml
# Aplikasi
app_name: myapp
app_env: production
app_url: https://domainanda.com
app_domain: domainanda.com

# Database
db_name: laravel_db
db_user: laravel
db_password: password_anda_yang_aman

# SSL
ssl_enabled: true
ssl_email: email@anda.com
```

### Langkah 4: Deploy

```bash
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml
```

### Langkah 5: Verifikasi Deployment

```bash
# Cek layanan
ssh ubuntu@IP_SERVER_ANDA "systemctl status nginx"
ssh ubuntu@IP_SERVER_ANDA "systemctl status php8.2-fpm"
ssh ubuntu@IP_SERVER_ANDA "systemctl status mysql"

# Tes HTTP response
curl -I http://IP_SERVER_ANDA

# Tes HTTPS (jika SSL diaktifkan)
curl -I https://domainanda.com
```

## Checklist Verifikasi

Setelah deployment, verifikasi:

- [ ] Nginx berjalan dan menyajikan konten
- [ ] PHP-FPM memproses file PHP
- [ ] MySQL menerima koneksi
- [ ] Aplikasi dapat diakses via HTTP
- [ ] Sertifikat SSL valid (jika diaktifkan)
- [ ] Firewall mengizinkan port 22, 80, 443
- [ ] Direktori storage dapat ditulis
- [ ] Queue workers berjalan (jika dikonfigurasi)

## Pemecahan Masalah

### Masalah: 502 Bad Gateway

**Gejala**: Browser menampilkan "502 Bad Gateway"

**Penyebab**: PHP-FPM tidak berjalan atau tidak dikonfigurasi dengan benar

**Solusi**:

```bash
# Cek status PHP-FPM
ssh ubuntu@IP_SERVER_ANDA "systemctl status php8.2-fpm"

# Cek log PHP-FPM
ssh ubuntu@IP_SERVER_ANDA "tail -f /var/log/php8.2-fpm.log"

# Restart PHP-FPM
ssh ubuntu@IP_SERVER_ANDA "sudo systemctl restart php8.2-fpm"
```

### Masalah: Koneksi Database Ditolak

**Gejala**: Laravel menampilkan error "Connection refused"

**Penyebab**: MySQL tidak berjalan atau kredensial salah

**Solusi**:

```bash
# Cek status MySQL
ssh ubuntu@IP_SERVER_ANDA "systemctl status mysql"

# Cek log MySQL
ssh ubuntu@IP_SERVER_ANDA "tail -f /var/log/mysql/error.log"

# Verifikasi kredensial
ssh ubuntu@IP_SERVER_ANDA "mysql -u laravel -p -e 'SHOW DATABASES;'"
```

### Masalah: Permission Ditolak

**Gejala**: Laravel menampilkan error permission di storage/logs

**Penyebab**: Permission file salah

**Solusi**:

```bash
# Perbaiki permission storage
ssh ubuntu@IP_SERVER_ANDA "sudo chown -R www-data:www-data /var/www/myapp/storage"
ssh ubuntu@IP_SERVER_ANDA "sudo chmod -R 775 /var/www/myapp/storage"

# Perbaiki permission bootstrap/cache
ssh ubuntu@IP_SERVER_ANDA "sudo chown -R www-data:www-data /var/www/myapp/bootstrap/cache"
ssh ubuntu@IP_SERVER_ANDA "sudo chmod -R 775 /var/www/myapp/bootstrap/cache"
```

### Masalah: Sertifikat SSL Tidak Berfungsi

**Gejala**: Browser menampilkan "Not Secure" atau error sertifikat

**Penyebab**: Sertifikat Let's Encrypt belum diterbitkan atau sudah kedaluwarsa

**Solusi**:

```bash
# Cek status sertifikat
ssh ubuntu@IP_SERVER_ANDA "sudo certbot certificates"

# Perbarui sertifikat
ssh ubuntu@IP_SERVER_ANDA "sudo certbot renew"

# Cek konfigurasi SSL Nginx
ssh ubuntu@IP_SERVER_ANDA "sudo nginx -t"
```

## Catatan Keamanan

### Firewall

Deployment mengkonfigurasi UFW dengan:

- Port 22 (SSH) - Terbuka
- Port 80 (HTTP) - Terbuka
- Port 443 (HTTPS) - Terbuka
- Semua port lainnya - Tertutup

### SSL/TLS

- Menggunakan Let's Encrypt untuk sertifikat SSL gratis
- Perpanjangan otomatis dikonfigurasi via cron
- Header HSTS diaktifkan

### Permission File

- File aplikasi dimiliki oleh www-data
- Direktori storage dapat ditulis oleh web server
- File sensitif tidak dapat diakses via web

### Database

- Password root MySQL diamankan
- Pengguna aplikasi memiliki hak terbatas
- Akses remote dinonaktifkan secara default

## Pemeliharaan

### Tugas Rutin

1. **Update paket**: `sudo apt update && sudo apt upgrade`
2. **Cek log**: `tail -f /var/log/nginx/error.log`
3. **Monitor ruang disk**: `df -h`
4. **Backup database**: `mysqldump -u root -p laravel_db > backup.sql`

### Strategi Backup

```bash
# Backup database
mysqldump -u root -p laravel_db > backup_$(date +%Y%m%d).sql

# Backup file aplikasi
tar -czf app_backup_$(date +%Y%m%d).tar.gz /var/www/myapp

# Backup ke lokasi remote
rsync -avz /var/www/myapp user@backup-server:/backups/
```

## Sumber Daya

- [Dokumentasi Laravel](https://laravel.com/docs)
- [Dokumentasi Nginx](https://nginx.org/en/docs/)
- [Dokumentasi PHP](https://www.php.net/docs.php)
- [Dokumentasi MySQL](https://dev.mysql.com/doc/)
- [Dokumentasi Let's Encrypt](https://letsencrypt.org/docs/)