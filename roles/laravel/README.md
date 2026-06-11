# Ansible Role: Laravel

Deploy Laravel application on Ubuntu 22.04 with Nginx, PHP-FPM, MySQL, **Scheduler**, and **Queue Worker**.

## Quick Start (Pemula)

Pilih playbook sesuai kebutuhan:

```bash
# 1. Edit inventory
nano inventories/production/inventory.yml

# 2. Jalankan salah satu:

# Deploy Laravel dengan Nginx
ansible-playbook -i inventories/production playbooks/laravel-nginx.yml

# Fix/Deploy Laravel (termasuk Scheduler & Queue)
ansible-playbook -i inventories/production playbooks/fix-laravel.yml

# Setup Server lengkap
ansible-playbook -i inventories/production playbooks/setup-server.yml
```

## Requirements

- Ubuntu 22.04 LTS
- Minimum 1GB RAM
- SSH access with sudo privileges
- Domain name (optional, for SSL)

## Features

| Feature | Status | Description |
|---|---|---|
| **Nginx** | ✅ | Web server with PHP-FPM |
| **PHP 8.2/8.3** | ✅ | Latest PHP with extensions |
| **MySQL** | ✅ | Database server |
| **Composer** | ✅ | PHP dependency manager |
| **SSL (Certbot)** | ✅ | Let's Encrypt auto-SSL |
| **Scheduler** | ✅ | Laravel task scheduler |
| **Queue Worker** | ✅ | Supervisor-managed queue |
| **UFW Firewall** | ✅ | Basic firewall rules |

## Role Variables

### Required Variables

```yaml
# Application
app_name: "myapp"                             # Application name
app_repo: "https://github.com/user/repo.git"  # Git repository
app_branch: "main"                            # Git branch
app_env: "production"                         # Environment

# Database
db_name: "laravel_db"                         # Database name
db_user: "laravel"                            # Database user
db_password: "secure_password"                # Database password

# Domain
domain: "example.com"                         # Domain name
```

### Optional Variables

```yaml
# PHP
php_version: "8.2"                            # PHP version
php_memory_limit: "256M"                      # Memory limit
php_upload_max_filesize: "64M"                # Upload max filesize

# SSL
ssl_enabled: false                            # Enable SSL
ssl_email: "admin@example.com"                # Email for Let's Encrypt

# Cache
cache_driver: "file"                          # Cache driver
session_driver: "file"                        # Session driver
queue_driver: "sync"                          # Queue driver
```

### Scheduler Variables

```yaml
# Scheduler Configuration
scheduler_enabled: false                       # Enable Laravel Scheduler
scheduler_cron_minute: "*"                    # Cron minute (default: every minute)
scheduler_cron_hour: "*"                      # Cron hour
```

### Queue Worker Variables

```yaml
# Queue Worker Configuration
queue_worker_enabled: false                    # Enable Queue Worker
queue_worker_connection: "database"           # Queue connection (database/redis/sqs)
queue_worker_queue: "default"                 # Queue name
queue_worker_sleep: "3"                       # Sleep time between jobs
queue_worker_tries: "3"                       # Max tries per job
queue_worker_max_time: "3600"                 # Max time per worker (seconds)
queue_worker_processes: 1                     # Number of worker processes
```

## Example Inventory

### Service 2: Beresin Deploy Laravel (Rp 750.000)

```yaml
# inventories/production/inventory.yml

all:
  children:
    laravel_servers:
      hosts:
        103.150.116.50:
          ansible_user: deployer
          
          # Application
          app_name: "klien-laravel-app"
          app_repo: "https://github.com/klien/repo.git"
          app_branch: "main"
          app_env: "production"
          
          # Domain & SSL
          domain: "apps.klien.com"
          ssl_enabled: true
          ssl_email: "admin@klien.com"
          
          # Database
          db_name: "laravel_klien"
          db_user: "laravel_klien"
          db_password: "{{ vault_db_password }}"
          
          # Scheduler (aktifkan jika perlu)
          scheduler_enabled: true
          scheduler_cron_minute: "*"
          scheduler_cron_hour: "*"
          
          # Queue Worker (aktifkan jika perlu)
          queue_worker_enabled: true
          queue_worker_connection: "database"
          queue_worker_queue: "default"
          queue_worker_processes: 2
```

### Vault File

```yaml
# inventories/production/group_vars/all/vault.yml

vault_db_password: "supersecretpassword"
```

```bash
# Edit vault
ansible-vault edit inventories/production/group_vars/all/vault.yml
```

## What This Role Does

1. **System Updates**: Updates package lists and installs dependencies
2. **PHP Installation**: Installs PHP 8.2 with required extensions
3. **Nginx Installation**: Installs and configures Nginx
4. **MySQL Installation**: Installs MySQL and creates database
5. **Composer Installation**: Installs Composer globally
6. **Application Deployment**: Clones repository and installs dependencies
7. **Configuration**: Sets up environment and configuration files
8. **SSL Setup**: Optional Let's Encrypt SSL configuration
9. **Scheduler Setup**: Configures Laravel task scheduler via cron
10. **Queue Worker**: Configures Supervisor for queue worker processes

## File Structure

```
laravel/
├── tasks/
│   └── main.yml              # Main task file
├── handlers/
│   └── main.yml              # Service handlers
├── templates/
│   ├── nginx.conf.j2         # Nginx configuration
│   ├── php-fpm.conf.j2       # PHP-FPM pool configuration
│   ├── env.j2                # Laravel .env template
│   └── supervisor-queue.conf.j2  # Queue Worker config
├── defaults/
│   └── main.yml              # Default variables
├── vars/
│   └── main.yml              # Role variables
├── meta/
│   └── main.yml              # Role metadata
└── README.md
```

## Scheduler Setup

### Cara Kerja

Laravel Scheduler bekerja dengan satu cron entry yang menjalankan `artisan schedule:run` setiap menit:

```
* * * * * cd /var/www/myapp && php artisan schedule:run >> /dev/null 2>&1
```

### Mengaktifkan Scheduler

```yaml
# inventory.yml
scheduler_enabled: true
```

### Manual Check

```bash
# Cek cron
crontab -u www-data -l

# Test scheduler
cd /var/www/myapp && php artisan schedule:list
```

## Queue Worker Setup

### Cara Kerja

Queue Worker dijalankan menggunakan **Supervisor** untuk memastikan worker selalu berjalan:

```ini
# /etc/supervisor/conf.d/myapp-queue.conf
[program:myapp-queue]
process_name=%(program_name)s_%(process_num)02d
command=php artisan queue:work database --queue=default --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=2
```

### Mengaktifkan Queue Worker

```yaml
# inventory.yml
queue_worker_enabled: true
queue_worker_connection: "database"    # or redis, sqs
queue_worker_queue: "default"
queue_worker_processes: 2
```

### Manual Check

```bash
# Cek status Supervisor
sudo supervisorctl status

# Restart queue worker
sudo supervisorctl restart myapp-queue*

# View logs
tail -f /var/log/supervisor/myapp-queue.log
```

## Usage Examples

### Deploy Baru

```bash
# Edit inventory
nano inventories/production/inventory.yml

# Deploy
ansible-playbook -i inventories/production/inventory.yml playbooks/laravel-nginx.yml --ask-vault-pass
```

### Fix/Redeploy (Service 2)

```bash
# Jalankan fix-laravel playbook
ansible-playbook -i inventories/production/inventory.yml playbooks/fix-laravel.yml --ask-vault-pass
```

### Dry Run (Check Mode)

```bash
ansible-playbook -i inventories/production/inventory.yml playbooks/laravel-nginx.yml --check
```

## Post-Deployment Checklist

Setelah deployment, pastikan:

- [ ] Akses website: `curl -I http://your-domain.com`
- [ ] Nginx running: `systemctl status nginx`
- [ ] PHP-FPM running: `systemctl status php8.2-fpm`
- [ ] MySQL running: `systemctl status mysql`
- [ ] Laravel logs tidak ada error: `tail -f /var/www/myapp/storage/logs/laravel.log`
- [ ] Jika scheduler aktif: `crontab -u www-data -l`
- [ ] Jika queue aktif: `sudo supervisorctl status`

## Troubleshooting

### Permission Denied

```bash
# Fix storage permissions
sudo chown -R www-data:www-data /var/www/myapp/storage
sudo chmod -R 775 /var/www/myapp/storage
```

### Queue Worker Down

```bash
# Check Supervisor
sudo supervisorctl status

# Restart queue worker
sudo supervisorctl restart myapp-queue*

# Check logs
tail -f /var/log/supervisor/myapp-queue.log
```

### Scheduler Not Running

```bash
# Check cron
crontab -u www-data -l

# Test scheduler manually
cd /var/www/myapp && php artisan schedule:run
```

### Database Connection Failed

```bash
# Check MySQL
sudo systemctl status mysql
mysql -u root -p -e "SHOW DATABASES;"
```

### Nginx Configuration Error

```bash
# Test configuration
sudo nginx -t

# Check error logs
sudo tail -f /var/log/nginx/error.log
```

## Logs

- **Nginx**: `/var/log/nginx/`
- **PHP-FPM**: `/var/log/php8.2-fpm.log`
- **MySQL**: `/var/log/mysql/`
- **Laravel**: `/var/www/myapp/storage/logs/`
- **Supervisor Queue**: `/var/log/supervisor/myapp-queue.log`

## License

MIT

## Author

OpenOps Toolkit Contributors
