#!/bin/bash
set -euo pipefail

cp config/example/* config/

#Apply test DB config for SQL connectivity
rm config/dbconfig.txt
cp tools/ci/dbconfig.txt config

# Now run the server and the unit tests
DreamDaemon paradise.dmb -close -trusted -verbose || EXIT_CODE=$?

# We don't care if extools dies
if [ $EXIT_CODE != 134 ]; then
   if [ $EXIT_CODE != 0 ]; then
      exit $EXIT_CODE
   fi
fi

# Check if the unit tests actually suceeded
cat data/clean_run.lk
