#!/bin/bash

echo "COVID-19 Analytics Pipeline Complete Setup"
echo "============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker Desktop first:"
    echo "   https://www.docker.com/products/docker-desktop/"
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not available. Please install Docker Desktop with Compose."
    exit 1
fi

echo "Starting PostgreSQL database..."
docker-compose up -d postgres

echo "Waiting for PostgreSQL to be ready..."
sleep 15

echo "Setting up database schema..."
# Wait for PostgreSQL to be ready
until docker exec covid_postgres pg_isready -U airbyte -d covid_analytics; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done

# Run database setup
docker exec -i covid_postgres psql -U airbyte -d covid_analytics < setup_database.sql

echo "Installing dbt-core if not present..."
if ! command -v dbt &> /dev/null; then
    pip install dbt-core dbt-postgres
fi

# Setup dbt profile
echo "Setting up dbt profile..."
mkdir -p ~/.dbt
cat > ~/.dbt/profiles.yml << EOF
covid_analytics:
  target: dev
  outputs:
    dev:
      type: postgres
      host: localhost
      port: 5432
      user: airbyte
      pass: "airbyte123"
      dbname: covid_analytics
      schema: analytics
      threads: 4
EOF

echo "Setup complete!"
echo ""
echo "Your pipeline is ready!"
echo ""
echo "Test the setup:"
echo "1. Check database: docker exec -it covid_postgres psql -U airbyte -d covid_analytics"
echo "2. Run dbt: dbt run --models staging marts"
echo "3. Test models: dbt test"
echo ""
echo "Optional: Airbyte UI available at http://localhost:8000"
echo "Database accessible at localhost:5432 (user: airbyte, pass: airbyte123)" 