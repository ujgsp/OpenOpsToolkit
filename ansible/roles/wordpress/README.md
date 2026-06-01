# Ansible Role: WordPress

Deploy WordPress on Ubuntu 22.04 with Nginx, PHP-FPM, and MySQL.

## Requirements

- Ubuntu 22.04 LTS
- Minimum 1GB RAM
- SSH access with sudo privileges
- Domain name (optional, for SSL)

## Role Variables

### Required Variables

```yaml
# Application
wp_app_name: "mysite"                    # Application name
wp_domain: "example.com"                # Domain name

# Database
wp_db_name: "wordpress_db"              # Database name
wp_db_user: "wordpress"                 # Database user
wp_db_password: "secure_password"       # Database password
```

### Optional Variables

```yaml
# PHP
wp_php_version: "8.2"                   # PHP version
wp_php_memory_limit: "256M"             # Memory limit

# WordPress
wp_version: "latest"                    # WordPress version
wp_table_prefix: "wp_"                  # Database table prefix
wp_admin_user: "admin"                  # Admin username
wp_admin_password: "admin_password"     # Admin password
wp_admin_email: "admin@example.com"     # Admin email

# SSL
wp_ssl_enabled: false                   # Enable SSL
wp_ssl_email: "admin@example.com"       # Email for Let's Encrypt
```

## Dependencies

None

## Example Playbook

```yaml
---
- hosts: webservers
  become: yes
  vars:
    wp_app_name: "my-wordpress-site"
    wp_domain: "blog.example.com"
    wp_ssl_enabled: true
    wp_ssl_email: "admin@example.com"
  roles:
    - wordpress
```

## What This Role Does

1. **System Updates**: Updates package lists and installs dependencies
2. **PHP Installation**: Installs PHP 8.2 with WordPress extensions
3. **Nginx Installation**: Installs and configures Nginx
4. **MySQL Installation**: Installs MySQL and creates database
5. **WordPress Installation**: Downloads and configures WordPress
6. **Security**: Configures secure file permissions and firewall

## License

MIT

## Author

OpenOps Toolkit Contributors