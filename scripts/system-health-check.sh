#!/bin/bash
# System Health Check Script
# Part of OpenOps Toolkit

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "OK")
            echo -e "${GREEN}[OK]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        *)
            echo "[INFO] $message"
            ;;
    esac
}

# Function to check disk usage
check_disk_usage() {
    echo "=== Disk Usage ==="
    
    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    local available=$(df -h / | awk 'NR==2 {print $4}')
    
    if [ $usage -gt 90 ]; then
        print_status "ERROR" "Disk usage is critical: ${usage}% (Available: ${available})"
    elif [ $usage -gt 80 ]; then
        print_status "WARNING" "Disk usage is high: ${usage}% (Available: ${available})"
    else
        print_status "OK" "Disk usage is normal: ${usage}% (Available: ${available})"
    fi
}

# Function to check memory usage
check_memory_usage() {
    echo "=== Memory Usage ==="
    
    local total=$(free -h | awk 'NR==2 {print $2}')
    local used=$(free -h | awk 'NR==2 {print $3}')
    local available=$(free -h | awk 'NR==2 {print $7}')
    local percentage=$(free | awk 'NR==2 {printf "%.0f", $3*100/$2}')
    
    if [ $percentage -gt 90 ]; then
        print_status "ERROR" "Memory usage is critical: ${percentage}% (Used: ${used}, Total: ${total})"
    elif [ $percentage -gt 80 ]; then
        print_status "WARNING" "Memory usage is high: ${percentage}% (Used: ${used}, Total: ${total})"
    else
        print_status "OK" "Memory usage is normal: ${percentage}% (Available: ${available})"
    fi
}

# Function to check CPU usage
check_cpu_usage() {
    echo "=== CPU Usage ==="
    
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    local cores=$(nproc)
    local percentage=$(echo "$load $cores" | awk '{printf "%.0f", ($1/$2)*100}')
    
    if [ $percentage -gt 90 ]; then
        print_status "ERROR" "CPU load is critical: ${percentage}% (Load: ${load}, Cores: ${cores})"
    elif [ $percentage -gt 70 ]; then
        print_status "WARNING" "CPU load is high: ${percentage}% (Load: ${load}, Cores: ${cores})"
    else
        print_status "OK" "CPU load is normal: ${percentage}% (Load: ${load}, Cores: ${cores})"
    fi
}

# Function to check running services
check_services() {
    echo "=== Service Status ==="
    
    local services=("nginx" "mysql" "php8.2-fpm" "redis-server")
    
    for service in "${services[@]}"; do
        if systemctl is-active --quiet "$service" 2>/dev/null; then
            print_status "OK" "$service is running"
        else
            print_status "WARNING" "$service is not running"
        fi
    done
}

# Function to check network connectivity
check_network() {
    echo "=== Network Connectivity ==="
    
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_status "OK" "Internet connectivity is working"
    else
        print_status "ERROR" "No internet connectivity"
    fi
    
    if ping -c 1 google.com &> /dev/null; then
        print_status "OK" "DNS resolution is working"
    else
        print_status "WARNING" "DNS resolution may be slow or failing"
    fi
}

# Function to check SSL certificates
check_ssl_certificates() {
    echo "=== SSL Certificates ==="
    
    local domains=("example.com" "api.example.com")
    
    for domain in "${domains[@]}"; do
        if command -v openssl &> /dev/null; then
            local expiry=$(echo | openssl s_client -servername "$domain" -connect "$domain:443" 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)
            
            if [ -n "$expiry" ]; then
                local expiry_date=$(date -d "$expiry" +%s 2>/dev/null || echo "0")
                local current_date=$(date +%s)
                local days_left=$(( (expiry_date - current_date) / 86400 ))
                
                if [ $days_left -lt 7 ]; then
                    print_status "ERROR" "SSL certificate for $domain expires in $days_left days"
                elif [ $days_left -lt 30 ]; then
                    print_status "WARNING" "SSL certificate for $domain expires in $days_left days"
                else
                    print_status "OK" "SSL certificate for $domain is valid for $days_left days"
                fi
            else
                print_status "WARNING" "Could not check SSL certificate for $domain"
            fi
        else
            print_status "WARNING" "OpenSSL not available for certificate check"
        fi
    done
}

# Function to check Docker containers
check_docker() {
    echo "=== Docker Containers ==="
    
    if command -v docker &> /dev/null; then
        local containers=$(docker ps -a --format "table {{.Names}}\t{{.Status}}" | tail -n +2)
        
        if [ -z "$containers" ]; then
            print_status "INFO" "No Docker containers found"
        else
            echo "$containers"
        fi
    else
        print_status "INFO" "Docker is not installed"
    fi
}

# Main function
main() {
    echo "=========================="
    echo "System Health Check"
    echo "=========================="
    echo ""
    
    check_disk_usage
    echo ""
    
    check_memory_usage
    echo ""
    
    check_cpu_usage
    echo ""
    
    check_services
    echo ""
    
    check_network
    echo ""
    
    check_ssl_certificates
    echo ""
    
    check_docker
    echo ""
    
    echo "=========================="
    echo "Health Check Complete"
    echo "=========================="
}

# Run main function
main