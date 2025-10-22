#!/usr/bin/env bash
set -euo pipefail

LOGFILE="/var/log/firstboot.log"

{
echo "🚀 Running first boot setup..."

USER_HOME="/home/${SUDO_USER:-$(logname)}"

# Clone dotfiles
if [ ! -d "$USER_HOME/.dotfiles" ]; then
  sudo -u "${SUDO_USER:-$(logname)}" git clone https://github.com/DanielMauderer/MyLinux "$USER_HOME/.dotfiles"
  sudo -u "${SUDO_USER:-$(logname)}" bash -c "cd ~/.dotfiles && ./install.sh || true"
fi

# Create toolbox
sudo -u "${SUDO_USER:-$(logname)}" toolbox create default || true

# Disable the service after running
systemctl disable firstboot.service

echo "✅ First boot setup complete."
} | tee -a "$LOGFILE"
