{{ config(
    materialized='table',
    indexes=[{'columns': ['report_date'], 'type': 'btree'}]
) }}

WITH daily_province_stats AS (
    SELECT 
        report_date,
        province,
        SUM(total_cases) as province_total_cases,
        SUM(hospital_admissions) as province_hospital_admissions,
        SUM(deaths) as province_deaths,
        COUNT(DISTINCT municipality) as municipalities_count
    FROM {{ ref('stg_covid_daily') }}
    GROUP BY report_date, province
),

daily_changes AS (
    SELECT *,
        -- Bereken dagelijkse nieuwe gevallen (delta)
        province_total_cases - LAG(province_total_cases) OVER (
            PARTITION BY province 
            ORDER BY report_date
        ) as new_cases_daily,
        
        province_hospital_admissions - LAG(province_hospital_admissions) OVER (
            PARTITION BY province 
            ORDER BY report_date  
        ) as new_admissions_daily
        
    FROM daily_province_stats
),

with_7day_avg AS (
    SELECT *,
        -- 7-daags gemiddelde van dagelijkse nieuwe gevallen
        AVG(new_cases_daily) OVER (
            PARTITION BY province 
            ORDER BY report_date 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) as avg_7day_new_cases
    FROM daily_changes
)

SELECT 
    report_date,
    province,
    province_total_cases,
    COALESCE(new_cases_daily, 0) as new_cases_daily,
    ROUND(COALESCE(avg_7day_new_cases, 0), 1) as avg_7day_new_cases,
    province_hospital_admissions,
    COALESCE(new_admissions_daily, 0) as new_admissions_daily,
    province_deaths,
    municipalities_count,
    
    -- Business metrics
    CASE 
        WHEN COALESCE(avg_7day_new_cases, 0) > 100 THEN 'HIGH'
        WHEN COALESCE(avg_7day_new_cases, 0) > 50 THEN 'MEDIUM' 
        ELSE 'LOW'
    END as risk_level
    
FROM with_7day_avg
WHERE report_date >= CURRENT_DATE - INTERVAL '1 year'  -- Changed from 90 days to 1 year
ORDER BY report_date DESC, province 