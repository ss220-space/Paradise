#!/usr/bin/env bash
set -euo pipefail

# This script is not actually used by CI, but kept as a reference incase we refactor CI again

source _build_dependencies.sh

mkdir -p ~/.byond/bin

echo "Installing rust-g version: $RUSTG_VERSION"
wget -O ~/.byond/bin/librust_g.so "https://github.com/ss220-space/rust-g-tg/releases/download/$RUSTG_VERSION/librust_g.so"
chmod +x ~/.byond/bin/librust_g.so
echo "rust-g installed:"
ldd ~/.byond/bin/librust_g.so
