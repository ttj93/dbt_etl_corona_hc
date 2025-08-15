# COVID-19 Analytics Pipeline Setup for Windows
# Run this in PowerShell as Administrator

Write-Host "COVID-19 Analytics Pipeline Complete Setup" -ForegroundColor Green
Write-Host "=============================================" -ForegroundColor Green

# Check if Docker is installed
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker is not installed. Please install Docker Desktop first:" -ForegroundColor Red
    Write-Host "   https://www.docker.com/products/docker-desktop/" -ForegroundColor Yellow
    exit 1
}

# Check if Docker Compose is available
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Host "Docker Compose is not available. Please install Docker Desktop with Compose." -ForegroundColor Red
    exit 1
}

Write-Host "Starting PostgreSQL database..." -ForegroundColor Blue
docker-compose up -d postgres

Write-Host "Waiting for PostgreSQL to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

Write-Host "Setting up database schema..." -ForegroundColor Blue
# Wait for PostgreSQL to be ready
do {
    Write-Host "Waiting for PostgreSQL..."
    Start-Sleep -Seconds 2
    $ready = docker exec covid_postgres pg_isready -U airbyte -d covid_analytics 2>$null
} while ($LASTEXITCODE -ne 0)

# Run database setup
Get-Content setup_database.sql | docker exec -i covid_postgres psql -U airbyte -d covid_analytics

Write-Host "Installing dbt-core if not present..." -ForegroundColor Blue
if (-not (Get-Command dbt -ErrorAction SilentlyContinue)) {
    pip install dbt-core dbt-postgres
}

# Setup dbt profile
Write-Host "Setting up dbt profile..." -ForegroundColor Blue
$dbtDir = "$env:USERPROFILE\.dbt"
if (-not (Test-Path $dbtDir)) {
    New-Item -ItemType Directory -Path $dbtDir -Force
}

$profileContent = @"
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
"@

$profileContent | Out-File -FilePath "$dbtDir\profiles.yml" -Encoding UTF8

Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Your pipeline is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "Test the setup:" -ForegroundColor Cyan
Write-Host "1. Check database: docker exec -it covid_postgres psql -U airbyte -d covid_analytics" -ForegroundColor White
Write-Host "2. Run dbt: dbt run --models staging marts" -ForegroundColor White
Write-Host "3. Test models: dbt test" -ForegroundColor White
Write-Host ""
Write-Host "Optional: Airbyte UI available at http://localhost:8000" -ForegroundColor Yellow
Write-Host "Database accessible at localhost:5432 (user: airbyte, pass: airbyte123)" -ForegroundColor Yellow 