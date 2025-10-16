#!/bin/bash
set -euo pipefail

cp config/example/* config/

#Apply test DB config for SQL connectivity
rm config/dbconfig.txt
cp tools/ci/dbconfig.txt config

# Now run the server and the game tests
DreamDaemon paradise.dmb -close -trusted -verbose

# Check if the game tests actually suceeded
cat data/clean_run.lk
