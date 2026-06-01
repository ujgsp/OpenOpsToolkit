# Prometheus

Open-source systems monitoring and alerting toolkit.

## Overview

Prometheus is an open-source systems monitoring and alerting toolkit originally built at SoundCloud. It collects metrics from configured targets at given intervals, evaluates rule expressions, displays the results, and can trigger alerts when specified conditions are observed.

## Features

- **Multi-dimensional data model**: Time series data identified by metric name and key/value pairs
- **PromQL**: Flexible query language
- **No reliance on distributed storage**: Single server nodes are autonomous
- **Time series collection**: Via a pull model over HTTP
- **Push support**: Via an intermediary gateway
- **Targets discovered**: Via service discovery or static configuration
- **Graphing and dashboarding**: Support via Grafana

## Quick Start

### Docker Compose (Recommended)

```bash
# Create directory
mkdir -p /opt/prometheus
cd /opt/prometheus

# Create configuration
mkdir -p config
cat > config/prometheus.yml << 'EOF'
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
EOF

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    restart: always
    ports:
      - "9090:9090"
    volumes:
      - ./config:/etc/prometheus
      - ./data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    networks:
      - monitoring

  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: always
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
    networks:
      - monitoring

networks:
  monitoring:
    external: true
EOF

# Start services
docker-compose up -d

# Access dashboard
# http://your-server-ip:9090
```

### Manual Installation

```bash
# Download Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Extract
tar xvfz prometheus-*.tar.gz
cd prometheus-*

# Create user
sudo useradd --no-create-home --shell /bin/false prometheus

# Create directories
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Copy binaries
sudo cp prometheus /usr/local/bin/
sudo cp promtool /usr/local/bin/

# Copy configuration
sudo cp prometheus.yml /etc/prometheus/

# Set permissions
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Create systemd service
sudo tee /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Start service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```

## Configuration

### prometheus.yml

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']

  - job_name: 'mysql'
    static_configs:
      - targets: ['mysqld-exporter:9104']
```

### Alert Rules

```yaml
# alert_rules.yml
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
          description: CPU usage is above 80% for 5 minutes

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High memory usage on {{ $labels.instance }}
          description: Memory usage is above 80% for 5 minutes

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 20
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: Low disk space on {{ $labels.instance }}
          description: Disk space is below 20%
```

## Exporters

### Node Exporter

```yaml
# docker-compose.yml
version: '3.8'

services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: always
    ports:
      - "9100:9100"
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.rootfs=/rootfs'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.mount-points-exclude=^/(sys|proc|dev|host|etc)($$|/)'
```

### Nginx Exporter

```yaml
# docker-compose.yml
version: '3.8'

services:
  nginx-exporter:
    image: nginx/nginx-prometheus-exporter:latest
    container_name: nginx-exporter
    restart: always
    ports:
      - "9113:9113"
    command:
      - '-nginx.scrape-uri=http://nginx:8080/stub_status'
```

### MySQL Exporter

```yaml
# docker-compose.yml
version: '3.8'

services:
  mysqld-exporter:
    image: prom/mysqld-exporter:latest
    container_name: mysqld-exporter
    restart: always
    ports:
      - "9104:9104"
    environment:
      - DATA_SOURCE_NAME="exporter:password@(mysql:3306)/"
```

## PromQL Examples

### Basic Queries

```promql
# CPU usage
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Disk usage
(node_filesystem_size_bytes - node_filesystem_avail_bytes) / node_filesystem_size_bytes * 100

# Network traffic
rate(node_network_receive_bytes_total[5m])
rate(node_network_transmit_bytes_total[5m])
```

### Advanced Queries

```promql
# Top 5 CPU usage instances
topk(5, 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100))

# Memory usage prediction
predict_linear(node_memory_MemAvailable_bytes[1h], 24*3600)

# HTTP request rate
sum(rate(http_requests_total[5m])) by (method, status)
```

## Alerting

### Alert Rules

```yaml
groups:
  - name: server_alerts
    rules:
      - alert: ServerDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: Server {{ $labels.instance }} is down

      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High CPU usage on {{ $labels.instance }}

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High memory usage on {{ $labels.instance }}
```

### Alertmanager

```yaml
# alertmanager.yml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@example.com'
  smtp_auth_username: 'alerts@example.com'
  smtp_auth_password: 'password'

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'web.hook'

receivers:
  - name: 'web.hook'
    email_configs:
      - to: 'admin@example.com'
        subject: 'Alert: {{ .GroupLabels.alertname }}'
        body: |
          {{ range .Alerts }}
          Alert: {{ .Annotations.summary }}
          Description: {{ .Annotations.description }}
          {{ end }}
```

## Backup

### Docker Backup
```bash
# Backup data directory
tar -czf prometheus-backup.tar.gz /opt/prometheus/data

# Restore
tar -xzf prometheus-backup.tar.gz -C /
```

### Automated Backup Script
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/prometheus"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/prometheus-$DATE.tar.gz /opt/prometheus/data

# Keep only last 7 backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

## Troubleshooting

### Common Issues

1. **Cannot access dashboard**
   - Check if container is running: `docker ps`
   - Check logs: `docker logs prometheus`
   - Verify port is open: `netstat -tlnp | grep 9090`

2. **Targets not showing up**
   - Check prometheus.yml configuration
   - Verify target endpoints are accessible
   - Check firewall rules

3. **High memory usage**
   - Reduce retention time
   - Optimize queries
   - Increase resources

### Logs
```bash
# Docker logs
docker logs -f prometheus

# Check configuration
docker exec prometheus promtool check config /etc/prometheus/prometheus.yml
```

## Security

### HTTPS with Let's Encrypt
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d prometheus.example.com
```

### Firewall
```bash
# Allow only necessary ports
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 9090/tcp  # Prometheus
sudo ufw allow 9100/tcp  # Node Exporter
sudo ufw enable
```

## Updates

### Docker Update
```bash
cd /opt/prometheus
docker-compose pull
docker-compose up -d
```

### Manual Update
```bash
# Download new version
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz

# Extract and replace binaries
tar xvfz prometheus-*.tar.gz
sudo cp prometheus-*/prometheus /usr/local/bin/
sudo cp prometheus-*/promtool /usr/local/bin/

# Restart service
sudo systemctl restart prometheus
```

## Resources

- [Official Documentation](https://prometheus.io/docs/)
- [GitHub Repository](https://github.com/prometheus/prometheus)
- [PromQL Examples](https://prometheus.io/docs/prometheus/latest/querying/examples/)

## License

Apache-2.0

## Author

OpenOps Toolkit Contributors