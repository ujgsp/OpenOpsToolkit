# AI Incident Analysis

AI-powered incident analysis for server logs.

## Overview

This tool analyzes server logs using AI to:
- Identify error patterns
- Determine root causes
- Assess impact
- Provide resolution recommendations

## Supported Log Types

### Nginx Logs

**Access Log Format:**
```
$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"
```

**Error Log Format:**
```
YYYY/MM/DD HH:MM:SS [level] PID#TID: *CID message
```

### Apache Logs

**Access Log Format:**
```
$remote_addr - $remote_user [$time_local] "$request" $status $bytes_sent "$http_referer" "$http_user_agent"
```

**Error Log Format:**
```
[day month year HH:MM:SS.mmmmmm] [level] [pid:tid] [client: IP] message
```

### Laravel Logs

**Log Format:**
```
[YYYY-MM-DD HH:MM:SS] production.ERROR: message {"exception":"..."}
```

## Usage

### Manual Analysis

```bash
# Analyze Nginx logs
python scripts/ai_incident.py --log-type nginx --file /var/log/nginx/error.log

# Analyze Laravel logs
python scripts/ai_incident.py --log-type laravel --file storage/logs/laravel.log

# Analyze last 24 hours
python scripts/ai_incident.py --log-type nginx --hours 24
```

### Automated Analysis

```yaml
# GitHub Actions workflow
name: AI Incident Analysis

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Collect logs
        run: |
          ssh server "tail -1000 /var/log/nginx/error.log" > nginx_errors.log
      
      - name: AI Analysis
        run: |
          python scripts/ai_incident.py --log-type nginx --file nginx_errors.log
```

## Prompts

### Nginx Error Analysis

```
Analyze the following Nginx error logs and provide:
1. Error patterns identified
2. Root cause analysis
3. Impact assessment
4. Resolution recommendations

Logs:
{logs}
```

### Laravel Error Analysis

```
Analyze the following Laravel application logs and provide:
1. Error types and frequencies
2. Root cause analysis
3. Affected functionality
4. Resolution recommendations

Logs:
{logs}
```

### System Log Analysis

```
Analyze the following system logs and provide:
1. Critical events identified
2. Security concerns
3. Performance issues
4. Recommended actions

Logs:
{logs}
```

## Examples

### Example 1: Nginx 502 Errors

**Input:**
```
2024/01/15 10:23:45 [error] 1234#0: *5678 connect() failed (111: Connection refused) while connecting to upstream
2024/01/15 10:23:46 [error] 1234#0: *5679 connect() failed (111: Connection refused) while connecting to upstream
2024/01/15 10:23:47 [error] 1234#0: *5680 connect() failed (111: Connection refused) while connecting to upstream
```

**AI Output:**
```
## Error Analysis

### Patterns Identified
- Recurring 502 Bad Gateway errors
- Connection refused to upstream server
- High frequency (3 errors in 2 seconds)

### Root Cause
The upstream application server (PHP-FPM) is not responding. This could be due to:
1. PHP-FPM service crashed
2. PHP-FPM process limit reached
3. Application error causing PHP-FPM to hang

### Impact
- All requests returning 502 errors
- Website completely inaccessible
- User experience severely impacted

### Resolution Steps
1. Check PHP-FPM status: systemctl status php8.2-fpm
2. Check PHP-FPM logs: tail -f /var/log/php8.2-fpm.log
3. Restart PHP-FPM: systemctl restart php8.2-fpm
4. Monitor for recurrence
```

### Example 2: Laravel Database Errors

**Input:**
```
[2024-01-15 10:23:45] production.ERROR: SQLSTATE[HY000] [2002] Connection refused {"exception":"[object] (PDOException(code: 2002): Connection refused at /var/www/app/vendor/laravel/framework/src/Illuminate/Database/Connectors/Connector.php:70)"}
```

**AI Output:**
```
## Error Analysis

### Patterns Identified
- Database connection refused
- PDOException with code 2002
- Affects application connectivity

### Root Cause
The application cannot connect to the MySQL database. Possible causes:
1. MySQL service is down
2. MySQL is not accepting connections
3. Incorrect database credentials
4. Firewall blocking connection

### Impact
- Application cannot read/write data
- All database-dependent features broken
- User-facing errors likely

### Resolution Steps
1. Check MySQL status: systemctl status mysql
2. Check MySQL logs: tail -f /var/log/mysql/error.log
3. Verify database credentials in .env
4. Test connection: mysql -u username -p -h localhost
5. Check firewall rules
```

## Configuration

### Environment Variables

```bash
# OpenAI API Key
OPENAI_API_KEY=your-api-key

# Model to use
AI_MODEL=gpt-4

# Max tokens for response
AI_MAX_TOKENS=1000

# Temperature (0-1)
AI_TEMPERATURE=0.3
```

### Configuration File

```yaml
# config/ai_ops.yml
incident_analysis:
  enabled: true
  model: gpt-4
  max_tokens: 1000
  temperature: 0.3
  
  log_types:
    nginx:
      paths:
        - /var/log/nginx/error.log
        - /var/log/nginx/access.log
      patterns:
        - "error"
        - "crit"
        - "alert"
    
    laravel:
      paths:
        - /var/www/app/storage/logs/laravel.log
      patterns:
        - "ERROR"
        - "CRITICAL"
        - "ALERT"
```

## Integration

### With Monitoring Stack

```yaml
# Prometheus alerting rule
groups:
  - name: ai_analysis
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        annotations:
          summary: "High error rate detected"
          description: "Triggering AI analysis..."
```

### With GitHub Issues

```python
def create_incident_issue(analysis):
    """Create GitHub issue from AI analysis."""
    issue = {
        'title': f"Incident: {analysis['summary']}",
        'body': f"""
## Incident Report

### Summary
{analysis['summary']}

### Root Cause
{analysis['root_cause']}

### Impact
{analysis['impact']}

### Resolution Steps
{analysis['resolution']}

### Logs
```
{analysis['logs']}
```
""",
        'labels': ['incident', 'ai-generated']
    }
    return issue
```

## Best Practices

### 1. Log Collection

- Collect logs from multiple sources
- Include timestamps and context
- Filter relevant time periods
- Preserve log format

### 2. Prompt Engineering

- Be specific about what you want
- Provide context about the system
- Ask for structured output
- Iterate on prompts

### 3. Validation

- Always validate AI output
- Cross-reference with other sources
- Test recommendations
- Document findings

## Troubleshooting

### Common Issues

1. **API Key Invalid**
   - Verify API key is correct
   - Check API key permissions
   - Ensure billing is active

2. **Poor Analysis Quality**
   - Improve prompt specificity
   - Provide more context
   - Use more capable model
   - Increase max tokens

3. **Rate Limiting**
   - Implement exponential backoff
   - Cache responses
   - Batch requests

## Resources

- [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
- [Log Analysis Best Practices](https://www.elastic.co/what-is/log-analysis)
- [Incident Response Playbooks](https://www.sans.org/white-papers/incident-handlers-handbook/)

## License

MIT

## Author

OpenOps Toolkit Contributors