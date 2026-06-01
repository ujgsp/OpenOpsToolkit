# Setup OpenVPN Server

Complete guide to deploy OpenVPN server for secure remote access.

## Overview

This guide walks you through deploying an OpenVPN server. OpenVPN provides:

- Secure remote access to internal networks
- Encrypted communication
- Client certificate authentication
- Multi-platform support

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      OpenVPN Server                          │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   OpenVPN   │  │   Firewall  │  │   Routing   │        │
│  │   :1194     │  │    (UFW)    │  │   (NAT)     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                 │                │
│         └────────────────┼─────────────────┘                │
│                          │                                  │
│                   ┌──────┴──────┐                          │
│                   │   Clients   │                          │
│                   └─────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

### Server Requirements

- **OS**: Ubuntu 22.04 LTS
- **RAM**: Minimum 512MB
- **Storage**: Minimum 10GB
- **Access**: SSH with sudo privileges
- **Network**: Public IP address

### Client Requirements

- **OS**: Windows, macOS, Linux, iOS, Android
- **Software**: OpenVPN client

## Installation

### Step 1: Configure Inventory

Edit `ansible/inventories/production/hosts.yml`:

```yaml
vpn_servers:
  hosts:
    vpn1:
      ansible_host: YOUR_SERVER_IP
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Step 2: Configure Variables

Edit `ansible/inventories/production/group_vars/vpn_servers.yml`:

```yaml
openvpn_server_ip: YOUR_SERVER_IP
openvpn_port: 1194
openvpn_protocol: udp
openvpn_clients:
  - laptop
  - phone
  - tablet
```

### Step 3: Deploy

```bash
ansible-playbook -i ansible/inventories/production ansible/roles/openvpn/tasks/main.yml
```

### Step 4: Verify Deployment

```bash
# Check OpenVPN status
ssh ubuntu@YOUR_SERVER_IP "systemctl status openvpn"

# Check OpenVPN logs
ssh ubuntu@YOUR_SERVER_IP "tail -f /var/log/openvpn.log"

# Check listening port
ssh ubuntu@YOUR_SERVER_IP "sudo netstat -tlnp | grep 1194"
```

### Step 5: Download Client Configurations

```bash
# Download client configs
scp -r ubuntu@YOUR_SERVER_IP:/etc/openvpn/clients/ ./openvpn-clients/

# List available clients
ls openvpn-clients/
```

## What Happens

1. **Install OpenVPN**: Installs OpenVPN and EasyRSA
2. **Setup PKI**: Initializes PKI and generates certificates
3. **Generate Server Config**: Creates server configuration
4. **Generate Client Configs**: Creates client configuration files
5. **Configure Firewall**: Enables IP forwarding and NAT
6. **Start Service**: Enables and starts OpenVPN

## Client Configuration

### Windows

1. Download [OpenVPN Connect](https://openvpn.net/client/)
2. Import `.ovpn` file
3. Connect to server

### macOS

1. Install [Tunnelblick](https://tunnelblick.net/)
2. Import `.ovpn` file
3. Connect to server

### Linux

```bash
# Install OpenVPN client
sudo apt install openvpn

# Connect using config file
sudo openvpn --config client.ovpn
```

### iOS

1. Install [OpenVPN Connect](https://apps.apple.com/app/openvpn-connect/id590379981)
2. Import `.ovpn` file
3. Connect to server

### Android

1. Install [OpenVPN Connect](https://play.google.com/store/apps/details?id=net.openvpn.openvpn)
2. Import `.ovpn` file
3. Connect to server

## Verification Checklist

After deployment, verify:

- [ ] OpenVPN service is running
- [ ] Port 1194 is listening
- [ ] Client configs are generated
- [ ] Can connect from client
- [ ] Can access internal network
- [ ] DNS resolution works
- [ ] Firewall is configured

## Troubleshooting

### Issue: Cannot Connect

**Symptoms**: Client cannot connect to VPN server

**Solution**:

```bash
# Check OpenVPN status
ssh ubuntu@YOUR_SERVER_IP "systemctl status openvpn"

# Check OpenVPN logs
ssh ubuntu@YOUR_SERVER_IP "tail -f /var/log/openvpn.log"

# Check firewall
ssh ubuntu@YOUR_SERVER_IP "sudo ufw status"

# Check port forwarding
ssh ubuntu@YOUR_SERVER_IP "sudo sysctl net.ipv4.ip_forward"
```

### Issue: No Internet After Connect

**Symptoms**: Connected to VPN but no internet access

**Solution**:

```bash
# Check IP forwarding
ssh ubuntu@YOUR_SERVER_IP "sudo sysctl net.ipv4.ip_forward"

# Enable IP forwarding
ssh ubuntu@YOUR_SERVER_IP "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf"
ssh ubuntu@YOUR_SERVER_IP "sudo sysctl -p"

# Check NAT rules
ssh ubuntu@YOUR_SERVER_IP "sudo iptables -t nat -L"
```

### Issue: DNS Not Working

**Symptoms**: Connected to VPN but DNS resolution fails

**Solution**:

```bash
# Check DNS configuration in server.conf
ssh ubuntu@YOUR_SERVER_IP "cat /etc/openvpn/server.conf | grep push"

# Add DNS push directive
# In server.conf:
# push "dhcp-option DNS 8.8.8.8"
# push "dhcp-option DNS 8.8.4.4"

# Restart OpenVPN
ssh ubuntu@YOUR_SERVER_IP "sudo systemctl restart openvpn"
```

### Issue: Certificate Errors

**Symptoms**: Client shows certificate verification failed

**Solution**:

```bash
# Regenerate client certificate
cd /etc/openvpn/easy-rsa
./easyrsa revoke client1
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1

# Copy new certificate to client
scp /etc/openvpn/clients/client1/client1.ovpn user@client:/path/
```

## Maintenance

### Regular Tasks

1. **Check logs**: `tail -f /var/log/openvpn.log`
2. **Monitor connections**: `cat /etc/openvpn/ipp.txt`
3. **Check certificates**: `openssl x509 -in /etc/openvpn/server.crt -noout -dates`
4. **Backup PKI**: `tar -czf pki-backup.tar.gz /etc/openvpn/easy-rsa/pki`

### Add New Client

```bash
# Generate new client certificate
cd /etc/openvpn/easy-rsa
./easyrsa gen-req newclient nopass
./easyrsa sign-req client newclient

# Copy client config
cp /etc/openvpn/easy-rsa/pki/issued/newclient.crt /etc/openvpn/clients/newclient/
cp /etc/openvpn/easy-rsa/pki/private/newclient.key /etc/openvpn/clients/newclient/

# Generate .ovpn file
# Use template from existing client
```

### Revoke Client

```bash
# Revoke client certificate
cd /etc/openvpn/easy-rsa
./easyrsa revoke client1

# Generate CRL
./easyrsa gen-crl

# Copy CRL to OpenVPN directory
cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/

# Restart OpenVPN
sudo systemctl restart openvpn
```

## Resources

- [OpenVPN Documentation](https://openvpn.net/community-resources/)
- [EasyRSA Documentation](https://easy-rsa.readthedocs.io/)
- [OpenVPN Connect](https://openvpn.net/client/)
- [Tunnelblick](https://tunnelblick.net/)