# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Laravel Ansible role
- SSL Expired Alert n8n workflow
- GitHub issue templates
- GitHub discussion templates
- GitHub labels configuration
- Documentation (README, ROADMAP, CONTRIBUTING, SECURITY)
- Example scripts and configurations

### Changed
- **Flatten repository structure**: Moved `ansible/` directory contents to repository root for simpler command execution (no more `cd ansible/` needed)
  - `ansible.cfg`, `playbooks/`, `roles/`, `inventories/` now at root
  - Updated all documentation references to reflect new paths
  - Maintained backward compatibility: all Ansible commands work from root
- **Replace Uptime Kuma with Gatus**: Monitoring stack now uses Gatus for uptime monitoring
  - More lightweight and developer-friendly
  - YAML-based configuration
  - Integrated Telegram alerting
  - Port changed from 3001 to 8080
  - Added `vault_gatus_telegram_token` and `vault_gatus_telegram_chat_id` variables

## [0.1.0] - 2026-06-01

### Added
- Project initialization
- Repository structure setup
- Basic documentation

### Changed
- None

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- None

## [0.0.1] - 2026-06-01

### Added
- Initial commit
- Project planning files

---

## Release Notes

## [v0.4.0] - 2026-06-11

### Added
- Gatus uptime monitoring (replaced Uptime Kuma)
- Telegram alerting integration
- Flattened repository structure
- 12 Ansible roles for complete infrastructure automation
- Comprehensive testing and documentation

### Changed
- Monitoring port from 3001 to 8080 (Gatus)
- Repository structure flattened (ansible/ directory removed)
- Updated all documentation and examples

### Breaking Changes
- Repository structure flattened (ansible/ directory removed)
- Monitoring port changed from 3001 to 8080 (Gatus)
- New variables: `vault_gatus_telegram_token`, `vault_gatus_telegram_chat_id`

### Upgrade Path
1. Update inventory to use new paths (no more ansible/ prefix)
2. Update monitoring variables (port 8080 instead of 3001)
3. Configure Telegram alerting variables

**Highlights**:
- Flattened repository structure for simpler command execution
- Replaced Uptime Kuma with Gatus for monitoring
- Telegram alerting integration
- 12 Ansible roles for complete infrastructure automation
- Comprehensive testing and documentation

**What's Included**:
- **12 Ansible roles**: laravel, wordpress, n8n, monitoring, docker, openvpn, vaultwarden, nginx, ufw, certbot, server-backup, server-hardening
- **Monitoring stack**: Gatus + Prometheus + Grafana + Alertmanager
- **Telegram alerting**: Integrated with Gatus for uptime notifications
- **Flattened structure**: All commands work from root directory
- **Production-ready**: CI/CD, code quality checks, release automation

**Breaking Changes**:
- Repository structure flattened (ansible/ directory removed)
- Monitoring port changed from 3001 to 8080 (Gatus)
- New variables: `vault_gatus_telegram_token`, `vault_gatus_telegram_chat_id`

**Upgrade Path**:
1. Update inventory to use new paths (no more ansible/ prefix)
2. Update monitoring variables (port 8080 instead of 3001)
3. Configure Telegram alerting variables

**Known Issues**:
- Service testing requires server with systemd (Docker container limitations)
- Production inventory needs to be filled with actual server IPs

**Contributors**:
- OpenOps Toolkit Team

---

### v0.1.0 (MVP)

**Release Date**: June 2026

**Highlights**:
- Laravel deployment automation with Ansible
- SSL certificate monitoring with n8n
- Comprehensive documentation
- GitHub community templates

**What's Included**:
- Ansible role for Laravel (Ubuntu 22.04 + Nginx + PHP-FPM + MySQL)
- n8n workflow for SSL certificate expiry alerts
- GitHub issue and discussion templates
- Project documentation (README, ROADMAP, CONTRIBUTING, SECURITY)
- Example configurations and scripts

**Breaking Changes**: None (initial release)

**Upgrade Path**: N/A (initial release)

**Known Issues**:
- Limited to Ubuntu 22.04
- Only Laravel role available (WordPress, n8n, Docker, OpenVPN, Vaultwarden coming in future releases)

**Contributors**:
- OpenOps Toolkit Team

---

## Future Releases

### v0.2.0 (Monitoring Stack) ✅ DONE
**Release Date**: June 2026

**Implemented Features**:
- Gatus uptime monitoring (replaced Uptime Kuma)
- Grafana dashboard templates
- Prometheus + Node Exporter setup
- Alerting rules configuration
- Telegram notification integration

### v0.3.0 (AI Ops) ✅ DONE
**Release Date**: June 2026

**Implemented Features**:
- AI incident summary (nginx/apache/laravel logs)
- AI GitHub issue summarization
- Log analysis automation

### v1.0.0 (Stable Release)
**Target**: Q3 2026

**Planned Features**:
- Integration testing suite
- Terraform cloud provisioning
- GitOps integration (ArgoCD/Flux)
- Video tutorials
- Community contributions

### v1.1.0 (Enhanced Features)
**Target**: Q4 2026

**Planned Features**:
- Additional Ansible roles (Redis, PostgreSQL, MongoDB)
- More n8n workflows (developer, productivity, telegram)
- Grafana dashboard templates
- Advanced monitoring alerts

### v2.0.0 (Enterprise Features)
**Target**: Q1 2027

**Planned Features**:
- RBAC (Role-Based Access Control)
- Audit logging
- Compliance tools
- Multi-cloud support (AWS, GCP, Azure)

---

## How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute to this project.

## Support

- **Issues**: [GitHub Issues](https://github.com/openops-toolkit/openops-toolkit/issues)
- **Discussions**: [GitHub Discussions](https://github.com/openops-toolkit/openops-toolkit/discussions)
- **Documentation**: [Project Documentation](docs/)

---

**Note**: This changelog follows the [Keep a Changelog](https://keepachangelog.com/) format.