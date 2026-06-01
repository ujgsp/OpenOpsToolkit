# Configure Telegram Alerts

Setup Telegram notifications for SSL expiry, domain expiry, and website downtime alerts.

## What You Get

- ✅ **SSL Alerts**: Get notified before SSL certificates expire
- ✅ **Domain Alerts**: Get notified before domains expire
- ✅ **Uptime Alerts**: Get notified when websites go down
- ✅ **Instant Notifications**: Receive alerts within minutes

## Requirements

- Telegram account
- n8n instance (see [Setup n8n](../setup-n8n/README.md))
- Domains/URLs to monitor

## Quick Start

### 1. Create Telegram Bot

1. Open Telegram
2. Search for @BotFather
3. Send `/newbot`
4. Follow instructions
5. Save the **Bot Token**

### 2. Get Chat ID

1. Search for @userinfobot
2. Send any message
3. Save the **Chat ID**

### 3. Configure n8n Workflow

#### SSL Expired Alert

1. Open n8n dashboard
2. Import `n8n/workflows/monitoring/ssl-expired-alert.json`
3. Open "Telegram Alert" node
4. Configure:
   - **Bot Token**: Your bot token
   - **Chat ID**: Your chat ID
5. Open "Check Certificates" node
6. Update domains list:
   ```javascript
   const domains = ['example.com', 'api.example.com', 'admin.example.com'];
   ```
7. Save and activate workflow

#### Domain Expired Alert

1. Import `n8n/workflows/monitoring/domain-expired-alert.json`
2. Configure Telegram credentials
3. Open "Check Domains" node
4. Update domains list
5. Configure WHOIS API key (get from whoisxmlapi.com)
6. Save and activate workflow

#### Website Down Alert

1. Import `n8n/workflows/monitoring/website-down-alert.json`
2. Configure Telegram credentials
3. Open "Check Websites" node
4. Update URLs list:
   ```javascript
   const urls = [
     'https://example.com',
     'https://api.example.com/health',
     'https://admin.example.com'
   ];
   ```
5. Save and activate workflow

### 4. Test Alerts

#### Test SSL Alert

```bash
# Trigger manually in n8n
# Or wait for schedule (every 12 hours)
```

#### Test Website Down Alert

```bash
# Temporarily stop a website
ssh ubuntu@YOUR_SERVER_IP "sudo systemctl stop nginx"

# Wait 5 minutes for alert
# Restart website
ssh ubuntu@YOUR_SERVER_IP "sudo systemctl start nginx"
```

## Alert Examples

### SSL Expiry Alert

```
🔒 SSL Certificate Alert

Domain: example.com
Expiry Date: 2024-02-15T00:00:00.000Z
Days Until Expiry: 15
Issuer: Let's Encrypt

⚠️ WARNING: Certificate expires in less than 30 days

Please renew the certificate immediately.
```

### Website Down Alert

```
🚨 Website Down Alert

URL: https://example.com
Status: 0
Response Time: 0ms

❌ Website is DOWN!

Error: connect ECONNREFUSED

Please check the website immediately.
```

## Configuration

### Alert Thresholds

#### SSL Alert

Edit "Check Certificates" node:

```javascript
// Alert when days until expiry <= 30
needsAlert: daysUntilExpiry <= 30

// Change to 7 days
needsAlert: daysUntilExpiry <= 7
```

#### Website Alert

Edit "Check Websites" node:

```javascript
// Alert when response time > 5000ms
needsAlert: response.statusCode >= 400 || responseTime > 5000

// Change to 3000ms
needsAlert: response.statusCode >= 400 || responseTime > 3000
```

### Schedule

Edit "Schedule Trigger" node:

| Workflow | Default | Options |
|----------|---------|---------|
| SSL Alert | Every 12 hours | Every 1-24 hours |
| Domain Alert | Every 24 hours | Every 1-24 hours |
| Website Alert | Every 5 minutes | Every 1-60 minutes |

## Troubleshooting

### No Alerts Received

```bash
# Check if workflow is active
# Open n8n dashboard → Workflows → Check status

# Check Telegram credentials
# Test in n8n: Execute Telegram node manually

# Check n8n logs
ssh ubuntu@YOUR_SERVER_IP "docker logs n8n"
```

### Wrong Chat ID

```bash
# Get correct Chat ID
# Message @userinfobot on Telegram

# Update in n8n workflow
# Open Telegram Alert node → Update Chat ID
```

### API Rate Limits

```bash
# SSL Alert: Uses crt.sh (free, no rate limit)
# Domain Alert: Uses WHOIS API (check your plan)
# Website Alert: Direct HTTP requests (no API)
```

## Next Steps

- [Deploy Laravel](../deploy-laravel/README.md)
- [Setup Monitoring](../setup-monitoring/README.md)
- [Setup n8n](../setup-n8n/README.md)