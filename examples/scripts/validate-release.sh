#!/bin/bash
# Validate Release Script
# OpenOps Toolkit

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    CHECKS_WARNING=$((CHECKS_WARNING + 1))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

# Check required files
check_required_files() {
    log_info "Checking required files..."
    
    REQUIRED_FILES=(
        "README.md"
        "CHANGELOG.md"
        "CONTRIBUTING.md"
        "SECURITY.md"
        "LICENSE"
        ".gitignore"
    )
    
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            log_success "Found: $file"
        else
            log_error "Missing: $file"
        fi
    done
}

# Check documentation
check_documentation() {
    log_info "Checking documentation..."
    
    if [ -f "README.md" ]; then
        if grep -q "# OpenOps Toolkit" README.md; then
            log_success "README.md has correct title"
        else
            log_warning "README.md may be missing title"
        fi
    fi
    
    if [ -f "CHANGELOG.md" ]; then
        if grep -q "## \[Unreleased\]" CHANGELOG.md; then
            log_success "CHANGELOG.md has unreleased section"
        else
            log_warning "CHANGELOG.md may be missing unreleased section"
        fi
    fi
}

# Check Ansible structure
check_ansible_structure() {
    log_info "Checking Ansible structure..."
    
    if [ -f "ansible.cfg" ]; then
        log_success "ansible.cfg exists"
    else
        log_error "ansible.cfg missing"
    fi
    
    if [ -d "roles" ]; then
        log_success "roles/ exists"
        
        # Count roles
        ROLE_COUNT=$(ls -d roles/*/ 2>/dev/null | wc -l)
        log_info "Found $ROLE_COUNT Ansible roles"
    else
        log_error "roles/ missing"
    fi
    
    if [ -d "playbooks" ]; then
        log_success "playbooks/ exists"
    else
        log_error "playbooks/ missing"
    fi
    
    if [ -d "inventories" ]; then
        log_success "inventories/ exists"
    else
        log_error "inventories/ missing"
    fi
}

# Check n8n workflows
check_n8n_workflows() {
    log_info "Checking n8n workflows..."
    
    if [ -d "n8n" ]; then
        log_success "n8n/ directory exists"
        
        if [ -d "n8n/workflows" ]; then
            log_success "n8n/workflows/ exists"
            
            # Count workflows
            WORKFLOW_COUNT=$(find n8n/workflows -name "*.json" 2>/dev/null | wc -l)
            log_info "Found $WORKFLOW_COUNT n8n workflows"
        else
            log_warning "n8n/workflows/ missing"
        fi
    else
        log_warning "n8n/ directory missing"
    fi
}

# Check monitoring stack
check_monitoring() {
    log_info "Checking monitoring stack..."
    
    if [ -d "monitoring" ]; then
        log_success "monitoring/ directory exists"
        
        if [ -f "monitoring/docker-compose.yml" ]; then
            log_success "monitoring/docker-compose.yml exists"
        else
            log_warning "monitoring/docker-compose.yml missing"
        fi
    else
        log_warning "monitoring/ directory missing"
    fi
}

# Check scripts
check_scripts() {
    log_info "Checking scripts..."
    
    if [ -d "scripts" ]; then
        log_success "scripts/ directory exists"
        
        # Check script permissions
        for script in scripts/*.sh; do
            if [ -x "$script" ]; then
                log_success "Executable: $script"
            else
                log_warning "Not executable: $script"
            fi
        done
    else
        log_warning "scripts/ directory missing"
    fi
}

# Check GitHub configuration
check_github_config() {
    log_info "Checking GitHub configuration..."
    
    if [ -d ".github" ]; then
        log_success ".github/ directory exists"
        
        if [ -d ".github/workflows" ]; then
            log_success ".github/workflows/ exists"
            
            # Count workflows
            WORKFLOW_COUNT=$(find .github/workflows -name "*.yml" 2>/dev/null | wc -l)
            log_info "Found $WORKFLOW_COUNT GitHub workflows"
        else
            log_warning ".github/workflows/ missing"
        fi
        
        if [ -d ".github/ISSUE_TEMPLATE" ]; then
            log_success ".github/ISSUE_TEMPLATE/ exists"
        else
            log_warning ".github/ISSUE_TEMPLATE/ missing"
        fi
    else
        log_warning ".github/ directory missing"
    fi
}

# Check YAML files
check_yaml_files() {
    log_info "Checking YAML files..."
    
    if command -v yamllint &> /dev/null; then
        YAML_ERRORS=$(find . -name "*.yml" -o -name "*.yaml" | grep -v ".git" | xargs yamllint -c .yamllint 2>&1 | grep -c "error" || true)
        
        if [ "$YAML_ERRORS" -eq 0 ]; then
            log_success "All YAML files are valid"
        else
            log_warning "Found $YAML_ERRORS YAML errors"
        fi
    else
        log_warning "yamllint not installed, skipping YAML validation"
    fi
}

# Check JSON files
check_json_files() {
    log_info "Checking JSON files..."
    
    JSON_ERRORS=0
    for file in $(find . -name "*.json" -not -path "./.git/*"); do
        if ! python3 -m json.tool "$file" > /dev/null 2>&1; then
            log_error "Invalid JSON: $file"
            JSON_ERRORS=$((JSON_ERRORS + 1))
        fi
    done
    
    if [ "$JSON_ERRORS" -eq 0 ]; then
        log_success "All JSON files are valid"
    fi
}

# Generate report
generate_report() {
    echo ""
    echo "=============================="
    echo "Validation Report"
    echo "=============================="
    echo ""
    echo "Checks passed: $CHECKS_PASSED"
    echo "Checks failed: $CHECKS_FAILED"
    echo "Warnings: $CHECKS_WARNING"
    echo ""
    
    if [ "$CHECKS_FAILED" -gt 0 ]; then
        log_error "Validation failed with $CHECKS_FAILED errors"
        exit 1
    elif [ "$CHECKS_WARNING" -gt 0 ]; then
        log_warning "Validation passed with $CHECKS_WARNING warnings"
    else
        log_success "All validation checks passed!"
    fi
}

# Main function
main() {
    echo "=============================="
    echo "OpenOps Toolkit Release Validator"
    echo "=============================="
    echo ""
    
    check_required_files
    check_documentation
    check_ansible_structure
    check_n8n_workflows
    check_monitoring
    check_scripts
    check_github_config
    check_yaml_files
    check_json_files
    generate_report
}

# Run main function
main