#!/bin/bash

apt-get update
apt-get install -y docker.io

mkdir -p /opt/meili_data

docker run -d \
  --name meilisearch \
  -p 7700:7700 \
  -v /opt/meili_data:/meili_data \
  getmeili/meilisearch:v1.7 \
  meilisearch --db-path /meili_data --master-key mysecuremasterkey
