{{ config(materialized='view') }}

SELECT 
    Date_of_publication::date as report_date,
    Municipality_name as municipality,
    Province as province,
    COALESCE(Total_reported, 0) as total_cases,
    COALESCE(Hospital_admission, 0) as hospital_admissions,
    COALESCE(Deceased, 0) as deaths,
    _airbyte_extracted_at as extracted_at
FROM {{ source('raw_covid', 'covid_19_aantallen_gemeente_cumulatief') }}
WHERE Date_of_publication IS NOT NULL
  AND Date_of_publication >= '2024-01-01' 