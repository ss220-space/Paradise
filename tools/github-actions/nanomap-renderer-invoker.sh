#!/bin/bash
# Generate maps
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 --disable icon-smoothing "./_maps/map_files/cyberiad/cyberiad.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 --disable icon-smoothing "./_maps/map_files/Delta/delta.dmm"
tools/github-actions/nanomap-renderer minimap -w 2040 -h 2040 --disable icon-smoothing "./_maps/map_files/nova/nova.dmm"
# Move and rename files so the game understands them
cd "data/nanomaps"
mv "cyberiad_nanomap_z1.png" "Cyberiad_nanomap_z1.png"
mv "delta_nanomap_z1.png" "Delta_nanomap_z1.png"
mv "nova_nanomap_z1.png" "Nova_nanomap_z1.png"
mv "nova_nanomap_z2.png" "Nova_nanomap_z2.png"
cd "../../"
cp "data/nanomaps/Cyberiad_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Delta_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Nova_nanomap_z1.png" "icons/_nanomaps"
cp "data/nanomaps/Nova_nanomap_z2.png" "icons/_nanomaps"
