# OpenOps Toolkit

**Toolkit DevOps Open Source untuk Tim Kecil**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/ujgsp/OpenOpsToolkit.svg)](https://github.com/ujgsp/OpenOpsToolkit/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/ujgsp/OpenOpsToolkit.svg)](https://github.com/ujgsp/OpenOpsToolkit/issues)

> Deploy Laravel, setup monitoring, konfigurasi automation, dan kelola VPS Anda — semua dari satu toolkit.

---

## Apa yang Bisa Saya Lakukan Dengan Ini?

✅ **Deploy Laravel** ke VPS dalam hitungan menit (Ubuntu 22.04 + Nginx + PHP 8.2 + MySQL)

✅ **Deploy WordPress** dengan satu perintah

✅ **Setup n8n** server workflow automation

✅ **Install Docker** di server Ubuntu mana pun

✅ **Setup OpenVPN** untuk akses remote yang aman

✅ **Deploy Vaultwarden** sebagai password manager self-hosted

✅ **Terima Alert Telegram** saat SSL expired, domain expired, atau website down

✅ **Setup Monitoring** dengan Uptime Kuma, Grafana, dan Prometheus

✅ **Analisis Insiden** dengan analisis log berbasis AI

✅ **Kelola Banyak Server** dari satu mesin kontrol

---

## Untuk Siapa Ini?

| Siapa | Mengapa |
|-------|---------|
| 👨‍💻 **Laravel Developer** | Deploy ke VPS tanpa pengetahuan DevOps |
| 🌐 **WordPress Developer** | Setup hosting untuk klien dalam hitungan menit |
| 💼 **Freelancer** | Kelola banyak server klien secara efisien |
| 🏢 **Software House Kecil** | Standarisasi proses deployment |
| 🏛️ **Tim IT Pemerintah** | Ikuti best practices dengan dokumentasi jelas |
| 🚀 **Startup** | Mulai dari kecil, scale nanti |

---

## Mengapa OpenOps Toolkit?

Tool DevOps enterprise sering kali:
- ❌ Terlalu kompleks untuk tim kecil
- ❌ Membutuhkan infrastruktur mahal
- ❌ Learning curve tinggi
- ❌ Overkill untuk 1-5 server

**OpenOps Toolkit** fokus pada:
- ✅ **VPS murah** (mulai dari $5/bulan)
- ✅ **Deployment sederhana** (satu perintah)
- ✅ **Dokumentasi jelas** (panduan langkah demi langkah)
- ✅ **Automation praktis** (workflow dunia nyata)
- ✅ **Ramah tim kecil** (1-10 orang)

---

## Mulai Cepat

### Prasyarat

- Ubuntu Server 22.04 LTS (1 VPS)
- Akses SSH ke server Anda
- Git terinstall di komputer Anda

### 1. Clone Repository

```bash
git clone https://github.com/ujgsp/OpenOpsToolkit.git
cd OpenOpsToolkit
```

### 2. Deploy Laravel (Contoh)

```bash
# Edit inventory dengan IP server Anda
nano ansible/inventories/production/hosts.yml

# Pilih webserver yang ingin digunakan:

# Opsi 1: Nginx (paling umum)
ansible-playbook -i ansible/inventories/production ansible/playbooks/laravel-nginx.yml

# Opsi 2: Apache2
ansible-playbook -i ansible/inventories/production ansible/playbooks/laravel-apache.yml

# Opsi 3: OpenLiteSpeed
ansible-playbook -i ansible/inventories/production ansible/playbooks/laravel-ols.yml
```

**Hasil**: Aplikasi Laravel berjalan di `http://ip-server-anda`

### 3. Setup Monitoring

```bash
# Deploy monitoring stack
cd monitoring
docker-compose up -d
```

**Hasil**: 
- Uptime Kuma di `http://ip-server-anda:3001`
- Grafana di `http://ip-server-anda:3000`
- Prometheus di `http://ip-server-anda:9090`

### 4. Import Workflow n8n

1. Buka dashboard n8n
2. Klik **Import from File**
3. Pilih `n8n/workflows/monitoring/ssl-expired-alert.json`
4. Konfigurasi token bot Telegram
5. Aktifkan workflow

**Hasil**: Terima alert Telegram saat sertifikat SSL expired

> 📖 **Panduan lengkap**: [Deploy Laravel ke VPS](docs/use-cases/deploy-laravel-vps.md) | [Setup Monitoring](docs/use-cases/setup-monitoring-stack.md) | [Setup n8n](docs/use-cases/setup-n8n-server.md) | [Setup OpenVPN](docs/use-cases/setup-openvpn-server.md)

---

## Screenshot

### Deploy Laravel

![Deploy Laravel](assets/screenshots/laravel-deploy-dashboard.png)

*Deploy Laravel ke VPS dengan satu perintah*

### Dashboard Monitoring

![Uptime Kuma](assets/screenshots/uptime-kuma.png)

*Monitor semua website Anda di satu tempat*

### Notifikasi Telegram

![Alert Telegram](assets/screenshots/telegram-alert.png)

*Dapatkan alert instan saat ada masalah*

### Workflow n8n

![Workflow n8n](assets/screenshots/n8n-workflow.png)

*Otomasi tugas operasional dengan visual workflow*

> 📸 **TODO**: Tambahkan screenshot sebenarnya sebelum rilis v1.0.0

---

## Modul yang Tersedia

### Ansible Roles

| Role | Deskripsi | Kebutuhan |
|------|-----------|-----------|
| `laravel` | Deploy aplikasi Laravel | Ubuntu 22.04, Nginx, PHP 8.2, MySQL |
| `wordpress` | Deploy WordPress | Ubuntu 22.04, Nginx, PHP 8.2, MySQL |
| `n8n` | Deploy automation n8n | Ubuntu 22.04, Docker |
| `docker` | Install Docker CE | Ubuntu 22.04 |
| `openvpn` | Setup server OpenVPN | Ubuntu 22.04 |
| `vaultwarden` | Deploy Vaultwarden | Ubuntu 22.04, Docker |

### Workflow n8n

| Workflow | Tujuan | Jadwal |
|----------|--------|--------|
| SSL Expired Alert | Monitor sertifikat SSL | Setiap 12 jam |
| Domain Expired Alert | Monitor expiry domain | Setiap 24 jam |
| Website Down Alert | Monitor ketersediaan website | Setiap 5 menit |

### Monitoring Stack

| Tool | Tujuan | Port |
|------|--------|------|
| Uptime Kuma | Monitoring website | 3001 |
| Grafana | Visualisasi | 3000 |
| Prometheus | Pengumpulan metrik | 9090 |

---

## Contoh Kasus Penggunaan

### Kasus 1: Deploy Laravel untuk Klien

**Skenario**: Freelancer perlu deploy aplikasi Laravel untuk klien.

```bash
# 1. Dapatkan kredensial VPS klien
# 2. Update inventory
nano ansible/inventories/production/hosts.yml

# 3. Deploy
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml

# 4. Selesai! Aplikasi klien sudah live
```

**Waktu**: 15 menit

📖 **Panduan lengkap**: [Deploy Laravel ke VPS](docs/use-cases/deploy-laravel-vps.md)

---

### Kasus 2: Setup Monitoring untuk Banyak Situs

**Skenario**: Software house perlu monitor 10 website klien.

```bash
# 1. Deploy monitoring stack
cd monitoring && docker-compose up -d

# 2. Import workflow alert SSL ke n8n
# 3. Tambahkan semua domain yang akan dimonitor
# 4. Konfigurasi notifikasi Telegram
```

**Hasil**: Dapat alert sebelum SSL/domain expired

📖 **Panduan lengkap**: [Setup Monitoring Stack](docs/use-cases/setup-monitoring-stack.md)

---

### Kasus 3: Setup VPN untuk Tim Remote

**Skenario**: Tim IT pemerintah butuh akses remote yang aman.

```bash
# 1. Deploy OpenVPN
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml --limit vpn_servers

# 2. Generate konfigurasi klien
# 3. Distribusikan ke anggota tim
```

**Hasil**: Tim dapat mengakses sistem internal dengan aman

📖 **Panduan lengkap**: [Setup OpenVPN Server](docs/use-cases/setup-openvpn-server.md)

---

## Dokumentasi Lengkap

### Panduan Penggunaan
- [Deploy Laravel ke VPS](docs/use-cases/deploy-laravel-vps.md)
- [Setup Monitoring Stack](docs/use-cases/setup-monitoring-stack.md)
- [Setup n8n Server](docs/use-cases/setup-n8n-server.md)
- [Setup OpenVPN Server](docs/use-cases/setup-openvpn-server.md)

### Contoh Cepat
- [Deploy Laravel](examples/deploy-laravel/README.md)
- [Setup Monitoring](examples/setup-monitoring/README.md)
- [Setup n8n](examples/setup-n8n/README.md)
- [Alert Telegram](examples/telegram-alert/README.md)

### Dokumentasi Teknis
- [Ansible Roles](ansible/roles/)
- [n8n Workflows](n8n/workflows/)
- [Monitoring Stack](monitoring/)
- [AI Ops](docs/aiops/)
- [Multi-Server](docs/multi-server/)

---

## Roadmap

### ✅ v0.1.0 — MVP (Selesai)
- [x] Deploy Laravel
- [x] Deploy WordPress
- [x] Deploy n8n
- [x] Install Docker
- [x] Setup OpenVPN
- [x] Deploy Vaultwarden

### ✅ v0.2.0 — Monitoring (Selesai)
- [x] Dokumentasi Uptime Kuma
- [x] Setup Grafana
- [x] Konfigurasi Prometheus

### ✅ v0.3.0 — AI Ops (Selesai)
- [x] Prompt analisis insiden
- [x] Ringkasan issue GitHub

### ✅ v0.4.0 — Multi-Server (Selesai)
- [x] Arsitektur multi-server
- [x] Inventaris terpusat
- [x] Orkestrasi deployment

### 🚧 v1.0.0 — Rilis Stabil (Dalam Proses)
- [ ] Testing integrasi
- [ ] Tutorial video
- [ ] Kontribusi komunitas
- [ ] Benchmark performa

---

## Struktur Proyek

```
OpenOpsToolkit/
├── ansible/              # Otomasi infrastruktur
│   ├── roles/            # 6 Ansible roles
│   ├── playbooks/        # Playbook deployment
│   └── inventories/      # Inventaris server
├── n8n/                  # Otomasi workflow
├── monitoring/           # Monitoring stack
├── docs/                 # Dokumentasi
├── examples/             # Contoh mulai cepat
└── scripts/              # Script utilitas
```

---

## Berkontribusi

Kami menyambut kontribusi! Lihat [CONTRIBUTING.md](CONTRIBUTING.md) untuk detailnya.

### Cara Berkontribusi

1. Fork repository
2. Buat branch fitur
3. Buat perubahan Anda
4. Submit pull request

### Good First Issues

Cari issue dengan label [`good first issue`](https://github.com/ujgsp/OpenOpsToolkit/labels/good%20first%20issue).

---

## Keamanan

Untuk masalah keamanan, lihat [SECURITY.md](SECURITY.md).

---

## Dukungan

- 📖 [Dokumentasi](docs/)
- 🐛 [Laporkan Bug](https://github.com/ujgsp/OpenOpsToolkit/issues/new?template=bug_report.md)
- 💡 [Minta Fitur](https://github.com/ujgsp/OpenOpsToolkit/issues/new?template=feature_request.md)
- 💬 [Diskusi](https://github.com/ujgsp/OpenOpsToolkit/discussions)

---

## Lisensi

MIT License — lihat [LICENSE](LICENSE) untuk detailnya.

---

## Penghargaan

- Terinspirasi dari [Ansible Galaxy](https://galaxy.ansible.com/)
- Terinspirasi dari [Awesome n8n](https://github.com/n8n-io/awesome-n8n)
- Dibangun untuk komunitas developer Indonesia

---

**Dibuat dengan ❤️ untuk developer yang mengelola server sendiri**