FROM python:3.11-bullseye

RUN apt update

RUN apt-get install -y openjdk-11-jdk
RUN apt-get install -y openjdk-11-jre

WORKDIR /app

COPY ./src .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["pytest", "test.py"]
