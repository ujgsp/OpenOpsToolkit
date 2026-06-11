# Setup Server OpenVPN

Panduan lengkap untuk deploy server OpenVPN untuk akses remote yang aman.

## Ringkasan

Panduan ini akan memandu Anda untuk deploy server OpenVPN. OpenVPN menyediakan:

- Akses remote yang aman ke jaringan internal
- Komunikasi terenkripsi
- Autentikasi sertifikat klien
- Dukungan multi-platform

## Arsitektur

```
┌─────────────────────────────────────────────────────────────┐
│                      Server OpenVPN                          │
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

## Kebutuhan

### Kebutuhan Server

- **OS**: Ubuntu 22.04 LTS
- **RAM**: Minimal 512MB
- **Penyimpanan**: Minimal 10GB
- **Akses**: SSH dengan hak sudo
- **Jaringan**: Alamat IP publik

### Kebutuhan Klien

- **OS**: Windows, macOS, Linux, iOS, Android
- **Perangkat Lunak**: Klien OpenVPN

## Instalasi

### Langkah 1: Konfigurasi Inventory

Edit `inventories/production/inventory.yml`:

```yaml
vpn_servers:
  hosts:
    vpn1:
      ansible_host: IP_SERVER_ANDA
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Langkah 2: Konfigurasi Variabel

Edit `inventories/production/group_vars/vpn_servers.yml`:

```yaml
openvpn_server_ip: IP_SERVER_ANDA
openvpn_port: 1194
openvpn_protocol: udp
openvpn_clients:
  - laptop
  - phone
  - tablet
```

### Langkah 3: Deploy

```bash
ansible-playbook -i inventories/production roles/openvpn/tasks/main.yml
```

### Langkah 4: Verifikasi Deployment

```bash
# Cek status OpenVPN
ssh ubuntu@IP_SERVER_ANDA "systemctl status openvpn"

# Cek log OpenVPN
ssh ubuntu@IP_SERVER_ANDA "tail -f /var/log/openvpn.log"

# Cek port yang mendengarkan
ssh ubuntu@IP_SERVER_ANDA "sudo netstat -tlnp | grep 1194"
```

### Langkah 5: Download Konfigurasi Klien

```bash
# Download konfigurasi klien
scp -r ubuntu@IP_SERVER_ANDA:/etc/openvpn/clients/ ./openvpn-clients/

# Daftar klien yang tersedia
ls openvpn-clients/
```

## Apa yang Terjadi

1. **Install OpenVPN**: Menginstall OpenVPN dan EasyRSA
2. **Setup PKI**: Menginisialisasi PKI dan menghasilkan sertifikat
3. **Buat Konfigurasi Server**: Membuat konfigurasi server
4. **Buat Konfigurasi Klien**: Membuat file konfigurasi klien
5. **Konfigurasi Firewall**: Mengaktifkan IP forwarding dan NAT
6. **Mulai Layanan**: Mengaktifkan dan memulai OpenVPN

## Konfigurasi Klien

### Windows

1. Download [OpenVPN Connect](https://openvpn.net/client/)
2. Import file `.ovpn`
3. Hubungkan ke server

### macOS

1. Install [Tunnelblick](https://tunnelblick.net/)
2. Import file `.ovpn`
3. Hubungkan ke server

### Linux

```bash
# Install klien OpenVPN
sudo apt install openvpn

# Hubungkan menggunakan file konfigurasi
sudo openvpn --config client.ovpn
```

### iOS

1. Install [OpenVPN Connect](https://apps.apple.com/app/openvpn-connect/id590379981)
2. Import file `.ovpn`
3. Hubungkan ke server

### Android

1. Install [OpenVPN Connect](https://play.google.com/store/apps/details?id=net.openvpn.openvpn)
2. Import file `.ovpn`
3. Hubungkan ke server

## Checklist Verifikasi

Setelah deployment, verifikasi:

- [ ] Layanan OpenVPN berjalan
- [ ] Port 1194 mendengarkan
- [ ] Konfigurasi klien dihasilkan
- [ ] Dapat terhubung dari klien
- [ ] Dapat mengakses jaringan internal
- [ ] Resolusi DNS berfungsi
- [ ] Firewall dikonfigurasi

## Pemecahan Masalah

### Masalah: Tidak Dapat Terhubung

**Gejala**: Klien tidak dapat terhubung ke server VPN

**Solusi**:

```bash
# Cek status OpenVPN
ssh ubuntu@IP_SERVER_ANDA "systemctl status openvpn"

# Cek log OpenVPN
ssh ubuntu@IP_SERVER_ANDA "tail -f /var/log/openvpn.log"

# Cek firewall
ssh ubuntu@IP_SERVER_ANDA "sudo ufw status"

# Cek port forwarding
ssh ubuntu@IP_SERVER_ANDA "sudo sysctl net.ipv4.ip_forward"
```

### Masalah: Tidak Ada Internet Setelah Terhubung

**Gejala**: Terhubung ke VPN tetapi tidak ada akses internet

**Solusi**:

```bash
# Cek IP forwarding
ssh ubuntu@IP_SERVER_ANDA "sudo sysctl net.ipv4.ip_forward"

# Aktifkan IP forwarding
ssh ubuntu@IP_SERVER_ANDA "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf"
ssh ubuntu@IP_SERVER_ANDA "sudo sysctl -p"

# Cek aturan NAT
ssh ubuntu@IP_SERVER_ANDA "sudo iptables -t nat -L"
```

### Masalah: DNS Tidak Berfungsi

**Gejala**: Terhubung ke VPN tetapi resolusi DNS gagal

**Solusi**:

```bash
# Cek konfigurasi DNS di server.conf
ssh ubuntu@IP_SERVER_ANDA "cat /etc/openvpn/server.conf | grep push"

# Tambahkan direktif push DNS
# Di server.conf:
# push "dhcp-option DNS 8.8.8.8"
# push "dhcp-option DNS 8.8.4.4"

# Restart OpenVPN
ssh ubuntu@IP_SERVER_ANDA "sudo systemctl restart openvpn"
```

### Masalah: Error Sertifikat

**Gejala**: Klien menampilkan verifikasi sertifikat gagal

**Solusi**:

```bash
# Hasilkan ulang sertifikat klien
cd /etc/openvpn/easy-rsa
./easyrsa revoke client1
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1

# Salin sertifikat baru ke klien
scp /etc/openvpn/clients/client1/client1.ovpn user@client:/path/
```

## Pemeliharaan

### Tugas Rutin

1. **Cek log**: `tail -f /var/log/openvpn.log`
2. **Monitor koneksi**: `cat /etc/openvpn/ipp.txt`
3. **Cek sertifikat**: `openssl x509 -in /etc/openvpn/server.crt -noout -dates`
4. **Backup PKI**: `tar -czf pki-backup.tar.gz /etc/openvpn/easy-rsa/pki`

### Tambah Klien Baru

```bash
# Hasilkan sertifikat klien baru
cd /etc/openvpn/easy-rsa
./easyrsa gen-req klienbaru nopass
./easyrsa sign-req client klienbaru

# Salin konfigurasi klien
cp /etc/openvpn/easy-rsa/pki/issued/klienbaru.crt /etc/openvpn/clients/klienbaru/
cp /etc/openvpn/easy-rsa/pki/private/klienbaru.key /etc/openvpn/clients/klienbaru/

# Buat file .ovpn
# Gunakan template dari klien yang ada
```

### Cabut Klien

```bash
# Cabut sertifikat klien
cd /etc/openvpn/easy-rsa
./easyrsa revoke client1

# Hasilkan CRL
./easyrsa gen-crl

# Salin CRL ke direktori OpenVPN
cp /etc/openvpn/easy-rsa/pki/crl.pem /etc/openvpn/

# Restart OpenVPN
sudo systemctl restart openvpn
```

## Sumber Daya

- [Dokumentasi OpenVPN](https://openvpn.net/community-resources/)
- [Dokumentasi EasyRSA](https://easy-rsa.readthedocs.io/)
- [OpenVPN Connect](https://openvpn.net/client/)
- [Tunnelblick](https://tunnelblick.net/)