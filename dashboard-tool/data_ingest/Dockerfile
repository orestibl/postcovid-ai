FROM mcr.microsoft.com/devcontainers/python:1-3.10-bullseye

ENV PYTHONUNBUFFERED 1

RUN lsb_release -a

COPY requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
   && rm -rf /tmp/pip-tmp

WORKDIR /app

COPY . .

ENTRYPOINT ["python3", "main.py"]

# Generar imagen y correr contenedor
# docker build -t data_ingest .
# Ejecutar contenedor con archivo de entrada
# Cambiar ./csv por la ruta del archivo de entrada
# docker run data_ingest indicators.csv
# docker run --rm --network host -v ./csv:/app/csv data_ingest
