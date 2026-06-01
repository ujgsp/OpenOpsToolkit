# Deploy Laravel to VPS

Complete guide to deploy a Laravel application to Ubuntu 22.04 VPS.

## Overview

This guide walks you through deploying a Laravel application to a VPS using Ansible. The deployment includes:

- Nginx web server
- PHP 8.2 with all required extensions
- MySQL database
- SSL/TLS via Let's Encrypt
- Firewall configuration
- Supervisor for queue workers

## Architecture

```
┌─────────────────┐
│   User/Browser   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      Nginx      │ ← SSL termination
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    PHP 8.2      │ ← Laravel application
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     MySQL       │ ← Database
└─────────────────┘
```

## Requirements

### Server Requirements

- **OS**: Ubuntu 22.04 LTS
- **RAM**: Minimum 1GB (2GB recommended)
- **Storage**: Minimum 20GB
- **Access**: SSH with sudo privileges

### Local Requirements

- **Git**: For cloning repository
- **Ansible**: 2.9+ (for running playbooks)
- **SSH Key**: For connecting to server

### Application Requirements

- **Laravel**: 8.x or higher
- **PHP Extensions**: mbstring, xml, curl, zip, gd, bcmath, intl
- **Database**: MySQL 8.0

## Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/ujgsp/OpenOpsToolkit.git
cd OpenOpsToolkit
```

### Step 2: Configure Inventory

Edit `ansible/inventories/production/hosts.yml`:

```yaml
webservers:
  hosts:
    web1:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Step 3: Configure Application

Edit `ansible/inventories/production/group_vars/all.yml`:

```yaml
# Application
app_name: myapp
app_env: production
app_url: https://yourdomain.com
app_domain: yourdomain.com

# Database
db_name: laravel_db
db_user: laravel
db_password: your_secure_password

# SSL
ssl_enabled: true
ssl_email: your@email.com
```

### Step 4: Deploy

```bash
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml
```

### Step 5: Verify Deployment

```bash
# Check services
ssh ubuntu@YOUR_SERVER_IP "systemctl status nginx"
ssh ubuntu@YOUR_SERVER_IP "systemctl status php8.2-fpm"
ssh ubuntu@YOUR_SERVER_IP "systemctl status mysql"

# Test HTTP response
curl -I http://YOUR_SERVER_IP

# Test HTTPS (if SSL enabled)
curl -I https://yourdomain.com
```

## Verification Checklist

After deployment, verify:

- [ ] Nginx is running and serving content
- [ ] PHP-FPM is processing PHP files
- [ ] MySQL is accepting connections
- [ ] Application is accessible via HTTP
- [ ] SSL certificate is valid (if enabled)
- [ ] Firewall allows ports 22, 80, 443
- [ ] Storage directory is writable
- [ ] Queue workers are running (if configured)

## Troubleshooting

### Issue: 502 Bad Gateway

**Symptoms**: Browser shows "502 Bad Gateway"

**Cause**: PHP-FPM is not running or not configured correctly

**Solution**:

```bash
# Check PHP-FPM status
ssh ubuntu@YOUR_SERVER_IP "systemctl status php8.2-fpm"

# Check PHP-FPM logs
ssh ubuntu@YOUR_SERVER_IP "tail -f /var/log/php8.2-fpm.log"

# Restart PHP-FPM
ssh ubuntu@YOUR_SERVER_IP "sudo systemctl restart php8.2-fpm"
```

### Issue: Database Connection Refused

**Symptoms**: Laravel shows "Connection refused" error

**Cause**: MySQL is not running or credentials are wrong

**Solution**:

```bash
# Check MySQL status
ssh ubuntu@YOUR_SERVER_IP "systemctl status mysql"

# Check MySQL logs
ssh ubuntu@YOUR_SERVER_IP "tail -f /var/log/mysql/error.log"

# Verify credentials
ssh ubuntu@YOUR_SERVER_IP "mysql -u laravel -p -e 'SHOW DATABASES;'"
```

### Issue: Permission Denied

**Symptoms**: Laravel shows permission errors in storage/logs

**Cause**: Incorrect file permissions

**Solution**:

```bash
# Fix storage permissions
ssh ubuntu@YOUR_SERVER_IP "sudo chown -R www-data:www-data /var/www/myapp/storage"
ssh ubuntu@YOUR_SERVER_IP "sudo chmod -R 775 /var/www/myapp/storage"

# Fix bootstrap/cache permissions
ssh ubuntu@YOUR_SERVER_IP "sudo chown -R www-data:www-data /var/www/myapp/bootstrap/cache"
ssh ubuntu@YOUR_SERVER_IP "sudo chmod -R 775 /var/www/myapp/bootstrap/cache"
```

### Issue: SSL Certificate Not Working

**Symptoms**: Browser shows "Not Secure" or certificate error

**Cause**: Let's Encrypt certificate not issued or expired

**Solution**:

```bash
# Check certificate status
ssh ubuntu@YOUR_SERVER_IP "sudo certbot certificates"

# Renew certificate
ssh ubuntu@YOUR_SERVER_IP "sudo certbot renew"

# Check Nginx SSL configuration
ssh ubuntu@YOUR_SERVER_IP "sudo nginx -t"
```

## Security Notes

### Firewall

The deployment configures UFW with:

- Port 22 (SSH) - Open
- Port 80 (HTTP) - Open
- Port 443 (HTTPS) - Open
- All other ports - Closed

### SSL/TLS

- Uses Let's Encrypt for free SSL certificates
- Automatic renewal configured via cron
- HSTS headers enabled

### File Permissions

- Application files owned by www-data
- Storage directory writable by web server
- Sensitive files not accessible via web

### Database

- MySQL root password secured
- Application user has limited privileges
- Remote access disabled by default

## Maintenance

### Regular Tasks

1. **Update packages**: `sudo apt update && sudo apt upgrade`
2. **Check logs**: `tail -f /var/log/nginx/error.log`
3. **Monitor disk space**: `df -h`
4. **Backup database**: `mysqldump -u root -p laravel_db > backup.sql`

### Backup Strategy

```bash
# Backup database
mysqldump -u root -p laravel_db > backup_$(date +%Y%m%d).sql

# Backup application files
tar -czf app_backup_$(date +%Y%m%d).tar.gz /var/www/myapp

# Backup to remote location
rsync -avz /var/www/myapp user@backup-server:/backups/
```

## Resources

- [Laravel Documentation](https://laravel.com/docs)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [PHP Documentation](https://www.php.net/docs.php)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)