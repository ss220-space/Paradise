#!/bin/bash

docker-compose down

[[ -f .env ]] || cp .env.example .env

./copy_config.sh

docker-compose up --build -d
