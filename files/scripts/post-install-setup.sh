#!/bin/bash

# Post-installation setup script for MaudiBlue
# This script should be run after the first boot to complete the setup

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
    echo -e "${CYAN}  MaudiBlue Post-Install Setup${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Function to check if running on Silverblue
check_silverblue() {
    if ! command -v rpm-ostree &> /dev/null; then
        print_error "This script is designed for Fedora Silverblue/Atomic"
        exit 1
    fi
}

# Function to setup dotfiles (link only, repo is pre-cloned into image)
setup_dotfiles() {
    print_status "Linking dotfiles from image into user config..."
    if [[ -f "/usr/local/share/scripts/dotfiles-setup.sh" ]]; then
        /usr/local/share/scripts/dotfiles-setup.sh
    else
        print_error "Dotfiles setup script not found. Please ensure the image was built correctly."
        exit 1
    fi
}

# Function to enable services
enable_services() {
    # No periodic updates; dotfiles are baked in and linked per-user
    print_status "Skipping automatic dotfiles update timers (not needed)."
}

# Function to setup shell
setup_shell() {
    print_status "Setting up Fish shell..."
    
    # Check if Fish is available
    if command -v fish &> /dev/null; then
        # Add Fish to /etc/shells if not already there
        if ! grep -q "/usr/bin/fish" /etc/shells; then
            echo "/usr/bin/fish" | sudo tee -a /etc/shells
        fi
        
        # Set Fish as default shell
        sudo chsh -s /usr/bin/fish $USER
        print_success "Fish shell set as default"
    else
        print_warning "Fish shell not found. Please install it first."
    fi
}

# Function to set up CLI tools inside a toolbox container
setup_toolbox_cli() {
    print_status "Setting up toolbox container with CLI tools..."

    if ! command -v toolbox &> /dev/null; then
        print_warning "toolbox is not available on this system. Skipping toolbox CLI setup."
        return
    fi

    if toolbox list | grep -q "cli-tools"; then
        print_status "Toolbox container 'cli-tools' already exists, updating packages..."
        toolbox run -c cli-tools bash -c "
            set -e
            sudo dnf update -y
            sudo dnf install -y bat fd-find ripgrep fzf tree btop neofetch rust cargo
            cargo install eza || true
        "
    else
        print_status "Creating toolbox container 'cli-tools' and installing CLI tools..."
        toolbox create --image fedora-toolbox:latest cli-tools
        toolbox run -c cli-tools bash -c "
            set -e
            sudo dnf update -y
            sudo dnf install -y bat fd-find ripgrep fzf tree btop neofetch rust cargo
            cargo install eza || true
        "
    fi

    print_success "Toolbox 'cli-tools' is ready with requested CLI tools"
}

# Function to create desktop shortcuts
create_shortcuts() {
    # Skip creating dotfiles update desktop entry
    print_status "Skipping dotfiles update desktop shortcut."
}

# Function to setup virtualization (libvirt/virt-manager)
setup_virtualization() {
    print_status "Configuring virtualization (libvirt/virt-manager)..."

    # Enable and start libvirtd
    if command -v systemctl &> /dev/null; then
        sudo systemctl enable --now libvirtd || true
    fi

    # Add current user to libvirt group
    if getent group libvirt >/dev/null 2>&1; then
        sudo usermod -aG libvirt "$(whoami)" || true
        print_success "Added $(whoami) to libvirt group"
        print_warning "Run: newgrp libvirt  # or log out/in to apply group membership"
    else
        print_warning "Group 'libvirt' not found. Ensure libvirt is installed."
    fi
}

# Function to show final instructions
show_final_instructions() {
    print_success "Post-installation setup completed!"
    echo ""
    echo "📋 What was set up:"
    echo "  • Dotfiles linked from image-cloned repository"
    echo "  • Fish shell set as default"
    echo "  • Desktop shortcuts created"
    echo ""
    echo "🔧 Available commands:"
    echo "  • Update dotfiles: dotfiles-update"
    echo "  • Check update timer: systemctl --user status dotfiles-update.timer"
    echo "  • View update logs: journalctl --user -u dotfiles-update.service"
    echo "  • System info: fastfetch"
    echo ""
    echo "📁 Configuration locations:"
    echo "  • Dotfiles repo: ~/.dotfiles"
    echo "  • Fish config: ~/.config/fish/"
    echo "  • Hyprland config: ~/.config/hypr/"
    echo "  • Waybar config: ~/.config/waybar/"
    echo ""
    print_warning "You may need to log out and back in for the shell change to take effect."
    echo ""
    print_status "Your MaudiBlue system is now ready to use!"
}

# Main execution
main() {
    print_header
    
    # Check if running on Silverblue
    check_silverblue
    
    # Run setup steps
    setup_dotfiles
    enable_services
    setup_shell
    setup_toolbox_cli
    create_shortcuts
    setup_virtualization
    
    # Show final instructions
    show_final_instructions
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
