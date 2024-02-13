@echo off

terraform state rm docker_volume.prom_data
terraform init
terraform get
terraform apply -auto-approve

docker stop test_python_hello
docker rm test_python_hello

docker build -t test_python_hello -f test.Dockerfile .
docker run -d --name test_python_hello --network devops_network test_python_hello
