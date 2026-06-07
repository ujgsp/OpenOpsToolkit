# n8n Workflow Templates

Workflow templates untuk integrasi n8n dengan monitoring stack.

## Workflows Tersedia

| Workflow | Tujuan | Jadwal |
|----------|--------|--------|
| `ssl-expired-alert.json` | Monitor sertifikat SSL | Setiap 12 jam |
| `domain-expired-alert.json` | Monitor expiry domain | Setiap 24 jam |
| `website-down-alert.json` | Monitor ketersediaan website | Setiap 5 menit |

## Cara Menggunakan

1. Deploy n8n menggunakan Ansible role:
   ```bash
   ansible-playbook -i ansible/inventories/production ansible/playbooks/site.yml --limit n8n_servers --ask-vault-pass
   ```

2. Buka dashboard n8n

3. Import workflow:
   - Klik **Import from File**
   - Pilih salah satu file `.json` di atas

4. Konfigurasi:
   - Token bot Telegram
   - Domain yang akan dimonitor
   - Threshold alert

5. Aktifkan workflow

## Prasyarat

- n8n instance yang sudah berjalan
- Telegram Bot Token
- Domain yang akan dimonitor
