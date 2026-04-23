#!/bin/bash

# Wait for SQL Server to start up before executing seed_data.sql
# This is because SQL Server does not have an automated execution feature like MySQL does by default.
echo "Waiting for SQL Server to start..."
for i in {1..60}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" &> /dev/null
    if [ $? -eq 0 ]; then
        echo "SQL Server is up - executing script"
        # run seed_data.sql
        /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD}" -C -i /seed_data.sql
        break
    fi
    echo "Not ready yet..."
    sleep 1
done