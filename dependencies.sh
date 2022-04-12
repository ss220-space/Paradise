#!/bin/bash

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
# Extracted from the Dockerfile. Change by editing Dockerfile's FROM command.
export BYOND_MAJOR=514
export BYOND_MINOR=1575

#rust_g git tag
export RUST_G_VERSION=2.1.1

#node version
export NODE_VERSION=16
export NODE_VERSION_PRECISE=16.14.0

# PHP version
export PHP_VERSION=7.2

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.7.2
