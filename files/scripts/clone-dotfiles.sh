#!/usr/bin/env bash
set -euo pipefail

mkdir -p /usr/local/share

if [ -d /usr/local/share/dotfiles/.git ]; then
  echo "[script] Updating existing dotfiles repo..."
  git -C /usr/local/share/dotfiles pull --ff-only || true
else
  echo "[script] Cloning dotfiles repo..."
  rm -rf /usr/local/share/dotfiles || true
  git clone --depth=1 https://github.com/DanielMauderer/MyLinux.git /usr/local/share/dotfiles
fi