# MaudiBlue - Personal BlueBuild Image

A custom BlueBuild image based on wayblue hyprland with automated dotfiles management and development tools.

## Features

- **Base**: wayblue hyprland (Fedora Silverblue with Hyprland)
- **Automated Dotfiles**: Automatic cloning and linking from GitHub repository
- **Development Tools**: Fish shell, Node.js, Rust, Python, Git, and more
- **Container Support**: Podman, Buildah, Skopeo
- **Flatpak Apps**: Firefox, Zen Browser, VS Code, Discord, Spotify, and more
- **Auto-Updates**: Daily automatic dotfiles updates via systemd timer

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/maudi/maudiblue:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/maudi/maudiblue:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

## First Boot Setup

After installation, run the initial setup script to configure dotfiles:

```bash
# Run the initial setup (this will be available in the image)
sudo /usr/local/share/scripts/initial-setup.sh
```

Or manually set up dotfiles:

```bash
# Clone and link dotfiles
dotfiles-setup

# Enable automatic updates
systemctl --user enable dotfiles-update.timer
systemctl --user start dotfiles-update.timer
```

## Dotfiles Management

### Automatic Updates

The image includes a systemd timer that automatically updates your dotfiles daily from the GitHub repository:

- **Timer**: `dotfiles-update.timer` (runs daily)
- **Service**: `dotfiles-update.service`
- **Manual update**: `dotfiles-update`

### Manual Commands

```bash
# Update dotfiles manually
dotfiles-update

# Check update timer status
systemctl --user status dotfiles-update.timer

# View update logs
journalctl --user -u dotfiles-update.service

# Disable automatic updates
systemctl --user disable dotfiles-update.timer
```

### Dotfiles Repository

The image automatically clones and links dotfiles from:
- **Repository**: https://github.com/DanielMauderer/MyLinux.git
- **Local directory**: `~/.dotfiles`
- **Config directory**: `~/.config`

Supported configurations:
- Fish shell (`~/.config/fish/`)
- Hyprland (`~/.config/hypr/`)
- Waybar (`~/.config/waybar/`)
- Fastfetch (`~/.config/fastfetch/`)
- Alacritty, Kitty, Neovim, Vim, Zsh, Bash

## Included Software

### System Packages
- **Shell**: Fish shell with fastfetch
- **Development**: Git, Node.js, Rust, Python, GCC, Make, CMake
- **Containers**: Podman, Buildah, Skopeo
- **Editors**: Vim, Nano, Micro
- **Utilities**: Htop, Tree, Curl, Wget, Rsync

### Flatpak Applications
- **Browsers**: Firefox, Zen Browser
- **Development**: Visual Studio Code
- **Communication**: Discord, Telegram
- **Media**: Spotify
- **System**: Flatseal, Desktop Files

## Customization

### Adding More Packages

Edit `recipes/recipe.yml` and add packages to the `install` section:

```yaml
- type: dnf
  install:
    packages:
      - your-package-here
```

### Adding More Flatpaks

Edit `recipes/recipe.yml` and add to the `install` section:

```yaml
- type: default-flatpaks
  configurations:
    - install:
        - your.flatpak.app
```

### Modifying Dotfiles Setup

Edit the scripts in `files/scripts/` to customize the dotfiles setup process.

## Building the Image

This repository uses GitHub Actions to automatically build the image. The build process:

1. Uses the BlueBuild GitHub Action
2. Builds from the `recipes/recipe.yml` configuration
3. Publishes to `ghcr.io/maudi/maudiblue:latest`
4. Signs the image with cosign

### Manual Build

To build locally:

```bash
# Install BlueBuild
pip install blue-build

# Build the image
blue-build build recipes/recipe.yml
```

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running:

```bash
cosign verify --key cosign.pub ghcr.io/maudi/maudiblue
```

## Troubleshooting

### Dotfiles Not Updating

1. Check if the timer is enabled:
   ```bash
   systemctl --user status dotfiles-update.timer
   ```

2. Check for errors in the service:
   ```bash
   journalctl --user -u dotfiles-update.service
   ```

3. Manually run the update:
   ```bash
   dotfiles-update
   ```

### Configuration Not Applied

1. Ensure dotfiles are properly linked:
   ```bash
   ls -la ~/.config/
   ```

2. Re-run the setup:
   ```bash
   dotfiles-setup
   ```

### Fish Shell Issues

1. Check if Fish is the default shell:
   ```bash
   echo $SHELL
   ```

2. Set Fish as default:
   ```bash
   sudo chsh -s /usr/bin/fish $USER
   ```

## Contributing

1. Fork the repository
2. Make your changes
3. Test the build locally
4. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [BlueBuild](https://blue-build.org/) for the build system
- [wayblue](https://github.com/wayblueorg/wayblue) for the base image
- [Universal Blue](https://universal-blue.org/) for inspiration