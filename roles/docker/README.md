# Ansible Role: Docker

Install and configure Docker on Ubuntu 22.04.

## Requirements

- Ubuntu 22.04 LTS
- SSH access with sudo privileges

## Role Variables

### Optional Variables

```yaml
# Docker
docker_edition: "ce"                    # Docker edition (ce/ee)
docker_version: "latest"                # Docker version
docker_users: ["ubuntu"]                # Users to add to docker group

# Docker Compose
docker_compose_version: "2.20.0"        # Docker Compose version

# Registry
docker_registry_mirror: ""              # Registry mirror URL
```

## Dependencies

None

## Example Playbook

```yaml
---
- hosts: webservers
  become: yes
  vars:
    docker_users:
      - ubuntu
      - deploy
  roles:
    - docker
```

## What This Role Does

1. **Install Dependencies**: Required packages for Docker
2. **Add Docker GPG Key**: Official Docker GPG key
3. **Add Docker Repository**: Official Docker repository
4. **Install Docker**: Docker CE, CLI, and containerd
5. **Install Docker Compose**: Latest version
6. **Configure Users**: Add users to docker group
7. **Start Docker**: Enable and start Docker service

## Usage

After installation:

```bash
# Check Docker version
docker --version

# Run test container
docker run hello-world

# Check Docker Compose
docker compose version
```

## License

MIT

## Author

OpenOps Toolkit Contributors