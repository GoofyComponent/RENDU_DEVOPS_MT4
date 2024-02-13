#Terraform configuration
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

locals {
  my_relative_path = "./"
  my_absolute_path = abspath(local.my_relative_path)

  current_working_directory = pathexpand(local.my_absolute_path)
}
output "absolute_path" {
  value = local.my_absolute_path
}
output "current_working_directory" {
  value = local.current_working_directory
}

# Docker network
resource "docker_network" "devops_network" {
  name   = "devops_network"
  driver = "bridge"
}

resource "docker_volume" "prom_data" {
  name = "prom_data"
}

# MongoDB related resources images
# MongoDB
resource "docker_image" "mongodb" {
  name = "mongo:latest"
}

# Mongodb visualizer
resource "docker_image" "mongo-express" {
  name = "mongo-express:latest"
}

# Mongodb monitoring
resource "docker_image" "mongodb-exporter" {
  name = "percona/mongodb_exporter:2.37.0"
}

resource "docker_image" "prometheus" {
  name = "prom/prometheus:v2.44.0"
}

resource "docker_image" "grafana" {
  name = "grafana/grafana:9.5.2"
}

# MongoDB related resources containers
resource "docker_container" "mongodb" {
  image = docker_image.mongodb.image_id
  name  = "mongodb-container"
  #ports {
    #internal = 27017
    #external = 3445
  #}
  restart = "unless-stopped"
  env = [
    "MONGO_INITDB_ROOT_USERNAME=admin", "MONGO_INITDB_ROOT_PASSWORD=adminpassword"
  ]
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["mongodb"]
  }
  
}

resource "docker_container" "mongo-express" {
  name  = "mongo-express-container"
  image = docker_image.mongo-express.name
  ports {
    internal = 8081
    external = 8082
  }
  restart = "unless-stopped"
  env = [
    "ME_CONFIG_MONGODB_SERVER=mongodb-container",
    "ME_CONFIG_MONGODB_ENABLE_ADMIN=true",
    "ME_CONFIG_MONGODB_ADMINUSERNAME=admin",
    "ME_CONFIG_MONGODB_ADMINPASSWORD=adminpassword",
    "ME_CONFIG_BASICAUTH_USERNAME=admin",
    "ME_CONFIG_BASICAUTH_PASSWORD=admin123"
  ]
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["mongo-express"]
  }
  depends_on = [
    docker_container.mongodb
  ]
}

resource "docker_container" "mongodb_exporter" {
  name    = "mongodb_exporter"
  image   = docker_image.mongodb-exporter.name
  command = ["--mongodb.global-conn-pool", "--collector.diagnosticdata", "--discovering-mode", "--mongodb.uri=mongodb://admin:adminpassword@mongodb-container:27017/"]
  restart = "unless-stopped"
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["mongodb_exporter"]
  }
  depends_on = [
    docker_container.mongodb
  ]
}

resource "docker_container" "prometheus" {
  name    = "prometheus"
  image   = docker_image.prometheus.name
  command = ["--config.file=/etc/prometheus/prometheus.yml"]
  restart = "unless-stopped"
  #ports {
    #internal = 9090
    #external = 8084
  #}
  volumes {
    container_path = "/etc/prometheus"
    host_path      = "${local.current_working_directory}/monitoring/prometheus"
    read_only      = false
  }
  volumes {
    container_path = "/prometheus"
    volume_name = docker_volume.prom_data.name
    read_only      = false
  }
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["prometheus"]
  }
  depends_on = [ 
    docker_container.mongodb_exporter
   ]
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.name
  ports {
    internal = 3000
    external = 8085
  }
  restart = "unless-stopped"
  env = [
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=grafana",
    "GF_PROVISIONING_ENABLED=true"
  ]
  volumes {
    container_path = "/etc/grafana/provisioning/datasources"
    host_path      = "${local.current_working_directory}/monitoring/grafana/datasources"
    read_only      = false
  }
  volumes {
    container_path = "/etc/grafana/provisioning/dashboards"
    host_path      = "${local.current_working_directory}/monitoring/grafana/dashboards"
    read_only      = false
  }
  volumes {
    container_path = "/var/lib/grafana/dashboards"
    host_path      = "${local.current_working_directory}/monitoring/grafana/dashboards"
    read_only      = false
  }
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["grafana"]
  }
  depends_on = [
    docker_container.prometheus
  ]
}


# Apache Spark related resources
resource "docker_image" "spark" {
  name = "bitnami/spark:3.5.0"
}

resource "docker_container" "spark-master" {
  image = docker_image.spark.image_id
  name  = "spark-master"
  restart = "unless-stopped"
  env = [
    "SPARK_MODE=master",
    "SPARK_RPC_AUTHENTICATION_ENABLED=no",
    "SPARK_RPC_ENCRYPTION_ENABLED=no",
    "SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED=no",
    "SPARK_SSL_ENABLED=no",
    "SPARK_USER=spark"
  ]
  ports {
    internal = 8080
    external = 8080
  }
  ports {
    internal = 7077
    external = 7077
  }
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["spark-master"]
  }
  depends_on = [
    docker_container.mongodb
  ]
  host {
    host = "host.docker.internal"
    ip   = "192.168.31.87"
  }
}

resource "docker_container" "spark-worker" {
  image = docker_image.spark.image_id
  name  = "spark-worker"
  restart = "unless-stopped"
  ports {
    internal = 8081
    external = 8081
  }
  env = [
    "SPARK_MODE=worker",
    "SPARK_MASTER_URL=spark://spark-master:7077",
    "SPARK_WORKER_CORES=1",
    "SPARK_WORKER_MEMORY=1G",
    "SPARK_RPC_AUTHENTICATION_ENABLED=no",
    "SPARK_RPC_ENCRYPTION_ENABLED=no",
    "SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED=no",
    "SPARK_SSL_ENABLED=no",
    "SPARK_USER=spark"
  ]
  networks_advanced {
    name    = docker_network.devops_network.name
    aliases = ["spark-worker"]
  }
  depends_on = [
    docker_container.spark-master
  ]
  #host {
    #host = "host.docker.internal"
    #ip   = "192.168.31.87"
  #}
}
