# Setup Monitoring Stack

Complete guide to deploy Uptime Kuma, Grafana, and Prometheus for monitoring.

## Overview

This guide walks you through deploying a complete monitoring stack using Docker Compose. The stack includes:

- **Uptime Kuma**: Website and service monitoring
- **Grafana**: Visualization and dashboards
- **Prometheus**: Metrics collection and storage
- **Node Exporter**: System metrics

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Monitoring Stack                        │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Uptime Kuma │  │   Grafana   │  │  Prometheus │        │
│  │   :3001     │  │   :3000     │  │   :9090     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                 │                │
│         └────────────────┼─────────────────┘                │
│                          │                                  │
│                   ┌──────┴──────┐                          │
│                   │   Network   │                          │
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

### Step 2: Clone Repository

```bash
git clone https://github.com/ujgsp/OpenOpsToolkit.git
cd OpenOpsToolkit/monitoring
```

### Step 3: Start Monitoring Stack

```bash
docker-compose up -d
```

### Step 4: Verify Services

```bash
# Check all containers are running
docker-compose ps

# Check Uptime Kuma
curl http://localhost:3001

# Check Grafana
curl http://localhost:3000/api/health

# Check Prometheus
curl http://localhost:9090/-/healthy

# Check Node Exporter
curl http://localhost:9100/metrics
```

### Step 5: Access Dashboards

| Service | URL | Default Credentials |
|---------|-----|---------------------|
| Uptime Kuma | http://YOUR_IP:3001 | Create on first visit |
| Grafana | http://YOUR_IP:3000 | admin / admin |
| Prometheus | http://YOUR_IP:9090 | No auth |

## Configuration

### Uptime Kuma

#### Add Website Monitor

1. Open http://YOUR_IP:3001
2. Create admin account
3. Click "Add New Monitor"
4. Configure:
   - **Monitor Type**: HTTP(s)
   - **Name**: My Website
   - **URL**: https://yourwebsite.com
   - **Interval**: 60 seconds
5. Click "Save"

#### Add Telegram Notification

1. Go to Settings → Notifications
2. Click "Setup Notification"
3. Select "Telegram"
4. Configure:
   - **Bot Token**: From @BotFather
   - **Chat ID**: From @userinfobot
5. Click "Save"

### Grafana

#### Add Prometheus Data Source

1. Open http://YOUR_IP:3000
2. Login with admin/admin
3. Go to Configuration → Data Sources
4. Click "Add data source"
5. Select "Prometheus"
6. Configure:
   - **URL**: http://prometheus:9090
   - **Access**: Server (default)
7. Click "Save & Test"

#### Import Dashboard

1. Go to Dashboards → Import
2. Enter dashboard ID: **1860** (Node Exporter Full)
3. Select Prometheus data source
4. Click "Import"

### Prometheus

#### Edit Configuration

Edit `prometheus/prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets:
        - 'node-exporter:9100'
        - 'YOUR_SERVER_2:9100'
        - 'YOUR_SERVER_3:9100'
```

#### Add Alert Rules

Edit `prometheus/alert_rules.yml`:

```yaml
groups:
  - name: example
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High CPU usage on {{ $labels.instance }}
```

## Verification Checklist

After deployment, verify:

- [ ] All containers are running
- [ ] Uptime Kuma is accessible
- [ ] Grafana is accessible
- [ ] Prometheus is collecting metrics
- [ ] Node Exporter is reporting system metrics
- [ ] Telegram notifications are working
- [ ] Dashboards are showing data

## Troubleshooting

### Issue: Container Not Starting

**Symptoms**: Container exits immediately after starting

**Solution**:

```bash
# Check container logs
docker-compose logs -f

# Check specific service
docker-compose logs -f uptime-kuma

# Restart service
docker-compose restart uptime-kuma
```

### Issue: Port Already in Use

**Symptoms**: Error "port is already allocated"

**Solution**:

```bash
# Check what's using the port
sudo netstat -tlnp | grep :3001

# Stop conflicting service
sudo systemctl stop conflicting-service

# Or change port in docker-compose.yml
ports:
  - "3002:3001"  # Change host port
```

### Issue: Permission Denied

**Symptoms**: Container can't write to data directory

**Solution**:

```bash
# Fix permissions
sudo chown -R 1000:1000 monitoring/uptime-kuma/data
sudo chown -R 472:472 monitoring/grafana/data
sudo chown -R 65534:65534 monitoring/prometheus/data
```

### Issue: Grafana Can't Connect to Prometheus

**Symptoms**: "Bad Gateway" or "Connection refused" in Grafana

**Solution**:

```bash
# Check if Prometheus is running
docker-compose ps prometheus

# Check Prometheus logs
docker-compose logs prometheus

# Test connection from Grafana container
docker exec grafana wget -qO- http://prometheus:9090/-/healthy
```

## Maintenance

### Regular Tasks

1. **Update images**: `docker-compose pull && docker-compose up -d`
2. **Check logs**: `docker-compose logs -f`
3. **Monitor disk space**: `df -h`
4. **Backup data**: See backup section

### Backup Strategy

```bash
# Backup Uptime Kuma data
tar -czf uptime-kuma-backup.tar.gz monitoring/uptime-kuma/data

# Backup Grafana data
tar -czf grafana-backup.tar.gz monitoring/grafana/data

# Backup Prometheus data
tar -czf prometheus-backup.tar.gz monitoring/prometheus/data

# Backup to remote location
rsync -avz monitoring/ user@backup-server:/backups/monitoring/
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

- [Uptime Kuma Documentation](https://uptime.kuma.pet/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Node Exporter Documentation](https://prometheus.io/docs/guides/node-exporter/)