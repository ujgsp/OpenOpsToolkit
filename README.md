# OpenOps Toolkit

**Open Source DevOps Toolkit for Small Teams**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub Stars](https://img.shields.io/github/stars/ujgsp/OpenOpsToolkit.svg)](https://github.com/ujgsp/OpenOpsToolkit/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/ujgsp/OpenOpsToolkit.svg)](https://github.com/ujgsp/OpenOpsToolkit/issues)

> Deploy Laravel, setup monitoring, configure automation, and manage your VPS — all from one toolkit.

---

## What Can I Do With This?

✅ **Deploy Laravel** to VPS in minutes (Ubuntu 22.04 + Nginx + PHP 8.2 + MySQL)

✅ **Deploy WordPress** with one command

✅ **Setup n8n** workflow automation server

✅ **Install Docker** on any Ubuntu server

✅ **Setup OpenVPN** for secure remote access

✅ **Deploy Vaultwarden** as self-hosted password manager

✅ **Receive Telegram Alerts** when SSL expires, domain expires, or website goes down

✅ **Setup Monitoring** with Uptime Kuma, Grafana, and Prometheus

✅ **Analyze Incidents** with AI-powered log analysis

✅ **Manage Multiple Servers** from a single control machine

---

## Who Is This For?

| Who | Why |
|-----|-----|
| 👨‍💻 **Laravel Developer** | Deploy to VPS without DevOps knowledge |
| 🌐 **WordPress Developer** | Setup hosting for clients in minutes |
| 💼 **Freelancer** | Manage multiple client servers efficiently |
| 🏢 **Small Software House** | Standardize deployment process |
| 🏛️ **Government IT Team** | Follow best practices with clear documentation |
| 🚀 **Startup** | Start small, scale later |

---

## Why OpenOps Toolkit?

Enterprise DevOps tools are often:
- ❌ Too complex for small teams
- ❌ Require expensive infrastructure
- ❌ Steep learning curve
- ❌ Overkill for 1-5 servers

**OpenOps Toolkit** focuses on:
- ✅ **VPS murah** (starts from $5/month)
- ✅ **Simple deployment** (one command)
- ✅ **Clear documentation** (step-by-step guides)
- ✅ **Practical automation** (real-world workflows)
- ✅ **Small team friendly** (1-10 people)

---

## Quick Start

### Prerequisites

- Ubuntu Server 22.04 LTS (1 VPS)
- SSH access to your server
- Git installed on your computer

### 1. Clone Repository

```bash
git clone https://github.com/ujgsp/OpenOpsToolkit.git
cd OpenOpsToolkit
```

### 2. Deploy Laravel (Example)

```bash
# Edit inventory with your server IP
nano ansible/inventories/production/hosts.yml

# Deploy Laravel
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml
```

**Result**: Laravel app running at `http://your-server-ip`

### 3. Setup Monitoring

```bash
# Deploy monitoring stack
cd monitoring
docker-compose up -d
```

**Result**: 
- Uptime Kuma at `http://your-server-ip:3001`
- Grafana at `http://your-server-ip:3000`
- Prometheus at `http://your-server-ip:9090`

### 4. Import n8n Workflow

1. Open n8n dashboard
2. Click **Import from File**
3. Select `n8n/workflows/monitoring/ssl-expired-alert.json`
4. Configure Telegram bot token
5. Activate workflow

**Result**: Receive Telegram alerts when SSL certificate expires

---

## Screenshots

### Laravel Deployment

![Laravel Deployment](assets/screenshots/laravel-deploy-dashboard.png)

*Deploy Laravel to VPS with one command*

### Monitoring Dashboard

![Uptime Kuma](assets/screenshots/uptime-kuma.png)

*Monitor all your websites in one place*

### Telegram Notification

![Telegram Alert](assets/screenshots/telegram-alert.png)

*Get instant alerts when something goes wrong*

### n8n Workflow

![n8n Workflow](assets/screenshots/n8n-workflow.png)

*Automate operational tasks with visual workflows*

> 📸 **TODO**: Add actual screenshots before v1.0.0 release

---

## Available Modules

### Ansible Roles

| Role | Description | Requirements |
|------|-------------|--------------|
| `laravel` | Deploy Laravel app | Ubuntu 22.04, Nginx, PHP 8.2, MySQL |
| `wordpress` | Deploy WordPress | Ubuntu 22.04, Nginx, PHP 8.2, MySQL |
| `n8n` | Deploy n8n automation | Ubuntu 22.04, Docker |
| `docker` | Install Docker CE | Ubuntu 22.04 |
| `openvpn` | Setup OpenVPN server | Ubuntu 22.04 |
| `vaultwarden` | Deploy Vaultwarden | Ubuntu 22.04, Docker |

### n8n Workflows

| Workflow | Purpose | Schedule |
|----------|---------|----------|
| SSL Expired Alert | Monitor SSL certificates | Every 12 hours |
| Domain Expired Alert | Monitor domain expiry | Every 24 hours |
| Website Down Alert | Monitor website availability | Every 5 minutes |

### Monitoring Stack

| Tool | Purpose | Port |
|------|---------|------|
| Uptime Kuma | Website monitoring | 3001 |
| Grafana | Visualization | 3000 |
| Prometheus | Metrics collection | 9090 |

---

## Example Use Cases

### Use Case 1: Deploy Laravel for Client

**Scenario**: Freelancer needs to deploy Laravel app for client.

```bash
# 1. Get client's VPS credentials
# 2. Update inventory
nano ansible/inventories/production/hosts.yml

# 3. Deploy
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml

# 4. Done! Client's app is live
```

**Time**: 15 minutes

---

### Use Case 2: Setup Monitoring for Multiple Sites

**Scenario**: Software house needs to monitor 10 client websites.

```bash
# 1. Deploy monitoring stack
cd monitoring && docker-compose up -d

# 2. Import SSL alert workflow to n8n
# 3. Add all domains to monitor
# 4. Configure Telegram notifications
```

**Result**: Get alerts before SSL/domain expires

---

### Use Case 3: Setup VPN for Remote Team

**Scenario**: Government IT team needs secure remote access.

```bash
# 1. Deploy OpenVPN
ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml --limit vpn_servers

# 2. Generate client configs
# 3. Distribute to team members
```

**Result**: Team can securely access internal systems

---

## Roadmap

### ✅ v0.1.0 — MVP (Complete)
- [x] Laravel deployment
- [x] WordPress deployment
- [x] n8n deployment
- [x] Docker installation
- [x] OpenVPN setup
- [x] Vaultwarden deployment

### ✅ v0.2.0 — Monitoring (Complete)
- [x] Uptime Kuma documentation
- [x] Grafana setup
- [x] Prometheus configuration

### ✅ v0.3.0 — AI Ops (Complete)
- [x] Incident analysis prompts
- [x] GitHub issue summarization

### ✅ v0.4.0 — Multi-Server (Complete)
- [x] Multi-server architecture
- [x] Centralized inventory
- [x] Deployment orchestration

### 🚧 v1.0.0 — Stable Release (In Progress)
- [ ] Integration testing
- [ ] Video tutorials
- [ ] Community contributions
- [ ] Performance benchmarks

---

## Project Structure

```
OpenOpsToolkit/
├── ansible/              # Infrastructure automation
│   ├── roles/            # 6 Ansible roles
│   ├── playbooks/        # Deployment playbooks
│   └── inventories/      # Server inventory
├── n8n/                  # Workflow automation
├── monitoring/           # Monitoring stack
├── docs/                 # Documentation
├── examples/             # Quick start examples
└── scripts/              # Utility scripts
```

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Good First Issues

Look for issues labeled [`good first issue`](https://github.com/ujgsp/OpenOpsToolkit/labels/good%20first%20issue).

---

## Security

For security concerns, see [SECURITY.md](SECURITY.md).

---

## Support

- 📖 [Documentation](docs/)
- 🐛 [Report Bug](https://github.com/ujgsp/OpenOpsToolkit/issues/new?template=bug_report.md)
- 💡 [Request Feature](https://github.com/ujgsp/OpenOpsToolkit/issues/new?template=feature_request.md)
- 💬 [Discussions](https://github.com/ujgsp/OpenOpsToolkit/discussions)

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Acknowledgments

- Inspired by [Ansible Galaxy](https://galaxy.ansible.com/)
- Inspired by [Awesome n8n](https://github.com/n8n-io/awesome-n8n)
- Built for Indonesian developer community

---

**Made with ❤️ for developers who manage their own servers**