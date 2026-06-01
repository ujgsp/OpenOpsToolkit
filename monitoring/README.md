# Monitoring Stack Documentation

Documentation for monitoring tools and setup.

## Available Tools

### Uptime Kuma
- **Purpose**: Website and service monitoring
- **Port**: 3001
- **Documentation**: [uptime-kuma/README.md](uptime-kuma/README.md)

### Grafana
- **Purpose**: Visualization and dashboards
- **Port**: 3000
- **Documentation**: [grafana/README.md](grafana/README.md)

### Prometheus
- **Purpose**: Metrics collection and storage
- **Port**: 9090
- **Documentation**: [prometheus/README.md](prometheus/README.md)

## Quick Start

### Docker Compose (Recommended)

```bash
cd monitoring
docker-compose up -d
```

### Manual Installation

See individual tool documentation for manual installation.

## Architecture

```
┌─────────────────┐
│   Uptime Kuma   │ → Website monitoring
├─────────────────┤
│   Prometheus    │ → Metrics collection
├─────────────────┤
│   Grafana       │ → Visualization
└─────────────────┘
```

## Ports

| Service     | Port | Description        |
|-------------|------|--------------------|
| Uptime Kuma | 3001 | Web interface      |
| Grafana     | 3000 | Dashboard          |
| Prometheus  | 9090 | Metrics API        |

## Configuration

### Environment Variables

```bash
# Uptime Kuma
UPTIME_KUMA_PORT=3001

# Grafana
GRAFANA_PORT=3000
GRAFANA_ADMIN_PASSWORD=admin

# Prometheus
PROMETHEUS_PORT=9090
```

### Docker Compose

```yaml
version: '3.8'

services:
  uptime-kuma:
    image: louislam/uptime-kuma:latest
    ports:
      - "3001:3001"
    volumes:
      - ./uptime-kuma/data:/app/data
    restart: always

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/config:/etc/prometheus
      - ./prometheus/data:/prometheus
    restart: always

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - ./grafana/data:/var/lib/grafana
    restart: always
```

## Usage

### Uptime Kuma
1. Access http://localhost:3001
2. Create admin account
3. Add monitors for your services

### Grafana
1. Access http://localhost:3000
2. Login with admin/admin
3. Add Prometheus data source
4. Import dashboards

### Prometheus
1. Access http://localhost:9090
2. Query metrics
3. Configure alerting rules

## Alerting

### Telegram Integration

Configure Telegram bot for alerts:

1. Create bot via @BotFather
2. Get bot token
3. Configure in monitoring tools
4. Set alert thresholds

### Email Alerts

Configure SMTP for email alerts:

```yaml
# Grafana SMTP config
smtp:
  host: smtp.gmail.com:587
  user: your-email@gmail.com
  password: your-password
  from_address: your-email@gmail.com
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Check if ports are in use
2. **Permission issues**: Check file permissions
3. **Docker issues**: Check Docker logs

### Logs

```bash
# Uptime Kuma
docker logs uptime-kuma

# Grafana
docker logs grafana

# Prometheus
docker logs prometheus
```

## License

MIT

## Author

OpenOps Toolkit Contributors