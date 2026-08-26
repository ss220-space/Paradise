#!/bin/bash
source _build_dependencies.sh

wget -O ~/dmm-tools "https://github.com/SpaceManiac/SpacemanDMM/releases/download/$SPACEMANDMM_TAG/dmm-tools"
chmod +x ~/dmm-tools
~/dmm-tools --version
