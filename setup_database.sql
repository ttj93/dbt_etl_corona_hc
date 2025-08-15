-- COVID-19 Analytics Database Setup
-- Run this after PostgreSQL is running

-- Create schemas
CREATE SCHEMA IF NOT EXISTS raw_data;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Create sample table structure (simulating what Airbyte would create)
CREATE TABLE IF NOT EXISTS raw_data.covid_19_aantallen_gemeente_cumulatief (
    Date_of_publication VARCHAR(50),
    Municipality_name VARCHAR(100),
    Province VARCHAR(100),
    Total_reported INTEGER,
    Hospital_admission INTEGER,
    Deceased INTEGER,
    _airbyte_extracted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Clear existing data and insert fresh sample data for testing
TRUNCATE TABLE raw_data.covid_19_aantallen_gemeente_cumulatief;

-- Insert sample data for testing (recent dates)
INSERT INTO raw_data.covid_19_aantallen_gemeente_cumulatief 
(Date_of_publication, Municipality_name, Province, Total_reported, Hospital_admission, Deceased) VALUES
-- Recent data (within 90 days)
('2024-12-01', 'Amsterdam', 'Noord-Holland', 1500, 45, 12),
('2024-12-01', 'Rotterdam', 'Zuid-Holland', 1200, 38, 8),
('2024-12-01', 'Den Haag', 'Zuid-Holland', 800, 25, 5),
('2024-12-02', 'Amsterdam', 'Noord-Holland', 1550, 48, 13),
('2024-12-02', 'Rotterdam', 'Zuid-Holland', 1230, 40, 9),
('2024-12-02', 'Den Haag', 'Zuid-Holland', 820, 26, 5),
('2024-12-03', 'Amsterdam', 'Noord-Holland', 1580, 50, 14),
('2024-12-03', 'Rotterdam', 'Zuid-Holland', 1250, 42, 10),
('2024-12-03', 'Den Haag', 'Zuid-Holland', 840, 27, 6),
('2024-12-04', 'Amsterdam', 'Noord-Holland', 1600, 52, 15),
('2024-12-04', 'Rotterdam', 'Zuid-Holland', 1270, 44, 11),
('2024-12-04', 'Den Haag', 'Zuid-Holland', 860, 28, 7),
('2024-12-05', 'Amsterdam', 'Noord-Holland', 1620, 54, 16),
('2024-12-05', 'Rotterdam', 'Zuid-Holland', 1290, 46, 12),
('2024-12-05', 'Den Haag', 'Zuid-Holland', 880, 29, 8),
('2024-12-06', 'Amsterdam', 'Noord-Holland', 1640, 56, 17),
('2024-12-06', 'Rotterdam', 'Zuid-Holland', 1310, 48, 13),
('2024-12-06', 'Den Haag', 'Zuid-Holland', 900, 30, 9),
('2024-12-07', 'Amsterdam', 'Noord-Holland', 1660, 58, 18),
('2024-12-07', 'Rotterdam', 'Zuid-Holland', 1330, 50, 14),
('2024-12-07', 'Den Haag', 'Zuid-Holland', 920, 31, 10);

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA raw_data TO airbyte;
GRANT ALL PRIVILEGES ON SCHEMA analytics TO airbyte;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA raw_data TO airbyte;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO airbyte; 