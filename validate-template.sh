#!/bin/bash

# Validation script for MaudiBlue BlueBuild template
# This script validates the template structure and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}================================${NC}"
    echo -e "${CYAN}  MaudiBlue Template Validation${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Function to check file existence
check_file() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        print_success "$description: $file"
        return 0
    else
        print_error "$description: $file (NOT FOUND)"
        return 1
    fi
}

# Function to check directory existence
check_directory() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        print_success "$description: $dir"
        return 0
    else
        print_error "$description: $dir (NOT FOUND)"
        return 1
    fi
}

# Function to check executable permissions
check_executable() {
    local file="$1"
    local description="$2"
    
    if [[ -x "$file" ]]; then
        print_success "$description: $file (executable)"
        return 0
    else
        print_warning "$description: $file (not executable)"
        return 1
    fi
}

# Function to validate YAML syntax
validate_yaml() {
    local file="$1"
    local description="$2"
    
    if command -v yamllint &> /dev/null; then
        if yamllint "$file" &> /dev/null; then
            print_success "$description: $file (YAML syntax valid)"
            return 0
        else
            print_error "$description: $file (YAML syntax invalid)"
            return 1
        fi
    else
        print_warning "$description: $file (yamllint not available, skipping YAML validation)"
        return 0
    fi
}

# Main validation function
validate_template() {
    print_header
    
    local errors=0
    
    print_status "Validating BlueBuild template structure..."
    echo ""
    
    # Check core files
    print_status "Checking core files..."
    check_file "recipes/recipe.yml" "Recipe configuration" || ((errors++))
    check_file "README.md" "README documentation" || ((errors++))
    check_file ".github/workflows/build.yml" "GitHub Actions workflow" || ((errors++))
    check_file "cosign.pub" "Cosign public key" || ((errors++))
    
    echo ""
    
    # Check script files
    print_status "Checking script files..."
    check_file "files/scripts/dotfiles-setup.sh" "Dotfiles setup script" || ((errors++))
    check_file "files/scripts/initial-setup.sh" "Initial setup script" || ((errors++))
    check_file "files/scripts/post-install-setup.sh" "Post-install setup script" || ((errors++))
    
    echo ""
    
    # Check system files
    print_status "Checking system files..."
    check_file "files/system/usr/local/bin/dotfiles-setup" "Dotfiles setup binary" || ((errors++))
    check_file "files/system/usr/local/bin/dotfiles-update" "Dotfiles update binary" || ((errors++))
    check_file "files/system/etc/systemd/user/dotfiles-update.service" "Systemd service" || ((errors++))
    check_file "files/system/etc/systemd/user/dotfiles-update.timer" "Systemd timer" || ((errors++))
    
    echo ""
    
    # Check executable permissions
    print_status "Checking executable permissions..."
    check_executable "files/scripts/dotfiles-setup.sh" "Dotfiles setup script" || ((errors++))
    check_executable "files/scripts/initial-setup.sh" "Initial setup script" || ((errors++))
    check_executable "files/scripts/post-install-setup.sh" "Post-install setup script" || ((errors++))
    check_executable "files/system/usr/local/bin/dotfiles-setup" "Dotfiles setup binary" || ((errors++))
    check_executable "files/system/usr/local/bin/dotfiles-update" "Dotfiles update binary" || ((errors++))
    
    echo ""
    
    # Validate YAML files
    print_status "Validating YAML files..."
    validate_yaml "recipes/recipe.yml" "Recipe configuration" || ((errors++))
    validate_yaml ".github/workflows/build.yml" "GitHub Actions workflow" || ((errors++))
    
    echo ""
    
    # Check directory structure
    print_status "Checking directory structure..."
    check_directory "files" "Files directory" || ((errors++))
    check_directory "files/scripts" "Scripts directory" || ((errors++))
    check_directory "files/system" "System directory" || ((errors++))
    check_directory "files/system/usr/local/bin" "Local bin directory" || ((errors++))
    check_directory "files/system/etc/systemd/user" "Systemd user directory" || ((errors++))
    check_directory "recipes" "Recipes directory" || ((errors++))
    check_directory ".github" "GitHub directory" || ((errors++))
    check_directory ".github/workflows" "GitHub workflows directory" || ((errors++))
    
    echo ""
    
    # Summary
    if [[ $errors -eq 0 ]]; then
        print_success "All validations passed! Template is ready for building."
        echo ""
        print_status "Next steps:"
        echo "  1. Commit and push your changes to GitHub"
        echo "  2. The GitHub Actions workflow will automatically build the image"
        echo "  3. The image will be available at ghcr.io/maudi/maudiblue:latest"
        echo "  4. Users can rebase to your image using rpm-ostree"
    else
        print_error "Found $errors validation errors. Please fix them before building."
        exit 1
    fi
}

# Run validation if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    validate_template
fi
