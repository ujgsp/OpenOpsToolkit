# Ansible Role: n8n

Deploy n8n workflow automation on Ubuntu 22.04 with Docker.

## Requirements

- Ubuntu 22.04 LTS
- Minimum 2GB RAM
- SSH access with sudo privileges
- Docker installed (or use docker role first)

## Role Variables

### Required Variables

```yaml
n8n_domain: "n8n.example.com"           # Domain name
n8n_basic_auth_user: "admin"            # Basic auth username
n8n_basic_auth_password: "password"     # Basic auth password
```

### Optional Variables

```yaml
# n8n
n8n_version: "latest"                   # n8n version
n8n_port: 5678                          # n8n port
n8n_protocol: "https"                   # Protocol
n8n_data_dir: "/opt/n8n"               # Data directory

# Database
n8n_db_type: "postgres"                 # Database type (postgres/sqlite)
n8n_db_name: "n8n"                     # Database name
n8n_db_user: "n8n"                     # Database user
n8n_db_password: "n8n_password"        # Database password

# SSL
n8n_ssl_enabled: true                   # Enable SSL
n8n_ssl_email: "admin@example.com"      # Email for Let's Encrypt

# Webhook
n8n_webhook_url: "https://n8n.example.com/webhook/"  # Webhook URL
```

## Dependencies

- docker (install separately or use docker role)

## Example Playbook

```yaml
---
- hosts: webservers
  become: yes
  vars:
    n8n_domain: "n8n.example.com"
    n8n_basic_auth_user: "admin"
    n8n_basic_auth_password: "{{ vault_n8n_password }}"
    n8n_ssl_enabled: true
    n8n_ssl_email: "admin@example.com"
  roles:
    - docker
    - n8n
```

## What This Role Does

1. **Docker Setup**: Ensures Docker is installed and running
2. **Directory Structure**: Creates necessary directories
3. **Docker Compose**: Deploys n8n with Docker Compose
4. **Nginx Configuration**: Sets up reverse proxy
5. **SSL Setup**: Optional Let's Encrypt SSL
6. **Database**: PostgreSQL for production use

## Access

After deployment:
- URL: `https://n8n.example.com`
- Username: `admin` (or configured value)
- Password: Configured password

## License

MIT

## Author

OpenOps Toolkit Contributors