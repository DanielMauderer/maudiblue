#!/bin/bash

# Fish shell setup script for Fedora Silverblue
# This script handles both initial installation and updates

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
    echo -e "${CYAN}  Fish Shell Setup for Silverblue${NC}"
    echo -e "${CYAN}================================${NC}"
    echo ""
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root"
    exit 1
fi

# Check if we're on Silverblue
if ! command -v rpm-ostree &> /dev/null; then
    print_error "This script is designed for Fedora Silverblue"
    exit 1
fi

# Check if Fish is already installed
FISH_INSTALLED=false
if command -v fish &> /dev/null; then
    FISH_INSTALLED=true
    print_warning "Fish shell is already installed"
fi

# Check if configuration exists
CONFIG_EXISTS=false
if [[ -d ~/.config/fish ]]; then
    CONFIG_EXISTS=true
    print_warning "Fish configuration already exists"
fi

print_header

# Determine if this is an update or fresh install
if [[ $FISH_INSTALLED == true && $CONFIG_EXISTS == true ]]; then
    print_status "Detected existing Fish installation with configuration"
    print_status "Running update mode..."
    UPDATE_MODE=true
else
    print_status "Running fresh installation mode..."
    UPDATE_MODE=false
fi

# Install Fish shell and fastfetch in one layer to reduce layering
print_status "Installing Fish shell and fastfetch via rpm-ostree (single layer)..."
# sudo rpm-ostree install fish fastfetch waydroid virt-manager libvirt qemu-kvm virt-viewer lxqt-policykit
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $(whoami)
newgrp libvirt
print_success "Fish shell and fastfetch installed"


# Install Zen Browser flatpak
print_status "Installing/updating Zen Browser flatpak..."
if flatpak list | grep -q "app.zen_browser.zen"; then
    print_status "Zen Browser already installed, updating..."
    flatpak update -y app.zen_browser.zen
else
    print_status "Installing Zen Browser..."
    flatpak install -y flathub app.zen_browser.zen
fi

# Set up configuration directories
print_status "Setting up configuration directories..."

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
    
    ln -sf "$source" "$target"
    print_success "$name configuration linked"
}

# Get the absolute path of the current directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Link Fish configuration
print_status "Setting up Fish configuration..."
mkdir -p ~/.config/fish
create_symlink "$REPO_DIR/fish/config.fish" "$HOME/.config/fish/config.fish" "Fish config"
create_symlink "$REPO_DIR/fish/aliases.fish" "$HOME/.config/fish/aliases.fish" "Fish aliases"
create_symlink "$REPO_DIR/fish/functions.fish" "$HOME/.config/fish/functions.fish" "Fish functions"
create_symlink "$REPO_DIR/fish/completions.fish" "$HOME/.config/fish/completions.fish" "Fish completions"

# Link Hyprland configuration
print_status "Setting up Hyprland configuration..."
create_symlink "$REPO_DIR/hypr" "$HOME/.config/hypr" "Hyprland"

# Link Waybar configuration
print_status "Setting up Waybar configuration..."
create_symlink "$REPO_DIR/waybar" "$HOME/.config/waybar" "Waybar"

# Link Fastfetch configuration
print_status "Setting up Fastfetch configuration..."
create_symlink "$REPO_DIR/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"

print_success "All configuration directories linked"

# Set Fish as default shell if not already
CURRENT_SHELL=$(getent passwd $USER | cut -d: -f7)
if [[ $CURRENT_SHELL != "/usr/bin/fish" ]]; then
    print_status "Setting Fish as default shell..."
    # Add Fish to /etc/shells if not already there
    if ! grep -q "/usr/bin/fish" /etc/shells; then
        echo "/usr/bin/fish" | sudo tee -a /etc/shells
    fi
    sudo chsh -s /usr/bin/fish $USER
    print_success "Fish set as default shell"
else
    print_status "Fish is already the default shell"
fi

# Set up toolbox container with command line tools
print_status "Setting up toolbox container with command line tools..."
if toolbox list | grep -q "dev-tools"; then
    print_status "Toolbox container 'dev-tools' already exists, updating..."
    toolbox run -c dev-tools bash -c "
        set -e
        sudo dnf update -y
        sudo dnf install -y bat fd-find ripgrep fzf tree btop neofetch
        sudo dnf install -y nodejs npm python3-pip rust cargo
        sudo dnf install -y gcc gcc-c++ make cmake
        sudo dnf install -y docker podman buildah skopeo
        sudo dnf install -y git curl wget vim nano
        cargo install eza
    "
else
    print_status "Creating new toolbox container 'dev-tools'..."
    toolbox create --image fedora-toolbox:latest dev-tools
    toolbox run -c dev-tools bash -c "
        set -e
        sudo dnf update -y
        sudo dnf install -y bat fd-find ripgrep fzf tree btop neofetch
        sudo dnf install -y nodejs npm python3-pip rust cargo
        sudo dnf install -y gcc gcc-c++ make cmake
        sudo dnf install -y docker podman buildah skopeo
        sudo dnf install -y git curl wget vim nano
        cargo install eza
    "
fi
print_success "Toolbox container with command line tools ready"

# Check for pending updates
print_status "Checking for pending system updates..."
if rpm-ostree status | grep -q "pending"; then
    print_warning "System has pending updates. You may want to run 'rpm-ostree upgrade' and reboot."
fi

# Final status
echo ""
print_success "Setup completed successfully!"
echo ""
echo "📋 Summary:"
echo "  • Fish shell: $(if $FISH_INSTALLED; then echo "Updated"; else echo "Installed"; fi)"
echo "  • Fastfetch: Installed in Silverblue"
echo "  • Command line tools: Installed in toolbox container"
echo "  • Zen Browser: Installed/Updated"
echo "  • Configuration: $(if $UPDATE_MODE; then echo "Updated"; else echo "Installed"; fi)"
echo "  • Fish config: Linked to ~/.config/fish/"
echo "  • Hyprland config: Linked to ~/.config/hypr/"
echo "  • Waybar config: Linked to ~/.config/waybar/"
echo "  • Fastfetch config: Linked to ~/.config/fastfetch/"
echo "  • Toolbox container: Ready with eza, bat, fd, ripgrep, fzf, tree, btop, neofetch"
echo ""
echo "🔧 Available aliases:"
echo "  • c, ff, ls, ll, lt, shutdown, wifi"
echo "  • update, reboot, suspend, hibernate"
echo "  • tb, tbr (toolbox commands)"
echo "  • fp, fpi, fpu, fpr, fpl (flatpak commands)"
echo "  • gs, ga, gc, gp, gl (git commands)"
echo "  • top (btop), cat (bat), less (bat), more (bat), tree, fd, rg, fzf, neofetch (via toolbox)"
echo ""
if [[ $UPDATE_MODE == false ]]; then
    print_warning "You need to reboot for the shell change to take effect."
    echo "Alternatively, you can start using Fish immediately with: exec fish"
else
    print_status "Configuration updated. You can reload Fish with: exec fish"
fi
echo ""
print_status "Run this script again anytime to update your configuration!"
echo ""
print_status "Configuration directories are now symlinked to this repository:"
echo "  • ~/.config/fish/ → $REPO_DIR/fish/"
echo "  • ~/.config/hypr/ → $REPO_DIR/hypr/"
echo "  • ~/.config/waybar/ → $REPO_DIR/waybar/"
echo "  • ~/.config/fastfetch/ → $REPO_DIR/fastfetch/"
echo ""
print_status "Any changes you make to the repository will be reflected in your system!"
