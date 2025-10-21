#!/usr/bin/env bash
set -euo pipefail

mkdir -p /usr/share/hypr

if [ -d /usr/share/.git ]; then
  echo "[script] Updating existing dotfiles repo..."
  git -C /usr/share/dotfiles pull --ff-only || true
else
  echo "[script] Cloning dotfiles repo..."
  rm -rf /usr/share/hypr || true
  git clone --depth=1 https://github.com/DanielMauderer/MyLinux.git /usr/share
fi