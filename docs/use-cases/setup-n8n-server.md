# Setup n8n Server

Complete guide to deploy n8n workflow automation server.

## Overview

This guide walks you through deploying n8n, a visual workflow automation tool. n8n allows you to:

- Automate operational tasks
- Connect different services
- Create visual workflows
- Receive and send webhooks

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      n8n Server                              │
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

## Requirements

### Server Requirements

- **OS**: Ubuntu 22.04 LTS
- **RAM**: Minimum 2GB (4GB recommended)
- **Storage**: Minimum 30GB
- **Access**: SSH with sudo privileges

### Software Requirements

- **Docker**: 20.10+
- **Docker Compose**: 2.0+

## Installation

### Step 1: Install Docker (if not installed)

```bash
# Using Ansible role
ansible-playbook -i ansible/inventories/production ansible/roles/docker/tasks/main.yml

# Or manually
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl enable docker
sudo systemctl start docker
```

### Step 2: Configure Inventory

Edit `ansible/inventories/production/hosts.yml`:

```yaml
n8n_servers:
  hosts:
    n8n1:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Step 3: Configure Variables

Edit `ansible/inventories/production/group_vars/n8n_servers.yml`:

```yaml
n8n_domain: n8n.yourdomain.com
n8n_basic_auth_user: admin
n8n_basic_auth_password: your_secure_password
n8n_ssl_enabled: true
n8n_ssl_email: your@email.com
```

### Step 4: Deploy

```bash
ansible-playbook -i ansible/inventories/production ansible/roles/n8n/tasks/main.yml
```

### Step 5: Verify Deployment

```bash
# Check if n8n is running
ssh ubuntu@YOUR_SERVER_IP "docker ps | grep n8n"

# Check n8n logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n"

# Test HTTP response
curl -I http://YOUR_SERVER_IP:5678

# Test HTTPS (if SSL enabled)
curl -I https://n8n.yourdomain.com
```

### Step 6: Access n8n

Open http://YOUR_SERVER_IP:5678 (or https://n8n.yourdomain.com)

Login with credentials configured in step 3.

## What Happens

1. **Install Docker**: Ensures Docker is installed and running
2. **Create Directories**: Creates n8n data directories
3. **Deploy n8n**: Starts n8n with Docker Compose
4. **Configure Nginx**: Sets up reverse proxy
5. **Setup SSL**: Configures Let's Encrypt (if domain provided)

## Import Workflows

### SSL Expired Alert

1. Open n8n dashboard
2. Click **Import from File**
3. Select `n8n/workflows/monitoring/ssl-expired-alert.json`
4. Configure Telegram credentials
5. Update domain list
6. Activate workflow

### Domain Expired Alert

1. Import `n8n/workflows/monitoring/domain-expired-alert.json`
2. Configure WHOIS API key
3. Update domain list
4. Activate workflow

### Website Down Alert

1. Import `n8n/workflows/monitoring/website-down-alert.json`
2. Configure Telegram credentials
3. Update URL list
4. Activate workflow

## Verification Checklist

After deployment, verify:

- [ ] n8n container is running
- [ ] PostgreSQL container is running
- [ ] n8n web interface is accessible
- [ ] Can login with configured credentials
- [ ] Can import workflows
- [ ] Can execute workflows
- [ ] SSL certificate is valid (if enabled)

## Troubleshooting

### Issue: Container Not Starting

**Symptoms**: Container exits immediately after starting

**Solution**:

```bash
# Check Docker logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n"

# Check Docker Compose
ssh ubuntu@YOUR_SERVER_IP "cd /opt/n8n && docker-compose ps"

# Restart containers
ssh ubuntu@YOUR_SERVER_IP "cd /opt/n8n && docker-compose restart"
```

### Issue: Cannot Access Web Interface

**Symptoms**: Connection refused or timeout

**Solution**:

```bash
# Check if port is open
ssh ubuntu@YOUR_SERVER_IP "sudo netstat -tlnp | grep 5678"

# Check Nginx configuration
ssh ubuntu@YOUR_SERVER_IP "sudo nginx -t"

# Check Nginx logs
ssh ubuntu@YOUR_SERVER_IP "sudo tail -f /var/log/nginx/n8n-error.log"
```

### Issue: Database Connection Issues

**Symptoms**: n8n shows database connection error

**Solution**:

```bash
# Check PostgreSQL status
ssh ubuntu@YOUR_SERVER_IP "docker exec n8n-postgres pg_isready"

# Check PostgreSQL logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n-postgres"

# Restart PostgreSQL
ssh ubuntu@YOUR_SERVER_IP "cd /opt/n8n && docker-compose restart postgres"
```

### Issue: SSL Certificate Not Working

**Symptoms**: Browser shows "Not Secure" or certificate error

**Solution**:

```bash
# Check certificate status
ssh ubuntu@YOUR_SERVER_IP "sudo certbot certificates"

# Renew certificate
ssh ubuntu@YOUR_SERVER_IP "sudo certbot renew"

# Check Nginx SSL configuration
ssh ubuntu@YOUR_SERVER_IP "sudo nginx -t"
```

## Maintenance

### Regular Tasks

1. **Update images**: `docker-compose pull && docker-compose up -d`
2. **Check logs**: `docker-compose logs -f`
3. **Monitor disk space**: `df -h`
4. **Backup data**: See backup section

### Backup Strategy

```bash
# Backup n8n data
tar -czf n8n-backup.tar.gz /opt/n8n/data

# Backup PostgreSQL data
docker exec n8n-postgres pg_dump -U n8n n8n > n8n-db-backup.sql

# Backup to remote location
rsync -avz /opt/n8n/ user@backup-server:/backups/n8n/
```

### Update Stack

```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d

# Check for updates
docker-compose images
```

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community](https://community.n8n.io/)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)