# n8n Workflow Templates

Collection of n8n workflow templates for automation and monitoring.

## Available Workflows

### Monitoring

#### SSL Certificate Expiry Alert
- **File**: `monitoring/ssl-expired-alert.json`
- **Purpose**: Monitor SSL certificate expiration
- **Schedule**: Every 12 hours
- **Notification**: Telegram

#### Domain Expiry Alert
- **File**: `monitoring/domain-expired-alert.json`
- **Purpose**: Monitor domain name expiration
- **Schedule**: Every 24 hours
- **Notification**: Telegram

#### Website Down Alert
- **File**: `monitoring/website-down-alert.json`
- **Purpose**: Monitor website availability
- **Schedule**: Every 5 minutes
- **Notification**: Telegram

## How to Import

1. Open n8n dashboard
2. Click "Import from File"
3. Select workflow JSON file
4. Configure credentials:
   - Telegram Bot API
   - WHOIS API (for domain monitoring)
5. Update configuration:
   - Domain names
   - URLs to monitor
   - Chat ID for notifications
6. Activate workflow

## Configuration

### Telegram Setup
1. Create Telegram bot via @BotFather
2. Get bot token
3. Get chat ID (use @userinfobot)
4. Add credentials in n8n

### SSL Monitoring
- Update domain list in workflow
- Configure alert thresholds (default: 30 days)

### Domain Monitoring
- Update domain list in workflow
- Get WHOIS API key from whoisxmlapi.com

### Website Monitoring
- Update URL list in workflow
- Configure timeout and thresholds

## Customization

### Adding New Domains
Edit the `domains` array in the function node:
```javascript
const domains = ['example.com', 'api.example.com', 'admin.example.com'];
```

### Adding New URLs
Edit the `urls` array in the function node:
```javascript
const urls = [
  'https://example.com',
  'https://api.example.com/health',
  'https://admin.example.com'
];
```

### Changing Schedule
Modify the Schedule Trigger node:
- Minutes: 1-59
- Hours: 1-23
- Days: 1-31

## Troubleshooting

### Telegram Not Sending
1. Check bot token
2. Verify chat ID
3. Ensure bot is added to chat

### API Errors
1. Check API key
2. Verify API endpoint
3. Check rate limits

### False Alerts
1. Adjust thresholds
2. Check network connectivity
3. Verify domain/URL configuration

## License

MIT

## Author

OpenOps Toolkit Contributors