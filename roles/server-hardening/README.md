# Server Hardening Role

Ansible role untuk hardening server Ubuntu dari serangan umum.

## Fitur

| Komponen | Deskripsi |
|---|---|
| **SSH Hardening** | Disable password login, force key-only, limit auth tries |
| **Fail2Ban** | Proteksi brute-force untuk SSH, Nginx, dan service lainnya |
| **Kernel Hardening** | Sysctl settings untuk mencegah IP spoofing, SYN flood, dll |
| **File Permissions** | Set permissions aman untuk file system kritis |
| **Unattended Upgrades** | Auto security updates untuk Ubuntu |
| **Timezone** | Konfigurasi timezone server |

## Kebutuhan

- Ubuntu 22.04 / 24.04 LTS
- Akses SSH dengan key-based authentication
- Ansible 2.12+

## Variabel

| Variabel | Default | Deskripsi |
|---|---|---|
| `ssh_port` | `22` | Port SSH |
| `ssh_permit_root_login` | `prohibit-password` | Izinkan root login hanya dengan key |
| `ssh_password_authentication` | `no` | Disable password authentication |
| `ssh_max_auth_tries` | `3` | Maksimal percobaan autentikasi |
| `fail2ban_bantime` | `3600` | Durasi ban (detik) |
| `fail2ban_maxretry` | `5` | Maksimal percobaan sebelum ban |
| `server_timezone` | `Asia/Jakarta` | Timezone server |
| `auto_security_updates` | `true` | Aktifkan auto security updates |

## Contoh Inventory

```yaml
# inventories/production/inventory.yml

all:
  children:
    hardening_servers:
      hosts:
        103.150.116.50:
          ansible_user: deployer
          ansible_port: 22
          
          # SSH Configuration
          ssh_port: 22
          ssh_permit_root_login: "prohibit-password"
          ssh_password_authentication: "no"
          
          # Fail2Ban Configuration
          fail2ban_bantime: "3600"
          fail2ban_maxretry: "5"
          
          # System Configuration
          server_timezone: "Asia/Jakarta"
          auto_security_updates: true
```

## Contoh Penggunaan

### Solo (tanpa playbook lain)

```yaml
# playbooks/hardening-only.yml

- name: Hardening Server
  hosts: hardening_servers
  become: yes
  roles:
    - server-hardening
```

```bash
ansible-playbook -i inventories/production/inventory.yml playbooks/hardening-only.yml --ask-vault-pass
```

### Gabungan dengan role lain

```yaml
# playbooks/setup-server.yml

- name: Setup Server
  hosts: setup_servers
  become: yes
  roles:
    - server-hardening   # Hardening pertama
    - ufw                # Firewall
    - nginx              # Web server
```

## Checklist Paska-Instalasi

Setelah menjalankan role ini, pastikan:

- [ ] Anda masih bisa SSH ke server (gunakan key yang benar)
- [ ] Fail2Ban aktif: `sudo fail2ban-client status`
- [ ] UFW aktif: `sudo ufw status verbose`
- [ ] Password auth sudah nonaktif: `grep PasswordAuthentication /etc/ssh/sshd_config`
- [ ] Auto updates berjalan: `dpkg -l unattended-upgrades`

## Troubleshooting

### Terkunci dari SSH

Jika Anda terkunci dari server karena password auth dinonaktifkan:

1. Akses console via panel VPS (DigitalOcean, Vultr, dll)
2. Login sebagai root
3. Edit `/etc/ssh/sshd_config`
4. Set `PasswordAuthentication yes`
5. Restart SSH: `systemctl restart sshd`

### Fail2Ban memblokir IP yang benar

```bash
# Cek status
sudo fail2ban-client status sshd

# Unblock IP
sudo fail2ban-client set sshd unbanip 123.45.67.89
```
