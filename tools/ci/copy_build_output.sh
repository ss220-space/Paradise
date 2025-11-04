#!/bin/bash

echo "Copying build outputs..."
mkdir -p \
    $1/icons \
    $1/tgui/public \

echo "Copying .dmb and .rsc files..."
cp paradise.dmb paradise.rsc $1/

echo "Copying resources..."
cp -r icons/* $1/icons/
cp -r tgui/public/* $1/tgui/public/

echo "Build outputs successfully copied!"
