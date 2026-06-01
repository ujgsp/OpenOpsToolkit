# Ansible Role: OpenVPN

Deploy OpenVPN server on Ubuntu 22.04.

## Requirements

- Ubuntu 22.04 LTS
- Minimum 512MB RAM
- SSH access with sudo privileges
- Public IP address

## Role Variables

### Required Variables

```yaml
openvpn_server_ip: "your-server-ip"     # Server public IP
openvpn_port: 1194                       # OpenVPN port
openvpn_protocol: "udp"                  # Protocol (udp/tcp)
```

### Optional Variables

```yaml
# Network
openvpn_network: "10.8.0.0"            # VPN network
openvpn_netmask: "255.255.255.0"       # VPN netmask
openvpn_dns: "8.8.8.8,8.8.4.4"       # DNS servers

# Certificate
openvpn_key_size: 2048                 # Key size
openvpn_cipher: "AES-256-GCM"         # Cipher
openvpn_auth: "SHA256"                 # Auth algorithm

# Clients
openvpn_clients: ["client1"]           # Client names
openvpn_client_config_dir: "/etc/openvpn/ccd"  # Client config dir

# Advanced
openvpn_duplicate_cn: false            # Allow duplicate CN
openvpn_max_clients: 100              # Max clients
```

## Dependencies

None

## Example Playbook

```yaml
---
- hosts: vpn_servers
  become: yes
  vars:
    openvpn_server_ip: "203.0.113.10"
    openvpn_clients:
      - laptop
      - phone
      - tablet
  roles:
    - openvpn
```

## What This Role Does

1. **Install OpenVPN**: Install OpenVPN and EasyRSA
2. **Setup PKI**: Initialize PKI and generate certificates
3. **Generate Server Config**: Create server configuration
4. **Generate Client Configs**: Create client configuration files
5. **Configure Firewall**: Enable IP forwarding and NAT
6. **Start Service**: Enable and start OpenVPN

## Client Configuration

After deployment, client configs are in:
```
/etc/openvpn/clients/
```

Download the `.ovpn` file and import into OpenVPN client.

## License

MIT

## Author

OpenOps Toolkit Contributors