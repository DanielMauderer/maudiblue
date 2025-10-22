#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Installing cargo tools: bat and eza"

mkdir -p /usr/local/cargo/bin
export CARGO_HOME=/usr/local/cargo

cargo install bat eza

ln -sf /usr/local/cargo/bin/bat /usr/bin/bat
ln -sf /usr/local/cargo/bin/eza /usr/bin/eza

echo "✅ Cargo tools installed."
