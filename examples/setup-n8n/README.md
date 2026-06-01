# Setup n8n Workflow Automation

Deploy n8n for automating operational tasks with visual workflows.

## What You Get

- ✅ **n8n**: Visual workflow automation
- ✅ **PostgreSQL**: Database for workflows
- ✅ **SSL**: Secure HTTPS access
- ✅ **Webhooks**: Receive external events

## Requirements

- Ubuntu 22.04 LTS VPS (2GB+ RAM recommended)
- Docker installed (use `ansible/roles/docker` if needed)
- Domain name (optional, for SSL)

## Quick Start

### 1. Configure Inventory

Edit `ansible/inventories/production/hosts.yml`:

```yaml
# Add n8n server
n8n_servers:
  hosts:
    n8n1:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### 2. Configure Variables

Edit `ansible/inventories/production/group_vars/n8n_servers.yml`:

```yaml
n8n_domain: n8n.yourdomain.com
n8n_basic_auth_user: admin
n8n_basic_auth_password: your_secure_password
n8n_ssl_enabled: true
n8n_ssl_email: your@email.com
```

### 3. Deploy

```bash
ansible-playbook -i ansible/inventories/production ansible/roles/n8n/tasks/main.yml
```

### 4. Verify

```bash
# Check if n8n is running
ssh ubuntu@YOUR_SERVER_IP "docker ps | grep n8n"

# Check n8n logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n"

# Test HTTP response
curl -I http://YOUR_SERVER_IP:5678
```

### 5. Access n8n

Open http://YOUR_SERVER_IP:5678 (or https://n8n.yourdomain.com)

Login with credentials configured in step 2.

## What Happens

1. **Install Docker**: Ensures Docker is installed
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

## Troubleshooting

### Container Not Starting

```bash
# Check Docker logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n"

# Check Docker Compose
ssh ubuntu@YOUR_SERVER_IP "cd /opt/n8n && docker-compose ps"
```

### Cannot Access Web Interface

```bash
# Check if port is open
ssh ubuntu@YOUR_SERVER_IP "sudo netstat -tlnp | grep 5678"

# Check Nginx configuration
ssh ubuntu@YOUR_SERVER_IP "sudo nginx -t"

# Check Nginx logs
ssh ubuntu@YOUR_SERVER_IP "sudo tail -f /var/log/nginx/n8n-error.log"
```

### Database Connection Issues

```bash
# Check PostgreSQL status
ssh ubuntu@YOUR_SERVER_IP "docker exec n8n-postgres pg_isready"

# Check PostgreSQL logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n-postgres"
```

## Next Steps

- [Configure Telegram Alerts](../telegram-alert/README.md)
- [Deploy Laravel](../deploy-laravel/README.md)
- [Setup Monitoring](../setup-monitoring/README.md)