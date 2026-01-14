#!/bin/bash
set -euo pipefail

if [ -z "${BYOND_MAJOR+x}" ]; then
  source _build_dependencies.sh
  # if some other build step hasn't specified the specific BYOND version we're not
  # gonna get it straight from _build_dependencies.sh so one more fallback here
  BYOND_MAJOR=$STABLE_BYOND_MAJOR
  BYOND_MINOR=$STABLE_BYOND_MINOR

  if [ -z "$1" ]; then
    echo "No arg specified. Assuming STABLE."
  else
    if [ "$1" == "BETA" ]; then
      BYOND_MAJOR=$BETA_BYOND_MAJOR
      BYOND_MINOR=$BETA_BYOND_MINOR
    fi
  fi


fi

if [ -d "$HOME/BYOND/byond/bin" ] && grep -Fxq "${BYOND_MAJOR}.${BYOND_MINOR}" $HOME/BYOND/version.txt;
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  rm -rf "$HOME/BYOND"
  mkdir -p "$HOME/BYOND"
  cd "$HOME/BYOND"

  if ! curl -L --fail --retry 3 \
  	-H "User-Agent: ParadiseSS1984/Paradise CI" \
    "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" \
    -o byond.zip; then
    echo "Failed to download BYOND!"
    exit 1
  fi

  if ! file byond.zip | grep -q "Zip archive"; then
    echo "Invalid archive detected:"
    head -n5 byond.zip
    exit 1
  fi

  unzip -q byond.zip

  if [ ! -d "byond" ]; then
    echo "Extraction failed! Contents:"
    ls -la
    exit 1
  fi

  rm byond.zip
  cd byond
  make here
  echo "$BYOND_MAJOR.$BYOND_MINOR" > "$HOME/BYOND/version.txt"
  cd ~/
fi
