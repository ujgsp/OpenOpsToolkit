# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |
| < 0.1   | :x:                |

## Reporting a Vulnerability

Kami sangat menghargai laporan vulnerability dari komunitas. Jika Anda menemukan masalah keamanan, harap laporkan secara bertanggung jawab.

### Cara Melaporkan

**JANGAN** buka GitHub issue untuk vulnerability.

Sebagai gantinya, silakan:

1. **Email**: kirim email ke security@openops-toolkit.com
2. **Subject**: Gunakan prefix `[SECURITY]` di subject
3. **Detail**: Sertakan informasi berikut:
   - Deskripsi vulnerability
   - Langkah-langkah untuk mereproduksi
   - Dampak potensial
   - Saran perbaikan (jika ada)

### Contoh Email

```
Subject: [SECURITY] Vulnerability in Ansible Laravel Role

Description:
Found a potential security issue in the Laravel deployment role...

Steps to Reproduce:
1. Run ansible-playbook with...
2. Check...
3. Observe...

Impact:
Could potentially expose...

Suggested Fix:
Consider adding...
```

### Response Time

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 1 week
- **Fix Timeline**: Depends on severity
  - Critical: 24-48 hours
  - High: 1 week
  - Medium: 2 weeks
  - Low: 1 month

### Disclosure Process

1. **Report received**: We acknowledge receipt
2. **Assessment**: We evaluate the vulnerability
3. **Fix developed**: We create a patch
4. **Disclosure**: We publish security advisory
5. **Release**: We release fixed version

### Safe Harbor

We consider security research conducted in accordance with this policy as:
- Authorized and will not pursue legal action
- Exempt from DMCA and CFAA
- Conducted in good faith

## Security Best Practices

### For Users

1. **Keep Updated**: Always use the latest version
2. **Review Configs**: Check configurations before deployment
3. **Use Secrets**: Never hardcode credentials
4. **Limit Access**: Use principle of least privilege
5. **Monitor**: Set up monitoring and alerting

### For Contributors

1. **Input Validation**: Validate all inputs
2. **Output Encoding**: Encode outputs properly
3. **Secrets Management**: Use secure secret storage
4. **Dependencies**: Keep dependencies updated
5. **Code Review**: Review for security issues

## Security Features

### Ansible Roles

- **Vault Integration**: Support for Ansible Vault
- **Secret Management**: Secure handling of credentials
- **Minimal Privileges**: Roles use minimum required permissions
- **Idempotent**: Safe to run multiple times

### n8n Workflows

- **Credential Storage**: Secure credential management
- **Webhook Security**: Token-based authentication
- **Data Validation**: Input validation on all nodes
- **Error Handling**: Secure error messages

### Monitoring

- **Access Control**: Dashboard authentication
- **Data Encryption**: Encrypted data transmission
- **Audit Logging**: Track access and changes
- **Alert Security**: Secure notification channels

## Known Security Considerations

### Ansible

- **SSH Keys**: Use SSH keys instead of passwords
- **Sudo**: Minimize sudo usage
- **Vault**: Use Ansible Vault for secrets
- **Host Key Checking**: Enable in production

### Docker

- **Rootless**: Use rootless Docker when possible
- **Images**: Use official images only
- **Networks**: Isolate container networks
- **Volumes**: Limit volume permissions

### Monitoring

- **Authentication**: Enable dashboard authentication
- **HTTPS**: Use HTTPS for all endpoints
- **Firewall**: Restrict access to monitoring ports
- **Updates**: Keep monitoring tools updated

## Security Contacts

- **Primary**: security@openops-toolkit.com
- **Backup**: maintainer@openops-toolkit.com
- **Emergency**: Use phone contact (available to verified reporters)

## Bug Bounty

Currently, we do not have a formal bug bounty program. However, we:
- Acknowledge reporters in release notes
- Provide recommendations for responsible disclosure
- Consider implementing a bounty program in the future

## Legal

This policy is subject to change. Please check for updates regularly.

---

**Last Updated**: June 2026