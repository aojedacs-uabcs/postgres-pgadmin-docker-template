FROM postgres:16-alpine

# Copiar todos los scripts de inicialización de tu carpeta al contenedor
COPY ./init-scripts/ /docker-entrypoint-initdb.d/

EXPOSE 5432