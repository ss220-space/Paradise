#!/bin/bash
# Generate maps
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 --disable icon-smoothing "./_maps/map_files/cyberiad/cyberiad.dmm"
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 --disable icon-smoothing "./_maps/map_files/Delta/delta.dmm"
tools/github-actions/dmm-tools-para minimap --enable nanomaps --width 2040 --height 2040 --disable icon-smoothing "./_maps/map_files/nova/nova.dmm"

# Move and rename files so the game understands them
mv "data/minimaps/cyberiad-1.png" "icons/_nanomaps/Cyberiad_nanomap_z1.png"
mv "data/minimaps/delta-1.png" "icons/_nanomaps/Delta_nanomap_z1.png"
mv "data/minimaps/nova-1.png" "icons/_nanomaps/Nova_nanomap_z1.png"
mv "data/minimaps/nova-2.png" "icons/_nanomaps/Nova_nanomap_z2.png"
