# Certbot Role

Ansible role untuk instalasi dan konfigurasi SSL certificate menggunakan Let's Encrypt.

## Fitur

| Komponen | Deskripsi |
|---|---|
| **SSL Certificate** | Auto-generate certificate via Let's Encrypt |
| **Nginx Integration** | Konfigurasi Nginx untuk HTTPS |
| **Auto-Renewal** | Cron job untuk auto-renewal certificate |
| **HTTP to HTTPS** | Redirect otomatis HTTP ke HTTPS |
| **SSL Hardening** | TLS 1.2/1.3, secure ciphers |

## Kebutuhan

- Ubuntu 22.04 / 24.04 LTS
- Nginx sudah terinstall
- Domain sudah dipoin ke IP server (DNS A Record)
- Port 80 terbuka (untuk Let's Encrypt challenge)

## Variabel

| Variabel | Default | Deskripsi |
|---|---|---|
| `ssl_enabled` | `true` | Aktifkan SSL |
| `ssl_email` | `""` | Email untuk Let's Encrypt (wajib!) |
| `ssl_staging` | `false` | Gunakan staging server (untuk testing) |
| `ssl_auto_renew` | `true` | Aktifkan auto-renewal |
| `server_domain` | - | Domain untuk SSL (wajib!) |

## Contoh Inventory

```yaml
# inventories/production/inventory.yml

all:
  children:
    ssl_servers:
      hosts:
        103.150.116.50:
          ansible_user: deployer
          
          # Domain Configuration
          server_domain: "cahjenggot.my.id"
          
          # SSL Configuration
          ssl_enabled: true
          ssl_email: "admin@cahjenggot.my.id"
          ssl_staging: false    # Gunakan true untuk testing
          ssl_auto_renew: true
```

## Contoh Penggunaan

### Solo

```yaml
# playbooks/ssl-only.yml

- name: Setup SSL
  hosts: ssl_servers
  become: yes
  roles:
    - nginx
    - certbot
```

```bash
ansible-playbook -i inventories/production/inventory.yml playbooks/ssl-only.yml --ask-vault-pass
```

### Dengan Service 1 (Setup Server)

```yaml
# playbooks/setup-server.yml (sudah include certbot)

- name: Setup Server
  hosts: setup_servers
  become: yes
  roles:
    - server-hardening
    - ufw
    - nginx
    - certbot       # SSL otomatis
```

### Dengan Service 2 (Deploy Laravel)

```yaml
# playbooks/fix-laravel.yml (sudah include certbot)

- name: Deploy Laravel
  hosts: laravel_servers
  become: yes
  roles:
    - laravel
    - certbot       # SSL untuk domain Laravel
```

## Prasyarat DNS

Sebelum menjalankan role ini, pastikan domain sudah dipoin ke IP server:

```
# DNS Record (contoh)
Type  | Name              | Value
------|-------------------|---------
A     | cahjenggot.my.id  | 103.150.116.50
A     | www               | 103.150.116.50
```

```bash
# Verifikasi DNS
dig cahjenggot.my.id
nslookup cahjenggot.my.id
```

## Proses SSL

1. Install Certbot & Nginx plugin
2. Cek apakah certificate sudah ada
3. Request certificate ke Let's Encrypt
4. Konfigurasi Nginx untuk HTTPS
5. Setup cron auto-renewal

## Konfigurasi Nginx

Role ini akan generate konfigurasi Nginx seperti berikut:

```nginx
# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name cahjenggot.my.id;
    
    location /.well-known/acme-challenge/ {
        root /var/www/html;
    }
    
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name cahjenggot.my.id;
    
    ssl_certificate /etc/letsencrypt/live/cahjenggot.my.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/cahjenggot.my.id/privkey.pem;
    
    # TLS 1.2 & 1.3 only
    ssl_protocols TLSv1.2 TLSv1.3;
    ...
}
```

## Auto-Renewal

Role ini otomatis setup cron untuk auto-renewal:

```bash
# Cek cron
crontab -l | grep certbot

# Output:
0 0,12 * * * certbot renew --quiet --deploy-hook 'systemctl reload nginx'
```

## Testing

### Gunakan Staging Server

Untuk testing tanpa rate limit Let's Encrypt:

```yaml
# inventory.yml
ssl_staging: true  # Gunakan staging server
```

### Verifikasi SSL

```bash
# Cek certificate
sudo certbot certificates

# Test SSL
curl -I https://cahjenggot.my.id

# Check SSL grade
# https://www.ssllabs.com/ssltest/
```

## Troubleshooting

### Certificate gagal di-generate

```bash
# Cek log certbot
sudo cat /var/log/letsencrypt/letsencrypt.log

# Pastikan port 80 terbuka
sudo ufw status | grep 80

# Test manual
sudo certbot certonly --nginx -d example.com --dry-run
```

### SSL tidak work di browser

```bash
# Cek certificate
openssl s_client -connect example.com:443 -servername example.com

# Cek expiry
sudo certbot certificates
```

### Auto-renewal gagal

```bash
# Test renewal
sudo certbot renew --dry-run

# Cek cron
sudo cat /var/spool/cron/crontabs/root
```

## Rate Limits

Let's Encrypt memiliki rate limits:
- 50 certificates per domain per week
- 300 new orders per account per day

Gunakan `ssl_staging: true` untuk testing agar tidak kena rate limit.
