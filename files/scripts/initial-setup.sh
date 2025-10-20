#!/bin/bash

# Initial setup script for BlueBuild image
# This script runs on first boot to set up dotfiles and user environment

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
    echo -e "${CYAN}  BlueBuild Initial Setup${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Function to run initial setup
run_initial_setup() {
    print_header
    
    # Run dotfiles linking (dotfiles pre-cloned into image)
    print_status "Linking dotfiles into user config..."
    /usr/local/share/scripts/dotfiles-setup.sh
    
    # Set up Fish as default shell if available
    if command -v fish &> /dev/null; then
        print_status "Setting Fish as default shell..."
        if ! grep -q "/usr/bin/fish" /etc/shells; then
            echo "/usr/bin/fish" | sudo tee -a /etc/shells
        fi
        sudo chsh -s /usr/bin/fish $USER
        print_success "Fish set as default shell"
    fi
    
    print_success "Initial setup completed!"
    echo ""
    echo "📋 What was set up:"
    echo "  • Dotfiles linked from image-cloned repository"
    echo "  • Fish shell set as default (if available)"
    echo ""
    echo "🔧 Manual commands:"
    echo "  • Relink dotfiles: /usr/local/share/scripts/dotfiles-setup.sh"
    echo ""
    print_warning "You may need to log out and back in for all changes to take effect."
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_initial_setup
fi
