# Uptime Kuma

Self-hosted monitoring tool for websites and services.

## Overview

Uptime Kuma is a fancy self-hosted monitoring tool similar to "Uptime Robot". It monitors your websites and services and notifies you when they go down.

## Features

- **Monitor Types**: HTTP(s), TCP, DNS, Docker, Steam Game Server, and more
- **Notifications**: Telegram, Discord, Slack, Email, Webhook, and 90+ services
- **Dashboard**: Beautiful and responsive dashboard
- **Status Pages**: Public status pages for your services
- **Multi-language**: Support for 20+ languages

## Quick Start

### Docker Compose (Recommended)

```bash
# Create directory
mkdir -p /opt/uptime-kuma
cd /opt/uptime-kuma

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: always
    ports:
      - "3001:3001"
    volumes:
      - ./data:/app/data
    environment:
      - UPTIME_KUMA_PORT=3001
EOF

# Start service
docker-compose up -d

# Access dashboard
# http://your-server-ip:3001
```

### Manual Installation

```bash
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Clone repository
git clone https://github.com/louislam/uptime-kuma.git
cd uptime-kuma

# Install dependencies
npm install

# Start service
node server.js
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `UPTIME_KUMA_PORT` | 3001 | Web interface port |
| `UPTIME_KUMA_HOST` | 0.0.0.0 | Listen host |
| `DATA_DIR` | ./data | Data directory |

### Docker Compose with Nginx

```yaml
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    container_name: uptime-kuma
    restart: always
    ports:
      - "127.0.0.1:3001:3001"
    volumes:
      - ./data:/app/data
    networks:
      - monitoring

networks:
  monitoring:
    external: true
```

### Nginx Configuration

```nginx
server {
    listen 80;
    server_name status.example.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Usage

### First Setup

1. Access `http://your-server:3001`
2. Create admin account
3. Add your first monitor

### Adding Monitors

#### HTTP Monitor
1. Click "Add New Monitor"
2. Select "HTTP(s)" as monitor type
3. Enter URL: `https://example.com`
4. Set interval: 60 seconds
5. Click "Save"

#### TCP Monitor
1. Click "Add New Monitor"
2. Select "TCP" as monitor type
3. Enter hostname and port
4. Set interval: 60 seconds
5. Click "Save"

#### Docker Monitor
1. Click "Add New Monitor"
2. Select "Docker" as monitor type
3. Connect Docker socket
4. Select container
5. Click "Save"

### Notification Setup

#### Telegram
1. Create bot via @BotFather
2. Get bot token
3. Get chat ID (use @userinfobot)
4. Add notification in Uptime Kuma:
   - Type: Telegram
   - Bot Token: your-bot-token
   - Chat ID: your-chat-id

#### Discord
1. Create webhook in Discord channel
2. Copy webhook URL
3. Add notification in Uptime Kuma:
   - Type: Discord
   - Webhook URL: your-webhook-url

#### Email (SMTP)
1. Configure SMTP settings:
   - Type: Email
   - SMTP Host: smtp.gmail.com
   - SMTP Port: 587
   - Username: your-email@gmail.com
   - Password: your-app-password

### Status Pages

1. Go to "Status Pages"
2. Click "Add New Status Page"
3. Configure:
   - Title: "Service Status"
   - Description: "Current status of our services"
   - URL: /status
4. Add monitors to status page
5. Publish status page

## Monitoring Examples

### Website Monitoring
```
Name: Main Website
URL: https://example.com
Interval: 60 seconds
```

### API Monitoring
```
Name: API Health
URL: https://api.example.com/health
Interval: 30 seconds
Expected Status: 200
```

### Database Monitoring
```
Name: MySQL
Type: TCP
Host: localhost
Port: 3306
Interval: 60 seconds
```

## Backup

### Docker Backup
```bash
# Backup data directory
tar -czf uptime-kuma-backup.tar.gz /opt/uptime-kuma/data

# Restore
tar -xzf uptime-kuma-backup.tar.gz -C /
```

### Automated Backup Script
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/uptime-kuma"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/uptime-kuma-$DATE.tar.gz /opt/uptime-kuma/data

# Keep only last 7 backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

## Troubleshooting

### Common Issues

1. **Cannot access dashboard**
   - Check if container is running: `docker ps`
   - Check logs: `docker logs uptime-kuma`
   - Verify port is open: `netstat -tlnp | grep 3001`

2. **Notifications not working**
   - Verify notification credentials
   - Check notification logs in Uptime Kuma
   - Test notification manually

3. **High CPU usage**
   - Reduce monitor intervals
   - Check for too many monitors
   - Monitor server resources

### Logs
```bash
# Docker logs
docker logs -f uptime-kuma

# Container shell
docker exec -it uptime-kuma /bin/sh
```

## Security

### HTTPS with Let's Encrypt
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d status.example.com
```

### Firewall
```bash
# Allow only necessary ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Updates

### Docker Update
```bash
cd /opt/uptime-kuma
docker-compose pull
docker-compose up -d
```

### Manual Update
```bash
cd uptime-kuma
git pull
npm install
pm2 restart uptime-kuma
```

## Resources

- [Official Documentation](https://uptime.kuma.pet/)
- [GitHub Repository](https://github.com/louislam/uptime-kuma)
- [Docker Hub](https://hub.docker.com/r/louislam/uptime-kuma)

## License

MIT

## Author

OpenOps Toolkit Contributors