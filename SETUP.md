# MaudiBlue Setup Guide

This guide will help you set up your MaudiBlue BlueBuild template and get it ready for building.

## Prerequisites

- A GitHub repository (fork this template or create your own)
- GitHub Actions enabled for your repository
- A GitHub Personal Access Token with appropriate permissions (for signing)

## Quick Setup

### 1. Fork or Clone This Repository

```bash
# If forking on GitHub, then clone your fork:
git clone https://github.com/YOUR_USERNAME/maudiblue.git
cd maudiblue

# Or clone this template directly:
git clone https://github.com/maudi/maudiblue.git
cd maudiblue
```

### 2. Customize Your Configuration

Edit `recipes/recipe.yml` to customize your image:

```yaml
# Change the name and description
name: your-image-name
description: Your custom BlueBuild image

# Add or remove packages
install:
  packages:
    - your-package-here

# Add or remove flatpaks
install:
  - your.flatpak.app
```

### 3. Set Up GitHub Secrets

Go to your repository settings and add these secrets:

- `SIGNING_SECRET`: Your cosign private key for signing images
  ```bash
  # Generate a new key pair
  cosign generate-key-pair
  # Copy the private key content to SIGNING_SECRET
  ```

### 4. Update Repository Information

Update the following files with your information:

- `README.md`: Change the image name and repository URLs
- `.github/workflows/build.yml`: Update the registry name if needed
- `cosign.pub`: Replace with your public key

### 5. Test Your Template

Run the validation script to check everything:

```bash
./validate-template.sh
```

### 6. Build Your Image

Commit and push your changes:

```bash
git add .
git commit -m "Initial MaudiBlue template setup"
git push origin main
```

The GitHub Actions workflow will automatically build your image and publish it to `ghcr.io/YOUR_USERNAME/YOUR_IMAGE_NAME:latest`.

## Customization Options

### Adding More Packages

Edit `recipes/recipe.yml` and add packages to the `install` section:

```yaml
- type: dnf
  install:
    packages:
      - your-package-here
      - another-package
```

### Adding More Flatpaks

Edit `recipes/recipe.yml` and add to the `install` section:

```yaml
- type: default-flatpaks
  configurations:
    - install:
        - your.flatpak.app
        - another.flatpak.app
```

### Customizing Dotfiles Setup

Edit the scripts in `files/scripts/` to customize the dotfiles setup process:

- `dotfiles-setup.sh`: Main dotfiles setup logic
- `initial-setup.sh`: First boot setup
- `post-install-setup.sh`: Post-installation setup

### Adding System Files

Place system files in `files/system/` and they will be copied to the image root:

```
files/system/
├── etc/
│   └── systemd/
│       └── user/
│           └── your-service.service
├── usr/
│   └── local/
│       └── bin/
│           └── your-script
└── ...
```

## Building Locally

To build the image locally:

```bash
# Install BlueBuild
pip install blue-build

# Build the image
blue-build build recipes/recipe.yml
```

## Testing Your Image

After building, you can test your image by rebasing to it:

```bash
# Rebase to your image
rpm-ostree rebase ostree-unverified-registry:ghcr.io/YOUR_USERNAME/YOUR_IMAGE_NAME:latest

# Reboot to apply changes
systemctl reboot
```

## Troubleshooting

### Build Failures

1. Check the GitHub Actions logs for specific error messages
2. Validate your YAML syntax
3. Ensure all required files are present

### Image Not Working

1. Check if the base image is correct
2. Verify package names in the recipe
3. Test with a minimal recipe first

### Dotfiles Not Working

1. Ensure the GitHub repository is accessible
2. Check the dotfiles setup script for errors
3. Verify the systemd service is enabled

## Advanced Configuration

### Custom Base Image

Change the base image in `recipes/recipe.yml`:

```yaml
base-image: ghcr.io/your-org/your-base-image
image-version: latest
```

### Multiple Recipes

You can have multiple recipe files for different variants:

```
recipes/
├── recipe.yml          # Main recipe
├── minimal.yml         # Minimal variant
└── development.yml     # Development variant
```

Update `.github/workflows/build.yml` to build multiple recipes:

```yaml
matrix:
  recipe:
    - recipes/recipe.yml
    - recipes/minimal.yml
    - recipes/development.yml
```

### Custom Modules

You can create custom BlueBuild modules for complex setups. See the [BlueBuild documentation](https://blue-build.org/) for more information.

## Support

- [BlueBuild Documentation](https://blue-build.org/)
- [Universal Blue Community](https://universal-blue.org/)
- [GitHub Issues](https://github.com/maudi/maudiblue/issues)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
