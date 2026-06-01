# OpenOps Toolkit

**Open Source DevOps Toolkit for Small Teams**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Issues](https://img.shields.io/github/issues/openops-toolkit/openops-toolkit.svg)](https://github.com/openops-toolkit/openops-toolkit/issues)
[![GitHub Stars](https://img.shields.io/github/stars/openops-toolkit/openops-toolkit.svg)](https://github.com/openops-toolkit/openops-toolkit/stargazers)

> 🚀 Kumpulan automation, deployment, monitoring, dan workflow operasional untuk developer, freelancer, software house kecil, UMKM digital, dan instansi.

## 📋 Overview

OpenOps Toolkit menyediakan:
- **Ansible Roles** untuk deployment aplikasi (Laravel, WordPress, n8n, dll)
- **n8n Workflows** untuk automation dan monitoring
- **Monitoring Stack** documentation (Uptime Kuma, Grafana, Prometheus)
- **AI Ops** tools untuk incident analysis
- **Scripts** untuk operasional sehari-hari

## 🎯 Target Users

- 👨‍💻 Laravel Developer
- 🌐 WordPress Developer
- 💼 Freelancer
- 🏢 Software House Kecil
- 🏛️ Tim IT Pemerintah Daerah
- 🏪 UMKM Digital
- 🚀 Startup Kecil

## 🚀 Quick Start

### Prerequisites
- Ubuntu Server 22.04 LTS (minimal 1 VPS)
- SSH Access
- Ansible 2.9+ (di local machine)
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/openops-toolkit/openops-toolkit.git
cd openops-toolkit

# Install Ansible (jika belum)
pip install ansible

# Deploy Laravel ke server
cd ansible
ansible-playbook -i inventories/production playbooks/laravel.yml
```

## 📁 Repository Structure

```
openops-toolkit/
├── ansible/                    # Ansible roles dan playbooks
│   ├── roles/
│   │   ├── laravel/           # Deploy Laravel app
│   │   ├── wordpress/         # Deploy WordPress
│   │   ├── n8n/               # Deploy n8n automation
│   │   ├── docker/            # Install Docker
│   │   ├── openvpn/           # Setup OpenVPN
│   │   └── vaultwarden/       # Deploy Vaultwarden
│   ├── inventories/           # Inventory files
│   ├── playbooks/             # Playbook files
│   └── docs/                  # Ansible documentation
│
├── n8n/                        # n8n workflow templates
│   ├── workflows/
│   │   ├── monitoring/        # SSL, Domain, Website alerts
│   │   ├── developer/         # GitHub notifications
│   │   ├── telegram/          # Telegram bots
│   │   └── productivity/      # Work automation
│   ├── templates/             # Workflow templates
│   └── docs/                  # n8n documentation
│
├── monitoring/                 # Monitoring stack docs
│   ├── uptime-kuma/           # Uptime Kuma setup
│   ├── grafana/               # Grafana dashboards
│   ├── prometheus/            # Prometheus config
│   └── docs/                  # Monitoring guides
│
├── scripts/                    # Utility scripts
├── docs/                       # General documentation
│   ├── deployment/            # Deployment guides
│   ├── automation/            # Automation guides
│   ├── monitoring/            # Monitoring guides
│   ├── aiops/                 # AI Ops documentation
│   └── roadmap/               # Project roadmap
│
├── examples/                   # Example configurations
├── ROADMAP.md                  # Project roadmap
├── CONTRIBUTING.md             # Contribution guidelines
├── SECURITY.md                 # Security policy
└── README.md                   # This file
```

## 📚 Documentation

### Deployment Guides
- [Laravel Deployment](docs/deployment/laravel.md)
- [WordPress Deployment](docs/deployment/wordpress.md)
- [n8n Deployment](docs/deployment/n8n.md)

### Automation
- [n8n Workflow Templates](n8n/README.md)
- [Ansible Roles](ansible/README.md)

### Monitoring
- [Uptime Kuma Setup](monitoring/uptime-kuma/README.md)
- [Grafana Dashboards](monitoring/grafana/README.md)
- [Prometheus Setup](monitoring/prometheus/README.md)

### AI Ops
- [Incident Analysis](docs/aiops/incident-analysis.md)
- [GitHub Issue Summary](docs/aiops/github-summary.md)

## 🛠️ Usage Examples

### Deploy Laravel Application

```yaml
# ansible/playbooks/laravel.yml
---
- hosts: webservers
  become: yes
  roles:
    - docker
    - laravel
```

### Import n8n Workflow

1. Buka n8n dashboard
2. Klik "Import from File"
3. Pilih workflow dari `n8n/workflows/`
4. Configure credentials
5. Activate workflow

### Setup Monitoring

```bash
# Deploy Uptime Kuma
cd monitoring/uptime-kuma
docker-compose up -d

# Access dashboard
# http://your-server:3001
```

## 🤝 Contributing

Kami sangat welcome kontribusi! Silakan baca [CONTRIBUTING.md](CONTRIBUTING.md) untuk:
- Cara submit pull request
- Branch naming convention
- Issue template
- Coding standards

## 🔒 Security

Untuk melaporkan vulnerability, silakan baca [SECURITY.md](SECURITY.md).

## 📞 Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/openops-toolkit/openops-toolkit/issues)
- 💬 [Discussions](https://github.com/openops-toolkit/openops-toolkit/discussions)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by [Ansible Galaxy](https://galaxy.ansible.com/)
- Inspired by [Awesome n8n](https://github.com/n8n-io/awesome-n8n)
- Built for Indonesian developer community

---

**Made with ❤️ for Indonesian developers**