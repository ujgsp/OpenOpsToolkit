# Multi-Server Management

Manage multiple servers from a centralized location.

## Overview

Multi-server management allows you to:
- Manage multiple servers from a single control machine
- Organize servers into logical groups
- Deploy applications across multiple servers
- Synchronize configurations
- Monitor server health

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Control Machine                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Ansible    │  │   Scripts   │  │  Monitoring │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
└─────────┼─────────────────┼─────────────────┼───────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│   Web Servers   │ │  App Servers    │ │  DB Servers     │
│  ┌───────────┐  │ │  ┌───────────┐  │ │  ┌───────────┐  │
│  │  Nginx    │  │ │  │  PHP-FPM  │  │ │  │  MySQL    │  │
│  │  Laravel  │  │ │  │  Laravel  │  │ │  │  Redis    │  │
│  └───────────┘  │ │  └───────────┘  │ │  └───────────┘  │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

## Server Groups

### Web Servers
- Nginx reverse proxy
- SSL termination
- Static file serving
- Load balancing

### App Servers
- PHP-FPM
- Application code
- Queue workers
- Scheduler

### Database Servers
- MySQL/PostgreSQL
- Redis
- Backup management

### Monitoring Servers
- Prometheus
- Grafana
- Alertmanager

## Quick Start

### 1. Inventory Structure

```
ansible/inventories/
├── production/
│   ├── inventory.yml
│   ├── group_vars/
│   │   ├── all.yml
│   │   ├── webservers.yml
│   │   ├── appservers.yml
│   │   └── dbservers.yml
│   └── host_vars/
│       ├── web1.yml
│       ├── app1.yml
│       └── db1.yml
├── staging/
│   └── ...
└── development/
    └── ...
```

### 2. Basic Inventory

```yaml
# inventories/production/inventory.yml
all:
  children:
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
        web2:
          ansible_host: 192.168.1.11
    
    appservers:
      hosts:
        app1:
          ansible_host: 192.168.1.20
        app2:
          ansible_host: 192.168.1.21
    
    dbservers:
      hosts:
        db1:
          ansible_host: 192.168.1.30
```

### 3. Group Variables

```yaml
# inventories/production/group_vars/all.yml
---
# Common variables for all servers
ansible_user: ubuntu
ansible_ssh_private_key_file: ~/.ssh/id_rsa
ansible_python_interpreter: /usr/bin/python3

# Application settings
app_name: myapp
app_env: production
app_url: https://example.com

# Timezone
timezone: Asia/Jakarta
```

### 4. Deploy to Multiple Servers

```bash
# Deploy to all servers
ansible-playbook -i inventories/production playbooks/site.yml

# Deploy to specific group
ansible-playbook -i inventories/production playbooks/webservers.yml

# Deploy to specific host
ansible-playbook -i inventories/production playbooks/site.yml --limit web1
```

## Inventory Management

### Centralized Inventory

```yaml
# inventories/production/inventory.yml
all:
  children:
    # Web tier
    webservers:
      hosts:
        web1:
          ansible_host: 192.168.1.10
          nginx_worker_processes: 4
        web2:
          ansible_host: 192.168.1.11
          nginx_worker_processes: 4
    
    # Application tier
    appservers:
      hosts:
        app1:
          ansible_host: 192.168.1.20
          php_fpm_max_children: 50
        app2:
          ansible_host: 192.168.1.21
          php_fpm_max_children: 50
    
    # Database tier
    dbservers:
      hosts:
        db1:
          ansible_host: 192.168.1.30
          mysql_max_connections: 200
    
    # Monitoring
    monitoring:
      hosts:
        monitor1:
          ansible_host: 192.168.1.40
    
    # Load balancer
    loadbalancers:
      hosts:
        lb1:
          ansible_host: 192.168.1.5
    
  vars:
    ansible_user: ubuntu
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Group Variables

```yaml
# inventories/production/group_vars/webservers.yml
---
# Web server configuration
nginx_worker_processes: auto
nginx_worker_connections: 1024
nginx_client_max_body_size: 64M

# SSL configuration
ssl_enabled: true
ssl_certificate: /etc/ssl/certs/example.com.crt
ssl_certificate_key: /etc/ssl/private/example.com.key
```

```yaml
# inventories/production/group_vars/appservers.yml
---
# Application server configuration
php_version: "8.2"
php_memory_limit: 256M
php_fpm_max_children: 50
php_fpm_start_servers: 5
php_fpm_min_spare_servers: 5
php_fpm_max_spare_servers: 35

# Application settings
app_env: production
app_debug: false
app_log_level: error
```

```yaml
# inventories/production/group_vars/dbservers.yml
---
# Database server configuration
mysql_version: "8.0"
mysql_max_connections: 200
mysql_innodb_buffer_pool_size: 1G

# Backup settings
backup_enabled: true
backup_schedule: "0 2 * * *"
backup_retention_days: 7
```

### Host Variables

```yaml
# inventories/production/host_vars/web1.yml
---
# Specific configuration for web1
nginx_worker_processes: 8
nginx_worker_connections: 2048

# Custom settings
server_role: primary
server_location: jakarta
```

## Deployment Patterns

### Rolling Deployment

Deploy to servers one at a time:

```yaml
# playbooks/rolling-deploy.yml
---
- hosts: webservers
  serial: 1
  tasks:
    - name: Deploy application
      include_role:
        name: laravel
      
    - name: Health check
      uri:
        url: "http://{{ ansible_host }}/health"
        status_code: 200
      register: health_check
      until: health_check.status == 200
      retries: 30
      delay: 10
```

### Blue-Green Deployment

Deploy to inactive environment and switch:

```yaml
# playbooks/blue-green.yml
---
- hosts: webservers
  vars:
    active_env: "{{ 'blue' if app_env == 'green' else 'green' }}"
  tasks:
    - name: Deploy to inactive environment
      include_role:
        name: laravel
      vars:
        app_env: "{{ active_env }}"
    
    - name: Switch traffic
      template:
        src: nginx-upstream.conf.j2
        dest: /etc/nginx/conf.d/upstream.conf
      notify: reload nginx
```

### Canary Deployment

Deploy to subset of servers first:

```yaml
# playbooks/canary.yml
---
# Deploy to canary servers
- hosts: canary
  tasks:
    - name: Deploy to canary
      include_role:
        name: laravel
    
    - name: Monitor canary
      pause:
        minutes: 5
    
    - name: Check canary health
      uri:
        url: "http://{{ ansible_host }}/health"
      register: canary_health
      failed_when: canary_health.status != 200

# Deploy to remaining servers
- hosts: webservers:!canary
  tasks:
    - name: Deploy to production
      include_role:
        name: laravel
```

## Server Management

### Server Groups

```yaml
# Server group definitions
server_groups:
  webservers:
    - web1
    - web2
    - web3
  
  appservers:
    - app1
    - app2
  
  dbservers:
    - db1
    - db2
  
  monitoring:
    - monitor1
  
  loadbalancers:
    - lb1
```

### Health Checks

```yaml
# Health check configuration
health_checks:
  webservers:
    - url: "http://{{ ansible_host }}/health"
      expected_status: 200
      timeout: 10
  
  appservers:
    - url: "http://{{ ansible_host }}:9000/status"
      expected_status: 200
      timeout: 5
  
  dbservers:
    - command: "mysqladmin ping"
      timeout: 5
```

### Server Status

```bash
# Check server status
ansible all -m ping -i inventories/production

# Check disk usage
ansible all -m shell -a "df -h" -i inventories/production

# Check memory usage
ansible all -m shell -a "free -h" -i inventories/production

# Check running services
ansible all -m shell -a "systemctl list-units --type=service --state=running" -i inventories/production
```

## Load Balancing

### Nginx Load Balancer

```nginx
# nginx-loadbalancer.conf
upstream backend {
    least_conn;
    server 192.168.1.20:9000 weight=5;
    server 192.168.1.21:9000 weight=5;
    server 192.168.1.22:9000 backup;
}

server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### HAProxy Load Balancer

```
# haproxy.cfg
global
    maxconn 4096

defaults
    mode http
    timeout connect 5s
    timeout client 30s
    timeout server 30s

frontend http_front
    bind *:80
    default_backend http_back

backend http_back
    balance roundrobin
    server app1 192.168.1.20:9000 check
    server app2 192.168.1.21:9000 check
    server app3 192.168.1.22:9000 check backup
```

## Monitoring

### Multi-Server Monitoring

```yaml
# prometheus-multi.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets:
        - '192.168.1.10:9100'  # web1
        - '192.168.1.11:9100'  # web2
        - '192.168.1.20:9100'  # app1
        - '192.168.1.21:9100'  # app2
        - '192.168.1.30:9100'  # db1
```

### Alerting Rules

```yaml
# alerting-rules.yml
groups:
  - name: multi_server
    rules:
      - alert: ServerDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Server {{ $labels.instance }} is down"
      
      - alert: HighCPU
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU on {{ $labels.instance }}"
```

## Backup Strategy

### Centralized Backup

```yaml
# backup-config.yml
backup:
  strategy: centralized
  destination: /mnt/backup
  
  schedules:
    webservers:
      - path: /var/www
      - schedule: "0 2 * * *"
      - retention: 7
    
    dbservers:
      - type: mysql
      - schedule: "0 3 * * *"
      - retention: 30
    
    configs:
      - path: /etc
      - schedule: "0 1 * * 0"
      - retention: 90
```

### Backup Script

```bash
#!/bin/bash
# multi-server-backup.sh

SERVERS=("web1" "web2" "app1" "app2" "db1")
BACKUP_DIR="/mnt/backup/$(date +%Y%m%d)"

mkdir -p $BACKUP_DIR

for server in "${SERVERS[@]}"; do
    echo "Backing up $server..."
    rsync -avz -e ssh $server:/var/www $BACKUP_DIR/$server/
    rsync -avz -e ssh $server:/etc $BACKUP_DIR/$server/etc/
done

echo "Backup completed: $BACKUP_DIR"
```

## Security

### SSH Key Management

```yaml
# ssh-config.yml
ssh:
  key_type: ed25519
  key_file: ~/.ssh/id_ed25519
  
  authorized_keys:
    - ssh-ed25519 AAAA... control@machine
  
  config:
    PasswordAuthentication: no
    PermitRootLogin: no
```

### Firewall Rules

```yaml
# firewall-config.yml
firewall:
  rules:
    - name: SSH
      port: 22
      source: 192.168.1.0/24
    
    - name: HTTP
      port: 80
      source: 0.0.0.0/0
    
    - name: HTTPS
      port: 443
      source: 0.0.0.0/0
    
    - name: MySQL
      port: 3306
      source: 192.168.1.0/24
```

## Troubleshooting

### Common Issues

1. **Connection Timeout**
   - Check SSH connectivity
   - Verify firewall rules
   - Check network connectivity

2. **Permission Denied**
   - Verify SSH key permissions
   - Check user permissions
   - Verify sudo access

3. **Deployment Failures**
   - Check Ansible logs
   - Verify server requirements
   - Check disk space

### Debug Commands

```bash
# Test connectivity
ansible all -m ping -i inventories/production

# Check inventory
ansible-inventory -i inventories/production --list

# Dry run
ansible-playbook -i inventories/production playbooks/site.yml --check

# Verbose output
ansible-playbook -i inventories/production playbooks/site.yml -vvv
```

## Best Practices

### 1. Inventory Management
- Use consistent naming conventions
- Organize by environment (production, staging, dev)
- Use group_vars for shared configuration
- Use host_vars for specific configuration

### 2. Deployment
- Use rolling deployments for zero downtime
- Implement health checks
- Use version control for configurations
- Test in staging before production

### 3. Security
- Use SSH keys instead of passwords
- Implement least privilege principle
- Regular security updates
- Monitor for suspicious activity

### 4. Monitoring
- Monitor all servers
- Set up alerting
- Regular health checks
- Track performance metrics

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/tips_tricks/ansible_tips_tricks.html)
- [Multi-Tier Deployments](https://docs.ansible.com/ansible/latest/scenario_guides/guide_rolling_upgrade.html)

## License

MIT

## Author

OpenOps Toolkit Contributors