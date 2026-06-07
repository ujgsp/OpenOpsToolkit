# Ansible Role: Laravel

Deploy Laravel application on Ubuntu 22.04 with Nginx, PHP-FPM, and MySQL.

## Quick Start (Pemula)

Pilih playbook sesuai webserver yang ingin digunakan:

```bash
# 1. Edit inventory
nano ansible/inventories/production/hosts.yml

# 2. Jalankan salah satu:

# Nginx (paling umum)
ansible-playbook -i ansible/inventories/production ansible/playbooks/laravel-nginx.yml

# Apache2
ansible-playbook -i ansible/inventories/production ansible/playbooks/laravel-apache.yml

# OpenLiteSpeed
ansible-playbook -i ansible/inventories/production ansible/playbooks/laravel-ols.yml
```

> 💡 Tidak perlu set variable `laravel_webserver_type` — sudah otomatis di setiap playbook.

## Requirements

- Ubuntu 22.04 LTS
- Minimum 1GB RAM
- SSH access with sudo privileges
- Domain name (optional, for SSL)

## Supported Web Servers

| Web Server | Variable Value | Notes |
|------------|----------------|-------|
| Nginx | `nginx` | Default, recommended |
| Apache2 | `apache2` | With mod_php or PHP-FPM |
| OpenLiteSpeed | `openlitespeed` | High-performance alternative |

## Role Variables

### Required Variables

```yaml
# Application
laravel_app_name: "myapp"                    # Application name
laravel_app_repo: "https://github.com/user/repo.git"  # Git repository
laravel_app_branch: "main"                   # Git branch
laravel_app_env: "production"                # Environment

# Database
laravel_db_name: "laravel_db"                # Database name
laravel_db_user: "laravel"                   # Database user
laravel_db_password: "secure_password"       # Database password

# Domain
laravel_domain: "example.com"                # Domain name
```

### Optional Variables

```yaml
# Webserver (nginx | apache2 | openlitespeed)
laravel_webserver_type: "nginx"              # Webserver type

# PHP
laravel_php_version: "8.2"                   # PHP version
laravel_php_memory_limit: "256M"             # Memory limit
laravel_php_upload_max_filesize: "64M"       # Upload max filesize

# Nginx
laravel_nginx_worker_processes: "auto"       # Worker processes
laravel_nginx_client_max_body_size: "64M"    # Client max body size

# SSL
laravel_ssl_enabled: false                   # Enable SSL
laravel_ssl_email: "admin@example.com"       # Email for Let's Encrypt

# Cache
laravel_cache_driver: "file"                 # Cache driver
laravel_session_driver: "file"               # Session driver
laravel_queue_driver: "sync"                 # Queue driver
```

## Dependencies

- docker (optional, for containerized deployment)

## Example Playbook

### Basic Usage

```yaml
---
- hosts: webservers
  become: yes
  roles:
    - laravel
```

### With Custom Variables

```yaml
---
- hosts: webservers
  become: yes
  vars:
    laravel_app_name: "my-laravel-app"
    laravel_app_repo: "https://github.com/user/my-laravel-app.git"
    laravel_domain: "myapp.example.com"
    laravel_ssl_enabled: true
    laravel_ssl_email: "admin@example.com"
  roles:
    - laravel
```

### With Specific Web Server

```yaml
---
- hosts: webservers
  become: yes
  vars:
    laravel_webserver_type: "apache2"  # or "openlitespeed"
    laravel_app_name: "my-laravel-app"
    laravel_app_repo: "https://github.com/user/my-laravel-app.git"
    laravel_domain: "myapp.example.com"
  roles:
    - laravel
```

### Per-Server Web Server (Inventory)

```yaml
webservers:
  hosts:
    nginx-server:
      ansible_host: 192.168.1.10
      laravel_webserver_type: "nginx"
    apache-server:
      ansible_host: 192.168.1.11
      laravel_webserver_type: "apache2"
    ols-server:
      ansible_host: 192.168.1.12
      laravel_webserver_type: "openlitespeed"
  vars:
    laravel_app_name: "my-laravel-app"
    laravel_app_repo: "https://github.com/user/my-laravel-app.git"
    laravel_domain: "myapp.example.com"
```

### With Inventory

```yaml
# inventories/production.yml
---
webservers:
  hosts:
    server1:
      ansible_host: 192.168.1.10
      ansible_user: ubuntu
    server2:
      ansible_host: 192.168.1.11
      ansible_user: ubuntu
  vars:
    laravel_app_name: "production-app"
    laravel_app_env: "production"
```

## What This Role Does

1. **System Updates**: Updates package lists and installs dependencies
2. **PHP Installation**: Installs PHP 8.2 with required extensions
3. **Nginx Installation**: Installs and configures Nginx
4. **MySQL Installation**: Installs MySQL and creates database
5. **Composer Installation**: Installs Composer globally
6. **Application Deployment**: Clones repository and installs dependencies
7. **Configuration**: Sets up environment and configuration files
8. **Services**: Configures and starts services
9. **SSL Setup**: Optional Let's Encrypt SSL configuration

## File Structure

```
laravel/
├── tasks/
│   └── main.yml          # Main task file
├── handlers/
│   └── main.yml          # Service handlers
├── templates/
│   ├── nginx.conf.j2     # Nginx configuration
│   ├── php-fpm.conf.j2   # PHP-FPM pool configuration
│   └── env.j2            # Laravel .env template
├── defaults/
│   └── main.yml          # Default variables
├── vars/
│   └── main.yml          # Role variables
├── meta/
│   └── main.yml          # Role metadata
└── README.md             # This file
```

## Usage

### 1. Configure Variables

Create `group_vars/webservers.yml` or pass variables in playbook:

```yaml
laravel_app_name: "myapp"
laravel_app_repo: "https://github.com/user/myapp.git"
laravel_domain: "myapp.example.com"
laravel_db_password: "{{ vault_db_password }}"  # Use Ansible Vault
```

### 2. Run Playbook

```bash
# Basic deployment
ansible-playbook -i inventories/production playbooks/laravel.yml

# With vault
ansible-playbook -i inventories/production playbooks/laravel.yml --ask-vault-pass

# Dry run (check mode)
ansible-playbook -i inventories/production playbooks/laravel.yml --check
```

### 3. Verify Deployment

```bash
# Check services
systemctl status nginx
systemctl status php8.2-fpm
systemctl status mysql

# Check application
curl -I http://your-domain.com
```

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Fix storage permissions
   sudo chown -R www-data:www-data /var/www/myapp/storage
   sudo chmod -R 775 /var/www/myapp/storage
   ```

2. **PHP Extensions Missing**
   ```bash
   # Install missing extensions
   sudo apt install php8.2-xml php8.2-mbstring php8.2-curl
   ```

3. **Database Connection Failed**
   ```bash
   # Check MySQL status
   sudo systemctl status mysql
   
   # Check database exists
   mysql -u root -p -e "SHOW DATABASES;"
   ```

4. **Nginx Configuration Error**
   ```bash
   # Test configuration
   sudo nginx -t
   
   # Check error logs
   sudo tail -f /var/log/nginx/error.log
   ```

### Logs

- **Nginx**: `/var/log/nginx/`
- **PHP-FPM**: `/var/log/php8.2-fpm.log`
- **MySQL**: `/var/log/mysql/`
- **Laravel**: `/var/www/myapp/storage/logs/`

## Security Notes

- Uses non-root user for application
- Configures firewall rules
- Sets secure file permissions
- Supports SSL/TLS encryption
- Uses Ansible Vault for secrets

## License

MIT

## Author

OpenOps Toolkit Contributors