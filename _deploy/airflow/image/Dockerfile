FROM docker.io/apache/airflow:slim-3.0.6-python3.12
USER root
RUN apt update && sudo apt install git -y
USER airflow
COPY requirements.txt /
RUN pip install --no-cache-dir "apache-airflow==3.0.6" -r /requirements.txt