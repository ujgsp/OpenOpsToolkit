# Deploy Laravel to VPS

Deploy a Laravel application to Ubuntu 22.04 VPS with Nginx, PHP 8.2, and MySQL.

## What You Get

- ✅ Nginx web server
- ✅ PHP 8.2 with all required extensions
- ✅ MySQL database
- ✅ SSL/TLS via Let's Encrypt
- ✅ Firewall configured
- ✅ Supervisor for queue workers

## Requirements

- Ubuntu 22.04 LTS VPS (1GB+ RAM)
- SSH access with sudo privileges
- Domain name (optional, for SSL)

## Quick Start

### 1. Configure Inventory

Edit `ansible/inventories/production/inventory.yml`:

```yaml
webservers:
  hosts:
    web1:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 2. Configure Variables

Edit `ansible/inventories/production/group_vars/all.yml`:

```yaml
app_name: myapp
app_env: production
app_url: https://yourdomain.com
app_domain: yourdomain.com

db_name: laravel_db
db_user: laravel
db_password: your_secure_password

ssl_enabled: true
ssl_email: your@email.com
```

### 3. Deploy

```bash
# From repository root
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml
```

### 4. Verify

```bash
# Check if Nginx is running
ssh ubuntu@YOUR_SERVER_IP "systemctl status nginx"

# Check if PHP-FPM is running
ssh ubuntu@YOUR_SERVER_IP "systemctl status php8.2-fpm"

# Check if MySQL is running
ssh ubuntu@YOUR_SERVER_IP "systemctl status mysql"

# Test HTTP response
curl -I http://YOUR_SERVER_IP
```

## What Happens

1. **System Update**: Updates all packages
2. **Install Dependencies**: Installs Nginx, PHP 8.2, MySQL
3. **Configure Services**: Sets up Nginx, PHP-FPM, MySQL
4. **Deploy Application**: Clones repo, installs dependencies
5. **Setup SSL**: Configures Let's Encrypt (if domain provided)
6. **Configure Firewall**: Opens ports 22, 80, 443

## Troubleshooting

### Connection Timeout

```bash
# Check if SSH is accessible
ssh ubuntu@YOUR_SERVER_IP "echo 'SSH works'"

# Check firewall
ssh ubuntu@YOUR_SERVER_IP "sudo ufw status"
```

### Permission Denied

```bash
# Check SSH key permissions
chmod 600 ~/.ssh/id_rsa

# Check if user has sudo access
ssh ubuntu@YOUR_SERVER_IP "sudo whoami"
```

### Database Connection Failed

```bash
# Check MySQL status
ssh ubuntu@YOUR_SERVER_IP "systemctl status mysql"

# Check database exists
ssh ubuntu@YOUR_SERVER_IP "mysql -u root -p -e 'SHOW DATABASES;'"
```

## Next Steps

- [Setup Monitoring](../setup-monitoring/README.md)
- [Setup n8n Automation](../setup-n8n/README.md)
- [Configure Telegram Alerts](../telegram-alert/README.md)