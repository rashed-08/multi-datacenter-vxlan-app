#!/bin/bash

echo "Creating Docker networks for DC1, DC2, and DC3..."

docker network create --driver bridge --subnet=10.200.0.0/16 dc1-net
docker network create --driver bridge --subnet=10.300.0.0/16 dc2-net
docker network create --driver bridge --subnet=10.400.0.0/16 dc3-net

echo "Networks created."