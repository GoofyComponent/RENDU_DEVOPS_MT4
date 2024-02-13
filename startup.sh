#!/bin/bash

terraform state rm docker_volume.prom_data
terraform init
terraform get
terraform apply -auto-approve

docker-compose up -d --no-deps --build