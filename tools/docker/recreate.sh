#!/bin/bash

docker-compose down

cp .env.local .env

docker-compose up --build -d
