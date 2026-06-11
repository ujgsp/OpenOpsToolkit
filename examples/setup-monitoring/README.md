# Setup Monitoring Stack

Deploy Uptime Kuma, Grafana, and Prometheus for monitoring your servers and websites.

## What You Get

- ✅ **Uptime Kuma**: Monitor website availability
- ✅ **Grafana**: Visualize metrics and dashboards
- ✅ **Prometheus**: Collect and store metrics
- ✅ **Node Exporter**: System metrics (CPU, RAM, Disk)

## Requirements

- Ubuntu 22.04 LTS VPS (2GB+ RAM recommended)
- Docker installed (use `roles/docker` if needed)

## Quick Start

### 1. Navigate to Monitoring Directory

```bash
cd monitoring
```

### 2. Start Monitoring Stack

```bash
docker-compose up -d
```

### 3. Verify Services

```bash
# Check all containers are running
docker-compose ps

# Check Uptime Kuma
curl http://localhost:3001

# Check Grafana
curl http://localhost:3000/api/health

# Check Prometheus
curl http://localhost:9090/-/healthy
```

### 4. Access Dashboards

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Uptime Kuma | http://YOUR_IP:3001 | Create on first visit |
| Grafana | http://YOUR_IP:3000 | admin / admin |
| Prometheus | http://YOUR_IP:9090 | No auth |

## Configuration

### Add Website to Monitor (Uptime Kuma)

1. Open http://YOUR_IP:3001
2. Create admin account
3. Click "Add New Monitor"
4. Select "HTTP(s)"
5. Enter URL: https://yourwebsite.com
6. Set interval: 60 seconds
7. Click "Save"

### Add Telegram Notification (Uptime Kuma)

1. Go to Settings → Notifications
2. Click "Setup Notification"
3. Select "Telegram"
4. Enter Bot Token (from @BotFather)
5. Enter Chat ID (from @userinfobot)
6. Click "Save"

### Import Grafana Dashboard

1. Open http://YOUR_IP:3000
2. Login with admin/admin
3. Go to Dashboards → Import
4. Enter dashboard ID: 1860 (Node Exporter Full)
5. Select Prometheus data source
6. Click "Import"

## What's Included

### Docker Compose Services

```yaml
services:
  uptime-kuma:    # Website monitoring
  prometheus:     # Metrics collection
  grafana:        # Visualization
  node-exporter:  # System metrics
```

### Ports

| Port | Service |
|------|---------|
| 3001 | Uptime Kuma |
| 3000 | Grafana |
| 9090 | Prometheus |
| 9100 | Node Exporter |

## Troubleshooting

### Container Not Starting

```bash
# Check logs
docker-compose logs -f

# Restart specific service
docker-compose restart uptime-kuma
```

### Port Already in Use

```bash
# Check what's using the port
sudo netstat -tlnp | grep :3001

# Stop conflicting service
sudo systemctl stop conflicting-service
```

### Permission Issues

```bash
# Fix data directory permissions
sudo chown -R 1000:1000 monitoring/uptime-kuma/data
sudo chown -R 472:472 monitoring/grafana/data
```

## Next Steps

- [Configure Telegram Alerts](../telegram-alert/README.md)
- [Deploy Laravel](../deploy-laravel/README.md)
- [Setup n8n Automation](../setup-n8n/README.md)