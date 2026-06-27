# vps-setup

Satu role Ansible untuk **layanan setup VPS Ubuntu** — hardening, web server, SSL, backup, monitoring, dan handover document.

Mapping langsung ke 3 tier layanan:

| Tier | Harga | Cakupan |
|------|-------|---------|
| `starter` | Rp 500-750K | Hardening + 1 web stack + PHP + SSL + backup + handover |
| `server_ready` | Rp 1.2-1.8jt | Starter + monitoring uptime |
| `ops_care` | Rp 500K-1.2jt/bln | Server_ready + maintenance (add-on) |

---

## Fitur

- **System setup** — hostname, timezone, swap, unattended-upgrades, base packages
- **SSH hardening** — port, key-only auth, MaxAuthTries, deploy user
- **UFW firewall** — default deny incoming, allow SSH/HTTP/HTTPS
- **Fail2Ban** — proteksi brute-force SSH
- **Web server** — pilih Nginx / Apache2 / OpenLiteSpeed (via `webserver` var)
- **PHP 8.2** — FPM + common modules + php.ini tuning
- **SSL** — Certbot + auto-renewal cron
- **Backup** — file + MySQL backup, cron harian, retensi 7 hari
- **Monitoring uptime** — cron-based HTTP/TCP check (tier server_ready+)
- **Handover document** — file markdown di `/root/handover-{client}.md`
- **Tags** — setiap komponen bisa jalan sendiri via tag

---

## Cara Pakai

### 1. Via playbook bawaan

```bash
# Starter
ansible-playbook -i inventory.yml playbooks/setup-vps.yml -e service_tier=starter

# Server Ready
ansible-playbook -i inventory.yml playbooks/setup-vps.yml -e service_tier=server_ready

# Hanya handover (re-gen dokumen)
ansible-playbook -i inventory.yml playbooks/setup-vps.yml -t handover

# Hanya Nginx + PHP
ansible-playbook -i inventory.yml playbooks/setup-vps.yml -t nginx,php
```

### 2. Standalone (dari role lain)

```yaml
- hosts: all
  roles:
    - role: vps-setup
      vars:
        service_tier: server_ready
        webserver: nginx
        server_domain: "app.client.com"
```

### 3. Inventory minimal

```yaml
all:
  hosts:
    client-vps:
      ansible_host: 103.x.x.x
      ansible_user: root
  vars:
    service_tier: starter
    webserver: nginx
    client_name: "client-xyz"
    client_email: "admin@client.com"
    server_domain: "app.client.com"
    deploy_user_ssh_key: "ssh-rsa AAAAB3NzaC1... user@host"
```

---

## Tags

| Tag | Komponen |
|-----|----------|
| `system` | hostname, timezone, swap, packages |
| `hardening` | Semua security (SSH + deploy user + UFW + Fail2Ban) |
| `ssh` | SSH hardening (sshd_config) |
| `deploy-user` / `deploy` | Deploy user + SSH key + sudo |
| `ufw` / `firewall` | UFW firewall only |
| `fail2ban` | Fail2Ban only |
| `nginx` | Nginx install + vhost |
| `apache2` | Apache2 install + vhost |
| `ols` / `openlitespeed` | OpenLiteSpeed install |
| `php` / `php8` | PHP 8.2 + FPM |
| `ssl` / `certbot` | SSL certificate |
| `backup` | Backup scripts + cron |
| `monitoring` | Uptime check script + cron |
| `handover` | Generate handover doc |

Gunakan: `ansible-playbook setup-vps.yml -t nginx,php,ssl`

---

## Variable Penting

| Variable | Default | Deskripsi |
|----------|---------|-----------|
| `service_tier` | `starter` | `starter` / `server_ready` / `ops_care` |
| `webserver` | `nginx` | `nginx` / `apache2` / `openlitespeed` |
| `client_name` | `""` | Nama client (untuk handover) |
| `server_domain` | `""` | Domain untuk SSL + vhost |
| `deploy_user` | `deploy` | Nama user deploy |
| `deploy_user_ssh_key` | `""` | **Wajib** — public key content |
| `ssl_email` | `""` | Email untuk Certbot |
| `php_version` | `"8.2"` | Versi PHP |
| `backup_mysql` | `false` | Backup database MySQL |
| `backup_mysql_password` | `""` | Password MySQL (pakai vault) |

Semua variable bisa di-override di inventory, `--extra-vars`, atau group_vars.

---

## Yang TIDAK Di-Handle (Client-Facing)

Role ini fokus ke **setup server dasar**, bukan deployment aplikasi:

| Tidak Di-handle | Alternatif |
|-----------------|-----------|
| Deploy Laravel / WordPress / app spesifik | Pakai role `laravel`, `wordpress` di repo ini |
| NodeJS / Python / Go runtime | Tambah secara manual atau via role terpisah |
| Docker / container | Pakai role `docker` di repo ini |
| Database management (user, db) | Playbook `dbservers.yml` |
| Performance monitoring (Grafana, Prometheus) | Playbook `monitoring.yml` (stack lengkap) |
| Advance firewall (rate limit, geo-block) | Manual atau role tambahan |
| Cluster / load balancer / auto-scaling | Diluar scope |
| Migrasi data dari server lama | Manual |
| Support / maintenance bulanan | Di-handle via Ops Care add-on (terpisah) |

Role ini **setup awal** (basic provisioning), bukan managed service.

---

## Yang TIDAK Di-Handle (Teknis)

- **Tidak install Docker** — Docker role terpisah
- **Tidak setup queue worker / scheduler** — spesifik aplikasi
- **Tidak deploy kode aplikasi** — hanya sediakan web server + runtime
- **Tidak setup database** — role ini backup MySQL tapi tidak create user/database (pakai `dbservers.yml`)
- **Tidak monitoring performa** — hanya uptime (HTTP/TCP reachable)
- **Tidak advance security** — hanya hardening dasar (SSH, UFW, Fail2Ban)

---

## Struktur Role

```
roles/vps-setup/
├── tasks/
│   ├── main.yml            ← orchestrator + tier logic
│   ├── system.yml          ← hostname, timezone, swap, packages
│   ├── hardening.yml       ← dispatcher ke sub-file dengan tag granular
│   ├── ssh.yml             ← SSH hardening
│   ├── deploy-user.yml     ← Deploy user + SSH key + sudo
│   ├── ufw.yml             ← UFW firewall
│   ├── fail2ban.yml        ← Fail2Ban
│   ├── nginx.yml           ← Nginx
│   ├── apache2.yml         ← Apache2
│   ├── ols.yml             ← OpenLiteSpeed
│   ├── php.yml             ← PHP 8.2
│   ├── ssl.yml             ← Certbot
│   ├── backup.yml          ← File + MySQL backup
│   ├── monitoring.yml      ← Uptime check
│   └── handover.yml        ← Handover doc
├── defaults/main.yml       ← Semua variable default
├── handlers/main.yml       ← Handlers (restart services)
└── templates/
    ├── nginx-vhost.conf.j2 ← Nginx virtual host
    ├── apache2-vhost.conf.j2 ← Apache2 virtual host
    ├── handover.md.j2      ← Template handover document
    └── jail.local.j2       ← Template Fail2Ban config
```

---

## Requirements

- **Ansible** ≥ 2.10
- **Target**: Ubuntu 22.04 / 24.04 (fresh VPS)
- **Akses**: root via SSH (key-based)
- **Python** di target: python3 (minimal)

---

*Part of **OpenOps Toolkit** — Ansible-based DevOps toolkit for VPS/Ubuntu.*
