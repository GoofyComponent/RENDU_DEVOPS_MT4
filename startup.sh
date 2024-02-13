#!/bin/bash

terraform init
terraform get
terraform state rm docker_volume.prom_data
terraform apply -auto-approve

docker-compose up -d --no-deps --build