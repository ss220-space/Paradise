#!/usr/bin/env bash
set -euo pipefail

source _build_dependencies.sh

mkdir -p ~/.byond/bin

echo "Installing dmjit version: $DMJIT_VERSION"
wget -O ~/.byond/bin/libdmjit.so "https://github.com/ss220-space/dmjit/releases/download/$DMJIT_VERSION/libdmjit.so"
chmod +x ~/.byond/bin/libdmjit.so
echo "dmjit installed:"
ldd ~/.byond/bin/libdmjit.so
