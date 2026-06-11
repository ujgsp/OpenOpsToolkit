# Server Backup Role

Ansible role untuk setup backup otomatis server Ubuntu.

## Fitur

| Komponen | Deskripsi |
|---|---|
| **File Backup** | Backup direktori konfigurasi (nginx, ssh, dll) |
| **MySQL Backup** | Backup semua atau database tertentu |
| **Auto Cleanup** | Hapus backup lama otomatis berdasarkan retention |
| **Cron Schedule** | Jadwal backup harian via cron |
| **Log Rotation** | Rotasi log backup otomatis |

## Kebutuhan

- Ubuntu 22.04 / 24.04 LTS
- Akses root atau sudo
- MySQL/MariaDB (opsional, untuk database backup)

## Variabel

| Variabel | Default | Deskripsi |
|---|---|---|
| `backup_enabled` | `true` | Aktifkan backup |
| `backup_path` | `/var/backups/server` | Lokasi penyimpanan backup |
| `backup_retention_days` | `7` | Berapa hari backup disimpan |
| `backup_mysql` | `true` | Aktifkan MySQL backup |
| `backup_mysql_databases` | `[]` (semua) | Database yang di-backup |
| `backup_mysql_user` | `root` | MySQL user untuk backup |
| `backup_mysql_password` | `""` | MySQL password (gunakan vault!) |
| `backup_paths` | `[nginx, ssh, var/www]` | Direktori yang di-backup |
| `backup_hour` | `2` | Jam backup berjalan (0-23) |
| `backup_minute` | `0` | Menit backup berjalan (0-59) |

## Contoh Inventory

```yaml
# inventories/production/inventory.yml

all:
  children:
    backup_servers:
      hosts:
        103.150.116.50:
          ansible_user: deployer
          
          # Backup Configuration
          backup_enabled: true
          backup_path: "/var/backups/server"
          backup_retention_days: 7
          
          # MySQL Backup
          backup_mysql: true
          backup_mysql_databases: []  # Kosong = backup semua
          backup_mysql_user: root
          # backup_mysql_password: di-vault!
          
          # File Backup Paths
          backup_paths:
            - /etc/nginx
            - /etc/ssh
            - /var/www
            - /etc/fail2ban
          
          # Cron Schedule
          backup_hour: "2"
          backup_minute: "0"
```

## Contoh Vault File

```yaml
# inventories/production/group_vars/all/vault.yml

vault_db_password: "supersecretpassword"
vault_mysql_root_password: "anothersecretpassword"
```

```bash
# Edit vault
ansible-vault edit inventories/production/group_vars/all/vault.yml
```

## Contoh Penggunaan

### Solo

```yaml
# playbooks/backup-only.yml

- name: Setup Backup
  hosts: backup_servers
  become: yes
  roles:
    - server-backup
```

```bash
ansible-playbook -i inventories/production/inventory.yml playbooks/backup-only.yml --ask-vault-pass
```

### Gabungan

```yaml
# playbooks/setup-server.yml

- name: Setup Server
  hosts: setup_servers
  become: yes
  roles:
    - server-hardening
    - ufw
    - server-backup    # Tambahkan di sini
    - nginx
```

## Struktur Backup

```
/var/backups/server/
├── server-backup-20240515_020000.tar.gz    # File backup
├── server-backup-20240516_020000.tar.gz
├── mysql/
│   ├── mydb-20240515_020500.sql.gz         # Database backup
│   ├── mydb-20240516_020500.sql.gz
│   └── backup-info-20240516_020500.txt
└── ...
```

## Restore Backup

### Restore File Backup

```bash
# List backup
ls -la /var/backups/server/server-backup-*.tar.gz

# Restore
tar -xzf /var/backups/server/server-backup-20240515_020000.tar.gz -C /
```

### Restore MySQL Backup

```bash
# List backup
ls -la /var/backups/server/mysql/*.sql.gz

# Restore
gunzip -c /var/backups/server/mysql/mydb-20240515_020500.sql.gz | mysql -u root -p mydb
```

## Manual Trigger

```bash
# Jalankan backup manual
sudo /usr/local/bin/server-backup.sh

# Jalankan MySQL backup manual
sudo /usr/local/bin/server-backup-mysql.sh

# Jalankan cleanup manual
sudo /usr/local/bin/server-backup-cleanup.sh
```

## Monitoring Backup

```bash
# Cek log backup
tail -f /var/log/server-backup.log
tail -f /var/log/server-backup-mysql.log

# Cek cron
crontab -l | grep backup
```

## Troubleshooting

### Backup gagal karena disk penuh

```bash
# Cek disk usage
df -h /var/backups

# Hapus backup manual
rm /var/backups/server/server-backup-*.tar.gz
```

### MySQL backup gagal

```bash
# Test koneksi MySQL
mysql -u root -p -e "SHOW DATABASES;"

# Cek log
cat /var/log/server-backup-mysql.log
```
