# Setup Monitoring Stack

Panduan lengkap untuk deploy Uptime Kuma, Grafana, dan Prometheus untuk monitoring.

## Ringkasan

Panduan ini akan memandu Anda untuk deploy stack monitoring lengkap menggunakan Docker Compose. Stack ini mencakup:

- **Uptime Kuma**: Monitoring website dan layanan
- **Grafana**: Visualisasi dan dashboard
- **Prometheus**: Pengumpulan dan penyimpanan metrik
- **Node Exporter**: Metrik sistem

## Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                      Stack Monitoring                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Uptime Kuma │  │   Grafana   │  │  Prometheus │        │
│  │   :3001     │  │   :3000     │  │   :9090     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                 │                │
│         └────────────────┼─────────────────┘                │
│                          │                                  │
│                   ┌──────┴──────┐                          │
│                   │   Network   │                          │
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

### Langkah 2: Clone Repository

```bash
git clone https://github.com/ujgsp/OpenOpsToolkit.git
cd OpenOpsToolkit/monitoring
```

### Langkah 3: Mulai Stack Monitoring

```bash
docker-compose up -d
```

### Langkah 4: Verifikasi Layanan

```bash
# Cek semua container berjalan
docker-compose ps

# Cek Uptime Kuma
curl http://localhost:3001

# Cek Grafana
curl http://localhost:3000/api/health

# Cek Prometheus
curl http://localhost:9090/-/healthy

# Cek Node Exporter
curl http://localhost:9100/metrics
```

### Langkah 5: Akses Dashboard

| Layanan | URL | Kredensial Default |
|---------|-----|-------------------|
| Uptime Kuma | http://IP_ANDA:3001 | Buat saat kunjungan pertama |
| Grafana | http://IP_ANDA:3000 | admin / admin |
| Prometheus | http://IP_ANDA:9090 | Tanpa autentikasi |

## Konfigurasi

### Uptime Kuma

#### Tambah Monitor Website

1. Buka http://IP_ANDA:3001
2. Buat akun admin
3. Klik "Add New Monitor"
4. Konfigurasi:
   - **Tipe Monitor**: HTTP(s)
   - **Nama**: Website Saya
   - **URL**: https://websiteanda.com
   - **Interval**: 60 detik
5. Klik "Save"

#### Tambah Notifikasi Telegram

1. Buka Settings → Notifications
2. Klik "Setup Notification"
3. Pilih "Telegram"
4. Konfigurasi:
   - **Bot Token**: Dari @BotFather
   - **Chat ID**: Dari @userinfobot
5. Klik "Save"

### Grafana

#### Tambah Sumber Data Prometheus

1. Buka http://IP_ANDA:3000
2. Login dengan admin/admin
3. Buka Configuration → Data Sources
4. Klik "Add data source"
5. Pilih "Prometheus"
6. Konfigurasi:
   - **URL**: http://prometheus:9090
   - **Akses**: Server (default)
7. Klik "Save & Test"

#### Import Dashboard

1. Buka Dashboards → Import
2. Masukkan ID dashboard: **1860** (Node Exporter Full)
3. Pilih sumber data Prometheus
4. Klik "Import"

### Prometheus

#### Edit Konfigurasi

Edit `prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets:
        - 'node-exporter:9100'
        - 'SERVER_2:9100'
        - 'SERVER_3:9100'
```

#### Tambah Aturan Alert

Edit `prometheus/alert_rules.yml`:

```yaml
groups:
  - name: example
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: Penggunaan CPU tinggi pada {{ $labels.instance }}
```

## Checklist Verifikasi

Setelah deployment, verifikasi:

- [ ] Semua container berjalan
- [ ] Uptime Kuma dapat diakses
- [ ] Grafana dapat diakses
- [ ] Prometheus mengumpulkan metrik
- [ ] Node Exporter melaporkan metrik sistem
- [ ] Notifikasi Telegram berfungsi
- [ ] Dashboard menampilkan data

## Pemecahan Masalah

### Masalah: Container Tidak Berjalan

**Gejala**: Container langsung keluar setelah dimulai

**Solusi**:

```bash
# Cek log container
docker-compose logs -f

# Cek layanan spesifik
docker-compose logs -f uptime-kuma

# Restart layanan
docker-compose restart uptime-kuma
```

### Masalah: Port Sudah Digunakan

**Gejala**: Error "port is already allocated"

**Solusi**:

```bash
# Cek apa yang menggunakan port
sudo netstat -tlnp | grep :3001

# Hentikan layanan yang konflik
sudo systemctl stop layanan-konflik

# Atau ubah port di docker-compose.yml
ports:
  - "3002:3001"  # Ubah port host
```

### Masalah: Permission Ditolak

**Gejala**: Container tidak dapat menulis ke direktori data

**Solusi**:

```bash
# Perbaiki permission
sudo chown -R 1000:1000 monitoring/uptime-kuma/data
sudo chown -R 472:472 monitoring/grafana/data
sudo chown -R 65534:65534 monitoring/prometheus/data
```

### Masalah: Grafana Tidak Dapat Terhubung ke Prometheus

**Gejala**: "Bad Gateway" atau "Connection refused" di Grafana

**Solusi**:

```bash
# Cek apakah Prometheus berjalan
docker-compose ps prometheus

# Cek log Prometheus
docker-compose logs prometheus

# Tes koneksi dari container Grafana
docker exec grafana wget -qO- http://prometheus:9090/-/healthy
```

## Pemeliharaan

### Tugas Rutin

1. **Update image**: `docker-compose pull && docker-compose up -d`
2. **Cek log**: `docker-compose logs -f`
3. **Monitor ruang disk**: `df -h`
4. **Backup data**: Lihat bagian backup

### Strategi Backup

```bash
# Backup data Uptime Kuma
tar -czf uptime-kuma-backup.tar.gz monitoring/uptime-kuma/data

# Backup data Grafana
tar -czf grafana-backup.tar.gz monitoring/grafana/data

# Backup data Prometheus
tar -czf prometheus-backup.tar.gz monitoring/prometheus/data

# Backup ke lokasi remote
rsync -avz monitoring/ user@backup-server:/backups/monitoring/
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

- [Dokumentasi Uptime Kuma](https://uptime.kuma.pet/docs/)
- [Dokumentasi Grafana](https://grafana.com/docs/)
- [Dokumentasi Prometheus](https://prometheus.io/docs/)
- [Dokumentasi Node Exporter](https://prometheus.io/docs/guides/node-exporter/)