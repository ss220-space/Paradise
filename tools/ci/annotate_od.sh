#!/bin/bash

set -euo pipefail
python tools/ci/annotate_od.py "$@"
