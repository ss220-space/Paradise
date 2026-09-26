#!/bin/bash
set -euo pipefail

DreamMaker ./paradise.dme
exec DreamDaemon paradise.dmb -port 3228 -trusted -close -verbose

