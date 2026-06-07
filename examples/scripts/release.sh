#!/bin/bash
# Release Automation Script
# OpenOps Toolkit

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/ujgsp/OpenOpsToolkit.git"
CHANGELOG_FILE="CHANGELOG.md"
VERSION_FILE="VERSION"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if git is clean
check_git_status() {
    if [ -n "$(git status --porcelain)" ]; then
        log_error "Git working directory is not clean. Please commit or stash changes."
    fi
    log_success "Git working directory is clean"
}

# Get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        CURRENT_VERSION=$(cat "$VERSION_FILE")
    else
        CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    fi
    log_info "Current version: $CURRENT_VERSION"
}

# Calculate next version
calculate_next_version() {
    # Parse version
    VERSION=${CURRENT_VERSION#v}
    MAJOR=$(echo $VERSION | cut -d. -f1)
    MINOR=$(echo $VERSION | cut -d. -f2)
    PATCH=$(echo $VERSION | cut -d. -f3)
    
    # Increment based on argument
    case $1 in
        major)
            MAJOR=$((MAJOR + 1))
            MINOR=0
            PATCH=0
            ;;
        minor)
            MINOR=$((MINOR + 1))
            PATCH=0
            ;;
        patch)
            PATCH=$((PATCH + 1))
            ;;
        *)
            log_error "Invalid version type. Use: major, minor, or patch"
            ;;
    esac
    
    NEXT_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
    log_info "Next version: $NEXT_VERSION"
}

# Generate changelog
generate_changelog() {
    log_info "Generating changelog..."
    
    # Get previous tag
    PREV_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
    
    # Generate changelog
    if [ -z "$PREV_TAG" ]; then
        CHANGELOG=$(git log --oneline --no-decorate)
    else
        CHANGELOG=$(git log --oneline --no-decorate ${PREV_TAG}..HEAD)
    fi
    
    # Create changelog file
    cat > "CHANGELOG_RELEASE.md" << EOF
# Release $NEXT_VERSION

**Release Date**: $(date +%Y-%m-%d)

## What's Changed

$CHANGELOG

## Installation

\`\`\`bash
git clone $REPO_URL
cd OpenOpsToolkit
git checkout $NEXT_VERSION
\`\`\`

## Documentation

- [README](README.md)
- [ROADMAP](ROADMAP.md)
- [CONTRIBUTING](CONTRIBUTING.md)

## Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for details.
EOF
    
    log_success "Changelog generated: CHANGELOG_RELEASE.md"
}

# Update CHANGELOG.md
update_changelog() {
    log_info "Updating CHANGELOG.md..."
    
    # Create new entry
    ENTRY="## [$NEXT_VERSION] - $(date +%Y-%m-%d)\n\n### Added\n- See release notes for details\n"
    
    # Insert after header
    sed -i "/## \[Unreleased\]/a\\
    \\
    $ENTRY" "$CHANGELOG_FILE"
    
    log_success "CHANGELOG.md updated"
}

# Update VERSION file
update_version() {
    echo "$NEXT_VERSION" > "$VERSION_FILE"
    log_success "VERSION file updated to $NEXT_VERSION"
}

# Create git tag
create_tag() {
    log_info "Creating git tag: $NEXT_VERSION"
    
    git add .
    git commit -m "release: $NEXT_VERSION"
    git tag -a "$NEXT_VERSION" -m "Release $NEXT_VERSION"
    
    log_success "Git tag created: $NEXT_VERSION"
}

# Push changes
push_changes() {
    log_info "Pushing changes..."
    
    git push origin main
    git push origin "$NEXT_VERSION"
    
    log_success "Changes pushed to remote"
}

# Create release archive
create_archive() {
    log_info "Creating release archive..."
    
    # Create release directory
    mkdir -p release
    
    # Create archive
    git archive --format=tar.gz --prefix="openops-toolkit-${NEXT_VERSION}/" "$NEXT_VERSION" > "release/openops-toolkit-${NEXT_VERSION}.tar.gz"
    git archive --format=zip --prefix="openops-toolkit-${NEXT_VERSION}/" "$NEXT_VERSION" > "release/openops-toolkit-${NEXT_VERSION}.zip"
    
    log_success "Release archives created in release/"
}

# Main function
main() {
    echo "=============================="
    echo "OpenOps Toolkit Release Script"
    echo "=============================="
    echo ""
    
    # Check arguments
    if [ -z "$1" ]; then
        echo "Usage: $0 <version-type>"
        echo ""
        echo "Version types:"
        echo "  major  - Breaking changes (v1.0.0 -> v2.0.0)"
        echo "  minor  - New features (v1.0.0 -> v1.1.0)"
        echo "  patch  - Bug fixes (v1.0.0 -> v1.0.1)"
        exit 1
    fi
    
    # Check git status
    check_git_status
    
    # Get current version
    get_current_version
    
    # Calculate next version
    calculate_next_version $1
    
    # Confirm release
    echo ""
    echo "Release: $CURRENT_VERSION -> $NEXT_VERSION"
    echo ""
    read -p "Continue with release? (y/n) " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Release cancelled"
        exit 0
    fi
    
    # Generate changelog
    generate_changelog
    
    # Update CHANGELOG.md
    update_changelog
    
    # Update VERSION file
    update_version
    
    # Create git tag
    create_tag
    
    # Push changes
    push_changes
    
    # Create release archive
    create_archive
    
    echo ""
    echo "=============================="
    echo "Release Complete!"
    echo "=============================="
    echo ""
    echo "Version: $NEXT_VERSION"
    echo "Tag: $NEXT_VERSION"
    echo "Archive: release/openops-toolkit-${NEXT_VERSION}.tar.gz"
    echo ""
    echo "Next steps:"
    echo "1. Create GitHub release with CHANGELOG_RELEASE.md"
    echo "2. Upload release archives"
    echo "3. Announce release"
    echo ""
}

# Run main function
main "$@"