# COVID-19 Analytics Pipeline
## dbt-core + Airbyte (45 minuten implementatie)

### Pipeline Overzicht
**Use Case**: Dagelijkse COVID-19 statistieken voor Nederlandse GGD regio's analyseren voor beleidsbeslissingen.

**Data Flow**:
```
COVID-19 API → Airbyte → PostgreSQL → dbt → Analytics Dashboard
```

---

## Data Architectuur

### Bron
- **RIVM COVID-19 API**: https://data.rivm.nl/covid-19/
- **Dataset**: Dagelijkse nieuwe gevallen per GGD regio
- **Format**: JSON via REST API
- **Update frequentie**: Dagelijks om 15:30

### Bestemming  
- **PostgreSQL**: Data warehouse
- **Schema**: `analytics.covid_daily_summary`

---

## Quick Start

### Prerequisites
- Docker Desktop installed
- Git Bash or PowerShell

### 1. Clone & Setup
```bash
git clone <your-repo-url>
cd dbt_etl_corona_hc

# Run setup (15 minutes)
chmod +x setup.sh
./setup.sh
```

### 2. Quick Restart (After PC restart)
```bash
# Quick restart (2 minutes)
chmod +x quick_start.sh
./quick_start.sh
```

### 3. Run Pipeline
```bash
# Build models
dbt run

# Test models
dbt test

# Generate docs
dbt docs generate
dbt docs serve
```

---

## Airbyte Configuratie

### Source: HTTP API Connector
```yaml
# airbyte_config/covid_source.yaml
source:
  name: "rivm-covid-api"
  source_type: "http-api"
  configuration:
    name: "COVID-19 RIVM"
    base_url: "https://data.rivm.nl/covid-19"
    path: "/COVID-19_aantallen_gemeente_cumulatief.json"
    http_method: "GET"
```

### Destination: PostgreSQL
```yaml
# airbyte_config/postgres_dest.yaml
destination:
  name: "postgres-warehouse"
  destination_type: "postgres"
  configuration:
    host: "localhost"
    port: 5432
    database: "covid_analytics"
    schema: "raw_data"
    username: "airbyte"
    password: "${POSTGRES_PASSWORD}"
```

### Connection
```yaml
# airbyte_config/covid_connection.yaml
connection:
  name: "covid-daily-sync"
  source: "rivm-covid-api"
  destination: "postgres-warehouse"
  sync_frequency: "0 16 * * *"  # Daily at 4 PM
  destination_namespace: "mirror_source"
```

---

## dbt Models

### Project Structuur
```
covid_analytics/
├── dbt_project.yml
├── models/
│   ├── staging/
│   │   ├── _sources.yml
│   │   ├── schema.yml
│   │   └── stg_covid_daily.sql
│   └── marts/
│       ├── schema.yml
│       └── mart_covid_summary.sql
├── airbyte_config/
│   ├── covid_source.yaml
│   ├── postgres_dest.yaml
│   └── covid_connection.yaml
├── docker-compose.yml
├── setup.sh
├── quick_start.sh
└── setup_database.sql
```

### 1. Sources & Staging
- **`_sources.yml`**: Definieert de raw data bron met validaties
- **`schema.yml`**: Model en kolom documentatie
- **`stg_covid_daily.sql`**: Data cleaning, type casting en null handling

### 2. Mart Model
- **`mart_covid_summary.sql`**: Business logic met:
  - Dagelijkse nieuwe gevallen (delta's)
  - 7-daags gemiddelde voor trend analyse
  - Risk level categorisatie (LOW/MEDIUM/HIGH)

---

## Pipeline Toelichting

### Waarom deze Pipeline?
1. **Relevantie**: COVID data is actueel en maatschappelijk relevant
2. **Simpliciteit**: 1 databron, duidelijke transformaties
3. **Schaalbaarheid**: Makkelijk uit te breiden met meer metrics

### Data Transformaties
```
Raw API Data → Staging (cleaning) → Mart (business logic)

Stap 1: Data typing en null handling
Stap 2: Dagelijkse nieuwe gevallen berekenen (delta's)  
Stap 3: 7-daags gemiddelde voor trend analyse
Stap 4: Risk level categorisatie voor beleid
```

### Business Value
- **Dagelijkse monitoring**: Automatisch dashboard voor GGD's
- **Trend analyse**: 7-daags gemiddelde voor beleidsbeslissingen  
- **Alerting**: Risk levels voor vroege waarschuwing

---

## Verification

### Check Database
```bash
# Connect to database
docker exec -it covid_postgres psql -U airbyte -d covid_analytics

# Check data
SELECT COUNT(*) FROM raw_data.covid_19_aantallen_gemeente_cumulatief;
SELECT COUNT(*) FROM analytics.mart_covid_summary;
```

### View Results
```bash
# See final analytics
dbt show --select mart_covid_summary
```

---

## Why This Works for Time Constraints

### Snel te implementeren (45 min)
- **Bekende API**: RIVM is reliable en goed gedocumenteerd
- **Simple schema**: Geen complexe joins of business rules
- **Standard transformaties**: Delta berekeningen en aggregaties

### Voldoet aan alle criteria
- **Modulariteit**: Staging + Mart layers
- **Airbyte begrip**: HTTP connector met schema definitie  
- **Documentatie**: Duidelijke uitleg van keuzes
- **Creativiteit**: Relevante use case met business impact

### Laat tijd over voor opdracht 2 & 3
- Monitoring hooks kunnen worden toegevoegd
- AWS deployment is straightforward uitbreiding
- Focus op core functionality eerste

---

## Documentation

### Generate Docs
```bash
dbt docs generate
dbt docs serve
```

### View Online
- Open `http://localhost:8080` in your browser
- See model lineage, column descriptions, and data tests

---

## Troubleshooting

### Common Issues
1. **Empty mart model**: Check date filter in `mart_covid_summary.sql`
2. **Database connection**: Ensure PostgreSQL container is running
3. **Permission errors**: Run setup scripts as Administrator

### Reset Everything
```bash
# Stop and remove containers
docker-compose down -v

# Start fresh
./setup.sh
```

---

## Support

- **Issues**: Create GitHub issue
- **Documentation**: Run `dbt docs serve`
- **Database**: Check Docker logs with `docker-compose logs postgres`

---

**Ready for opdracht 2 (monitoring) en 3 (AWS integratie)!**