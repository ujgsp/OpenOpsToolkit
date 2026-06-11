# Setup Monitoring Stack

Deploy Gatus, Grafana, and Prometheus for monitoring your servers and websites.

## What You Get

- ✅ **Gatus**: Monitor website availability
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

# Check Gatus
curl http://localhost:8080

# Check Grafana
curl http://localhost:3000/api/health

# Check Prometheus
curl http://localhost:9090/-/healthy
```

### 4. Access Dashboards

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Gatus | http://YOUR_IP:8080 | Create on first visit |
| Grafana | http://YOUR_IP:3000 | admin / admin |
| Prometheus | http://YOUR_IP:9090 | No auth |

## Configuration

### Add Website to Monitor (Gatus)

Gatus uses a YAML configuration file. To add a monitor:

1. Edit the Gatus config file:
   ```bash
   sudo nano /opt/monitoring/gatus/config/config.yaml
   ```

2. Add a new endpoint under `endpoints`:
   ```yaml
   endpoints:
     - name: My Website
       url: "https://yourwebsite.com"
       interval: 60s
       conditions:
         - "[STATUS] == 200"
         - "[RESPONSE_TIME] < 500"
       alerts:
         - type: telegram
           failure-threshold: 3
           send-on-resolved: true
           description: "Website health check failed"
   ```

3. Restart Gatus container:
   ```bash
   docker-compose restart gatus
   ```

### Telegram Alerting Configuration

Telegram alerting is already configured in `config.yaml`:

```yaml
alerting:
  telegram:
    token: "YOUR_BOT_TOKEN"
    id: "YOUR_CHAT_ID"
```

To get the token and chat ID:
1. Create a Telegram bot via @BotFather
2. Get chat ID via @userinfobot or Telegram API
3. Update variables in inventory:
   ```yaml
   vault_gatus_telegram_token: "your-bot-token"
   vault_gatus_telegram_chat_id: "your-chat-id"
   ```
4. Redeploy with Ansible or update manually on server

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
  gatus:    # Website monitoring
  prometheus:     # Metrics collection
  grafana:        # Visualization
  node-exporter:  # System metrics
```

### Ports

| Port | Service |
|------|---------|
| 8080 | Gatus |
| 3000 | Grafana |
| 9090 | Prometheus |
| 9100 | Node Exporter |

## Troubleshooting

### Container Not Starting

```bash
# Check logs
docker-compose logs -f

# Restart specific service
docker-compose restart gatus
```

### Port Already in Use

```bash
# Check what's using the port
sudo netstat -tlnp | grep :8080

# Stop conflicting service
sudo systemctl stop conflicting-service
```

### Permission Issues

```bash
# Fix data directory permissions
sudo chown -R 1000:1000 monitoring/gatus/data
sudo chown -R 472:472 monitoring/grafana/data
```

## Next Steps

- [Configure Telegram Alerts](../telegram-alert/README.md)
- [Deploy Laravel](../deploy-laravel/README.md)
- [Setup n8n Automation](../setup-n8n/README.md)