#!/bin/bash

echo "Quick COVID-19 Pipeline Restart"
echo "=================================="

echo "Starting PostgreSQL database..."
docker-compose up -d postgres

echo "Waiting for database to be ready..."
sleep 10

echo "Database ready!"
echo ""
echo "Test your pipeline:"
echo "dbt run"
echo "dbt test"
echo "dbt docs generate && dbt docs serve"
echo ""
echo "Database: localhost:5432 (airbyte/airbyte123)" 