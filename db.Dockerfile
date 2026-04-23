# Dockerfile for db
# We have two dockerfile because the app (.NET) and the database (SQL Server) are separate environments, whitch means  two different containers!
FROM mcr.microsoft.com/mssql/server:2022-latest

USER root
COPY init.sh /init.sh
COPY seed_data.sql /seed_data.sql
RUN chmod +x /init.sh

USER mssql
ENTRYPOINT ["/bin/bash", "-c", "/init.sh & /opt/mssql/bin/sqlservr"]