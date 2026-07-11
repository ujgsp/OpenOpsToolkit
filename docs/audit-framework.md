# Audit Framework

Ansible-based server audit framework for OpenOps Toolkit.

## Quick Start

```bash
# Audit all servers
ansible-playbook -i inventories/production/inventory.yml playbooks/audit.yml

# Audit only security checks
ansible-playbook -i inventories/production/inventory.yml playbooks/audit.yml -t audit_security

# Audit specific hosts
ansible-playbook -i inventories/production/inventory.yml playbooks/audit.yml -l webservers

# Use example inventory
ansible-playbook -i inventories/examples/audit.yml playbooks/audit.yml
```

## Architecture

```
roles/
  audit_core/          → Report generation (JSON + Markdown)
  audit_os/            → OS info, updates, unattended-upgrades
  audit_security/      → SSH, firewall, fail2ban, sudo, passwords, SUID
  audit_storage/       → Disk usage
  audit_services/      → Running services count
  audit_network/       → Open ports, connections, DNS, public IP
  audit_nginx/         → Config test, status, workers, error log
  audit_apache/        → Config test, status, modules, error log
  audit_openlitespeed/ → Config check, status
  audit_php/           → Version, FPM, modules, limits
  audit_mysql/         → Config, status, root pw, anon users, binlog
  audit_postgresql/    → Config, status, auth, SSL
  audit_docker/        → Version, status, containers, privileged
  audit_ssl/           → Cert expiry, certbot, TLS version
playbooks/audit.yml    → Entry point
plugins/filter/        → Format conversion (JSON → Markdown)
reports/               → Output directory (auto-created)
```

## Audit Modules

| Module | Checks | Tags |
|--------|--------|------|
| `audit_os` | System info, available updates, unattended-upgrades | `audit_os`, `os` |
| `audit_security` | SSH root/password/port, firewall, fail2ban, failed logins, sudo, password policy, SUID | `audit_security`, `security` |
| `audit_storage` | Disk usage on `/` | `audit_storage`, `storage` |
| `audit_services` | Running services count | `audit_services`, `services` |
| `audit_network` | Open ports, active connections, DNS resolution, public IP | `audit_network`, `network` |
| `audit_nginx` | Installation, config test, service status, workers, error log | `audit_nginx`, `nginx`, `webserver` |
| `audit_apache` | Installation, config test, service status, modules, error log | `audit_apache`, `apache`, `webserver` |
| `audit_openlitespeed` | Installation, service status, config check | `audit_openlitespeed`, `ols`, `webserver` |
| `audit_php` | Version, FPM, modules, upload_max_filesize, memory_limit | `audit_php`, `php` |
| `audit_mysql` | Installation, status, root password, anon users, max connections, binlog | `audit_mysql`, `mysql`, `database` |
| `audit_postgresql` | Installation, status, password auth, max connections, SSL | `audit_postgresql`, `postgresql`, `database` |
| `audit_docker` | Installation, status, version, containers, privileged, daemon config | `audit_docker`, `docker`, `container` |
| `audit_ssl` | Certificate expiry, certbot, TLS version | `audit_ssl`, `ssl` |

## Output

Reports are saved to `reports/audit-{timestamp}.{format}`.

### JSON Output

Each check produces:

```json
{
  "id": "ssh_root_login",
  "category": "security",
  "name": "SSH Root Login",
  "severity": "HIGH",
  "status": "PASS",
  "message": "Root login is disabled",
  "details": {"current_value": "no", "expected_value": "no"},
  "recommendation": "",
  "hostname": "web1",
  "timestamp": "2026-07-11T13:00:00Z"
}
```

### Status

| Status | Meaning |
|--------|---------|
| PASS | Check passed |
| WARN | Attention needed, not critical |
| FAIL | Needs remediation |

### Severity

| Level | Use Case |
|-------|----------|
| INFO | Informational |
| LOW | Best practice |
| MEDIUM | Moderate risk |
| HIGH | Significant risk |
| CRITICAL | Immediate action |

## Configuration

Override defaults in inventory vars:

```yaml
# inventories/production/group_vars/all.yml
audit_disk_warn_percent: 50
audit_disk_fail_percent: 80
audit_failed_logins_warn: 10
audit_failed_logins_fail: 50
audit_services_warn: 20
audit_services_fail: 40
audit_ports_warn: 10
audit_ports_fail: 20
audit_output_format: markdown  # json | markdown | yaml
```

## Extending

### Add a New Audit Module

1. Create `roles/audit_newmodule/tasks/main.yml`
2. Append checks to `audit_results` list variable
3. Add role to `playbooks/audit.yml`
4. Add tag for selective execution

### Data Model

Every check must produce:

```yaml
audit_results:
  - id: unique_check_id        # required
    category: security          # required
    name: Human Readable Name   # required
    severity: HIGH              # required: INFO|LOW|MEDIUM|HIGH|CRITICAL
    status: PASS                # required: PASS|WARN|FAIL
    message: Description        # required
    details: {}                 # optional: raw data
    recommendation: ""          # optional: remediation text
```
