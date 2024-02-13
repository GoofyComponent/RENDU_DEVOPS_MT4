# RENDU_DEVOPS_MT4

Repository containing the rendering of the DEVOPS course for HETIC's MT42025 promotion

## Usage

The startup script will execute and deploy the infrastructure needed for the project. Then, depending on the script launched, it will run the application or the application test.
This Python script utilizes PySpark to generate random data, organizes it, and stores it in a MongoDB database.
At the same time, the script creates a Grafana dashboard to monitor the MongoDB server (available at ip `<yourip>:8085`) and an Apache Spark Web UI (available at ip `<yourip>:8080` and `<yourip>:8081`).

## Login & Password

- Grafana : admin / grafana
- MongoDB : admin / adminpassword
- MongoExpress : admin / admin123

---

## How to launch

To launch the project, a script is available with all the commands but you will need on your machine:

- [Docker](https://docs.docker.com/get-docker/)
- [Terrafom](https://developer.hashicorp.com/terraform/tutorials/docker-get-started/install-cli)

Linux :

```bash
 sh startup.sh
```

Windows :

```bash
 ./startup.bat
```

---

## Tests

Some tests are available for the python script. You can launch them with the following commands:

Linux :

```bash
 sh test.sh
```

Windows :

```bash
 ./test.bat
```

---

## Team

- Grousset Luca
- Buisson Thomas
- Albuquerque Adrien
- Gamiette Teddy
- Azevedo Da Silva Antoine
- Vo Brandon
