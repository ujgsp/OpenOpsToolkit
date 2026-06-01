# Grafana

Open-source analytics and monitoring platform.

## Overview

Grafana is the open source analytics & monitoring solution for every database. It allows you to query, visualize, alert on, and understand your metrics.

## Features

- **Visualization**: Multiple chart types (graphs, gauges, tables, etc.)
- **Data Sources**: Support for Prometheus, InfluxDB, Elasticsearch, MySQL, and more
- **Dashboards**: Pre-built and custom dashboards
- **Alerting**: Flexible alerting rules
- **Plugins**: Extensible with plugins

## Quick Start

### Docker Compose (Recommended)

```bash
# Create directory
mkdir -p /opt/grafana
cd /opt/grafana

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: always
    ports:
      - "3000:3000"
    volumes:
      - ./data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    networks:
      - monitoring

networks:
  monitoring:
    external: true
EOF

# Start service
docker-compose up -d

# Access dashboard
# http://your-server-ip:3000
```

### Manual Installation

```bash
# Add GPG key
wget -q -O - https://apt.grafana.com/gpg.key | sudo apt-key add -

# Add repository
echo "deb https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Install
sudo apt update
sudo apt install grafana

# Start service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GF_SECURITY_ADMIN_PASSWORD` | admin | Admin password |
| `GF_USERS_ALLOW_SIGN_UP` | false | Allow user signup |
| `GF_SERVER_ROOT_URL` | http://localhost:3000 | Root URL |
| `GF_INSTALL_PLUGINS` | - | Plugins to install |

### Docker Compose with Nginx

```yaml
version: '3.8'

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: always
    ports:
      - "127.0.0.1:3000:3000"
    volumes:
      - ./data:/var/lib/grafana
      - ./provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
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
    server_name grafana.example.com;

    location / {
        proxy_pass http://localhost:3000;
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

1. Access `http://your-server:3000`
2. Login with admin/admin
3. Change admin password
4. Add data source

### Adding Data Sources

#### Prometheus
1. Go to Configuration → Data Sources
2. Click "Add data source"
3. Select "Prometheus"
4. Configure:
   - Name: Prometheus
   - URL: http://prometheus:9090
   - Access: Server (default)
5. Click "Save & Test"

#### InfluxDB
1. Go to Configuration → Data Sources
2. Click "Add data source"
3. Select "InfluxDB"
4. Configure:
   - Name: InfluxDB
   - URL: http://influxdb:8086
   - Database: mydb
5. Click "Save & Test"

### Creating Dashboards

#### New Dashboard
1. Click "+" → "Dashboard"
2. Click "Add new panel"
3. Select data source
4. Write query
5. Configure visualization
6. Click "Apply"

#### Import Dashboard
1. Click "+" → "Import"
2. Enter dashboard ID or upload JSON
3. Select data source
4. Click "Import"

### Pre-built Dashboards

#### Node Exporter Full
- Dashboard ID: 1860
- Description: Full node exporter dashboard

#### Docker Monitoring
- Dashboard ID: 893
- Description: Docker container monitoring

#### Nginx Monitoring
- Dashboard ID: 12708
- Description: Nginx status monitoring

## Data Sources

### Prometheus

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

### MySQL

```yaml
# grafana provisioning
apiVersion: 1

datasources:
  - name: MySQL
    type: mysql
    url: mysql:3306
    database: grafana
    user: grafana
    secureJsonData:
      password: password
```

## Alerting

### Alert Rules

1. Go to Alerting → Alert rules
2. Click "New alert rule"
3. Configure:
   - Name: High CPU Usage
   - Query: avg(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100 < 20
   - Condition: IS_BELOW 20
   - Evaluate every: 1m
   - For: 5m
4. Click "Save"

### Notification Channels

#### Telegram
1. Go to Alerting → Contact points
2. Click "New contact point"
3. Select "Telegram"
4. Configure:
   - Bot Token: your-bot-token
   - Chat ID: your-chat-id

#### Email
1. Go to Alerting → Contact points
2. Click "New contact point"
3. Select "Email"
4. Configure:
   - Email: admin@example.com
   - SMTP settings in grafana.ini

## Plugins

### Installing Plugins

```bash
# Docker
docker exec grafana-cli plugins install grafana-piechart-panel

# Manual
grafana-cli plugins install grafana-piechart-panel
```

### Recommended Plugins

- **Pie Chart**: grafana-piechart-panel
- **Worldmap**: grafana-worldmap-panel
- **Clock**: grafana-clock-panel
- **Alert List**: grafana-alertlist-panel

## Backup

### Docker Backup
```bash
# Backup data directory
tar -czf grafana-backup.tar.gz /opt/grafana/data

# Restore
tar -xzf grafana-backup.tar.gz -C /
```

### Automated Backup Script
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/grafana"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/grafana-$DATE.tar.gz /opt/grafana/data

# Keep only last 7 backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

## Troubleshooting

### Common Issues

1. **Cannot access dashboard**
   - Check if container is running: `docker ps`
   - Check logs: `docker logs grafana`
   - Verify port is open: `netstat -tlnp | grep 3000`

2. **Data source connection failed**
   - Verify data source URL
   - Check network connectivity
   - Verify credentials

3. **Dashboard not loading**
   - Check browser console for errors
   - Verify data source is working
   - Check Grafana logs

### Logs
```bash
# Docker logs
docker logs -f grafana

# Configuration file
/etc/grafana/grafana.ini
```

## Security

### HTTPS with Let's Encrypt
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d grafana.example.com
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
cd /opt/grafana
docker-compose pull
docker-compose up -d
```

### Manual Update
```bash
sudo apt update
sudo apt upgrade grafana
sudo systemctl restart grafana-server
```

## Resources

- [Official Documentation](https://grafana.com/docs/)
- [GitHub Repository](https://github.com/grafana/grafana)
- [Docker Hub](https://hub.docker.com/r/grafana/grafana)

## License

AGPL-3.0

## Author

OpenOps Toolkit Contributors