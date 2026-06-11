# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

No changes yet. All changes are documented in the releases below.

## [v0.4.0] - 2026-06-11

### Added
- Gatus uptime monitoring (replaced Uptime Kuma)
- Telegram alerting integration
- Flattened repository structure
- 12 Ansible roles for complete infrastructure automation
- Comprehensive testing and documentation
- Initial project structure
- Laravel Ansible role
- SSL Expired Alert n8n workflow
- GitHub issue templates
- GitHub discussion templates
- GitHub labels configuration
- Documentation (README, ROADMAP, CONTRIBUTING, SECURITY)
- Example scripts and configurations

### Changed
- Monitoring port from 3001 to 8080 (Gatus)
- Repository structure flattened (ansible/ directory removed)
- Updated all documentation and examples
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

### Breaking Changes
- Repository structure flattened (ansible/ directory removed)
- Monitoring port changed from 3001 to 8080 (Gatus)
- New variables: `vault_gatus_telegram_token`, `vault_gatus_telegram_chat_id`

### Upgrade Path
1. Update inventory to use new paths (no more ansible/ prefix)
2. Update monitoring variables (port 8080 instead of 3001)
3. Configure Telegram alerting variables

## [v0.1.0] - 2026-06-01

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

## [v0.0.1] - 2026-06-01

### Added
- Initial commit
- Project planning files