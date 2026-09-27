#!/bin/bash

# Called by TGS before compiling, with the deployment directory as $1.
# Builds tgui and prepends the TGS define to the dme.

set -e
set -x

original_dir=$PWD
cd "$1"

if [ -x "$HOME/.bun/bin/bun" ]; then
	export PATH="$HOME/.bun/bin:$PATH"
fi

env TG_BOOTSTRAP_CACHE="$original_dir" CBT_BUILD_MODE="TGS" tools/bootstrap/javascript.sh tools/build/build.ts
