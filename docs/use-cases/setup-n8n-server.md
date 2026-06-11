# Setup Server n8n

Panduan lengkap untuk deploy server workflow automation n8n.

## Ringkasan

Panduan ini akan memandu Anda untuk deploy n8n, tool otomasi workflow visual. n8n memungkinkan Anda untuk:

- Mengotomatiskan tugas operasional
- Menghubungkan layanan berbeda
- Membuat workflow visual
- Menerima dan mengirim webhook

## Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                      Server n8n                              │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │     n8n     │  │  PostgreSQL │  │    Nginx    │        │
│  │   :5678     │  │   :5432     │  │   :80/443   │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                 │                │
│         └────────────────┼─────────────────┘                │
│                          │                                  │
│                   ┌──────┴──────┐                          │
│                   │   Docker    │                          │
│                   └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Kebutuhan

### Kebutuhan Server

- **OS**: Ubuntu 22.04 LTS
- **RAM**: Minimal 2GB (4GB direkomendasikan)
- **Penyimpanan**: Minimal 30GB
- **Akses**: SSH dengan hak sudo

### Kebutuhan Perangkat Lunak

- **Docker**: 20.10+
- **Docker Compose**: 2.0+

## Instalasi

### Langkah 1: Install Docker (jika belum terinstall)

```bash
# Menggunakan Ansible role
ansible-playbook -i inventories/production roles/docker/tasks/main.yml

# Atau secara manual
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
```

### Langkah 2: Konfigurasi Inventory

Edit `inventories/production/inventory.yml`:

```yaml
n8n_servers:
  hosts:
    n8n1:
      ansible_host: IP_SERVER_ANDA
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Langkah 3: Konfigurasi Variabel

Edit `inventories/production/group_vars/n8n_servers.yml`:

```yaml
n8n_domain: n8n.domainanda.com
n8n_basic_auth_user: admin
n8n_basic_auth_password: password_anda_yang_aman
n8n_ssl_enabled: true
n8n_ssl_email: email@anda.com
```

### Langkah 4: Deploy

```bash
ansible-playbook -i inventories/production roles/n8n/tasks/main.yml
```

### Langkah 5: Verifikasi Deployment

```bash
# Cek apakah n8n berjalan
ssh ubuntu@IP_SERVER_ANDA "docker ps | grep n8n"

# Cek log n8n
ssh ubuntu@IP_SERVER_ANDA "docker logs n8n"

# Tes HTTP response
curl -I http://IP_SERVER_ANDA:5678

# Tes HTTPS (jika SSL diaktifkan)
curl -I https://n8n.domainanda.com
```

### Langkah 6: Akses n8n

Buka http://IP_SERVER_ANDA:5678 (atau https://n8n.domainanda.com)

Login dengan kredensial yang dikonfigurasi di langkah 3.

## Apa yang Terjadi

1. **Install Docker**: Memastikan Docker terinstall dan berjalan
2. **Buat Direktori**: Membuat direktori data n8n
3. **Deploy n8n**: Memulai n8n dengan Docker Compose
4. **Konfigurasi Nginx**: Mengatur reverse proxy
5. **Setup SSL**: Mengkonfigurasi Let's Encrypt (jika domain tersedia)

## Import Workflow

### Alert SSL Expired

1. Buka dashboard n8n
2. Klik **Import from File**
3. Pilih `n8n/workflows/monitoring/ssl-expired-alert.json`
4. Konfigurasi kredensial Telegram
5. Update daftar domain
6. Aktifkan workflow

### Alert Domain Expired

1. Import `n8n/workflows/monitoring/domain-expired-alert.json`
2. Konfigurasi kunci API WHOIS
3. Update daftar domain
4. Aktifkan workflow

### Alert Website Down

1. Import `n8n/workflows/monitoring/website-down-alert.json`
2. Konfigurasi kredensial Telegram
3. Update daftar URL
4. Aktifkan workflow

## Checklist Verifikasi

Setelah deployment, verifikasi:

- [ ] Container n8n berjalan
- [ ] Container PostgreSQL berjalan
- [ ] Antarmuka web n8n dapat diakses
- [ ] Dapat login dengan kredensial yang dikonfigurasi
- [ ] Dapat mengimpor workflow
- [ ] Dapat mengeksekusi workflow
- [ ] Sertifikat SSL valid (jika diaktifkan)

## Pemecahan Masalah

### Masalah: Container Tidak Berjalan

**Gejala**: Container langsung keluar setelah dimulai

**Solusi**:

```bash
# Cek log Docker
ssh ubuntu@IP_SERVER_ANDA "docker logs n8n"

# Cek Docker Compose
ssh ubuntu@IP_SERVER_ANDA "cd /opt/n8n && docker-compose ps"

# Restart container
ssh ubuntu@IP_SERVER_ANDA "cd /opt/n8n && docker-compose restart"
```

### Masalah: Tidak Dapat Mengakses Antarmuka Web

**Gejala**: Koneksi ditolak atau timeout

**Solusi**:

```bash
# Cek apakah port terbuka
ssh ubuntu@IP_SERVER_ANDA "sudo netstat -tlnp | grep 5678"

# Cek konfigurasi Nginx
ssh ubuntu@IP_SERVER_ANDA "sudo nginx -t"

# Cek log Nginx
ssh ubuntu@IP_SERVER_ANDA "sudo tail -f /var/log/nginx/n8n-error.log"
```

### Masalah: Koneksi Database Bermasalah

**Gejala**: n8n menampilkan error koneksi database

**Solusi**:

```bash
# Cek status PostgreSQL
ssh ubuntu@IP_SERVER_ANDA "docker exec n8n-postgres pg_isready"

# Cek log PostgreSQL
ssh ubuntu@IP_SERVER_ANDA "docker logs n8n-postgres"

# Restart PostgreSQL
ssh ubuntu@IP_SERVER_ANDA "cd /opt/n8n && docker-compose restart postgres"
```

### Masalah: Sertifikat SSL Tidak Berfungsi

**Gejala**: Browser menampilkan "Not Secure" atau error sertifikat

**Solusi**:

```bash
# Cek status sertifikat
ssh ubuntu@IP_SERVER_ANDA "sudo certbot certificates"

# Perbarui sertifikat
ssh ubuntu@IP_SERVER_ANDA "sudo certbot renew"

# Cek konfigurasi SSL Nginx
ssh ubuntu@IP_SERVER_ANDA "sudo nginx -t"
```

## Pemeliharaan

### Tugas Rutin

1. **Update image**: `docker-compose pull && docker-compose up -d`
2. **Cek log**: `docker-compose logs -f`
3. **Monitor ruang disk**: `df -h`
4. **Backup data**: Lihat bagian backup

### Strategi Backup

```bash
# Backup data n8n
tar -czf n8n-backup.tar.gz /opt/n8n/data

# Backup data PostgreSQL
docker exec n8n-postgres pg_dump -U n8n n8n > n8n-db-backup.sql

# Backup ke lokasi remote
rsync -avz /opt/n8n/ user@backup-server:/backups/n8n/
```

### Update Stack

```bash
# Pull image terbaru
docker-compose pull

# Restart layanan
docker-compose up -d

# Cek update
docker-compose images
```

## Sumber Daya

- [Dokumentasi n8n](https://docs.n8n.io/)
- [Komunitas n8n](https://community.n8n.io/)
- [Dokumentasi Docker](https://docs.docker.com/)
- [Dokumentasi PostgreSQL](https://www.postgresql.org/docs/)