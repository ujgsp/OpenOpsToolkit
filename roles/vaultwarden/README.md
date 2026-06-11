# Ansible Role: Vaultwarden

Deploy Vaultwarden (Bitwarden compatible password manager) on Ubuntu 22.04.

## Requirements

- Ubuntu 22.04 LTS
- Minimum 1GB RAM
- SSH access with sudo privileges
- Docker installed (or use docker role first)

## Role Variables

### Required Variables

```yaml
vaultwarden_domain: "vault.example.com"  # Domain name
vaultwarden_admin_token: "secure_token"  # Admin token
```

### Optional Variables

```yaml
# Vaultwarden
vaultwarden_version: "latest"           # Vaultwarden version
vaultwarden_port: 8080                  # Web UI port
vaultwarden_data_dir: "/opt/vaultwarden"  # Data directory

# Features
vaultwarden_signups_allowed: true       # Allow signups
vaultwarden_invitations_allowed: true   # Allow invitations
vaultwarden_admin_enabled: true         # Enable admin panel

# Email
vaultwarden_smtp_host: ""              # SMTP host
vaultwarden_smtp_port: 587            # SMTP port
vaultwarden_smtp_security: "starttls" # SMTP security
vaultwarden_smtp_username: ""         # SMTP username
vaultwarden_smtp_password: ""         # SMTP password

# SSL
vaultwarden_ssl_enabled: true         # Enable SSL
vaultwarden_ssl_email: "admin@example.com"  # Email for Let's Encrypt
```

## Dependencies

- docker (install separately or use docker role)

## Example Playbook

```yaml
---
- hosts: webservers
  become: yes
  vars:
    vaultwarden_domain: "vault.example.com"
    vaultwarden_admin_token: "{{ vault_admin_token }}"
    vaultwarden_ssl_enabled: true
    vaultwarden_ssl_email: "admin@example.com"
  roles:
    - docker
    - vaultwarden
```

## What This Role Does

1. **Docker Setup**: Ensures Docker is installed and running
2. **Directory Structure**: Creates necessary directories
3. **Docker Compose**: Deploys Vaultwarden with Docker Compose
4. **Nginx Configuration**: Sets up reverse proxy
5. **SSL Setup**: Optional Let's Encrypt SSL
6. **Admin Panel**: Configures admin access

## Access

After deployment:
- URL: `https://vault.example.com`
- Admin Panel: `https://vault.example.com/admin`
- Admin Token: Configured token

## License

MIT

## Author

OpenOps Toolkit Contributors