#!/bin/bash
# Renders every map listed in maps.json at full resolution (32px per turf).
# Uses upstream SpacemanDMM dmm-tools, which draws objects as well as turfs.
set -euo pipefail

RENDERER="${RENDERER:-dmm-tools}"
OUT="${OUT:-data/webmap-renders}"
MAPS="${MAPS:-tools/webmap/maps.json}"

mkdir -p "$OUT"

python3 -c "
import json
for entry in json.load(open('$MAPS', encoding='utf-8'))['maps']:
    print(entry['dmm'])
" | while read -r dmm; do
	echo "rendering $dmm"
	"$RENDERER" minimap -o "$OUT" "./$dmm"
done

echo "renders in $OUT:"
ls -la "$OUT"
