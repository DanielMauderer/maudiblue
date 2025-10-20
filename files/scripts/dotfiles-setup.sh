#!/bin/bash

# Dotfiles setup script for BlueBuild
# This script handles cloning and linking dotfiles from GitHub repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="/usr/local/share/dotfiles" # cloned at build time by script module
CONFIG_DIR="/home/$USER/.config"

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
    echo -e "${CYAN}  Dotfiles Setup for BlueBuild${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Function to create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    if [[ -L "$target" ]]; then
        print_status "Updating existing $name symlink..."
        rm "$target"
    elif [[ -d "$target" || -f "$target" ]]; then
        print_status "Backing up existing $name configuration..."
        mv "$target" "$target.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"
    
    ln -sf "$source" "$target"
    print_success "$name configuration linked"
}

# Function to setup dotfiles
setup_dotfiles() {
    print_header
    
    # Dotfiles are expected to exist in the image at $DOTFILES_DIR
    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR. Ensure recipe script cloned it."
        exit 1
    fi
    
    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"
    
    # Link configurations
    print_status "Setting up configuration links..."
    
    # Link Fish configuration
    if [[ -d "$DOTFILES_DIR/fish" ]]; then
        create_symlink "$DOTFILES_DIR/fish" "$CONFIG_DIR/fish" "Fish"
    fi
    
    # Link Hyprland configuration
    if [[ -d "$DOTFILES_DIR/hypr" ]]; then
        create_symlink "$DOTFILES_DIR/hypr" "$CONFIG_DIR/hypr" "Hyprland"
    fi
    
    # Link Waybar configuration
    if [[ -d "$DOTFILES_DIR/waybar" ]]; then
        create_symlink "$DOTFILES_DIR/waybar" "$CONFIG_DIR/waybar" "Waybar"
    fi
    
    # Link Fastfetch configuration
    if [[ -d "$DOTFILES_DIR/fastfetch" ]]; then
        create_symlink "$DOTFILES_DIR/fastfetch" "$CONFIG_DIR/fastfetch" "Fastfetch"
    fi
    
    # Link other common configs
    for config in "alacritty" "kitty" "nvim" "vim" "zsh" "bash"; do
        if [[ -d "$DOTFILES_DIR/$config" ]]; then
            create_symlink "$DOTFILES_DIR/$config" "$CONFIG_DIR/$config" "$config"
        fi
    done
    
    print_success "Dotfiles setup completed!"
    echo ""
    echo "📋 Summary:"
    echo "  • Local directory: $DOTFILES_DIR"
    echo "  • Config directory: $CONFIG_DIR"
    echo ""
    echo "🔧 To relink dotfiles manually:"
    echo "  re-run: /usr/local/share/scripts/dotfiles-setup.sh"
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_dotfiles
fi
