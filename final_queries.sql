-- Final SQL Queries for Presentation and Report


-- Query 1: County-Pollutant Combinations with Above-Average AQI
-- Purpose: Identify county and pollutant combinations where the
-- average AQI is higher than the overall average AQI across all records.
-- 
-- This helps to identify regions and pollutant types associated with
-- relatively worse air quality in the dataset.

SELECT 
    S.state_name,
    C.county_name,
    A.parameter_name,
    AVG(A.aqi) AS avg_aqi
FROM AQI_Record A
JOIN State S ON A.state_code = S.state_code
JOIN County C 
    ON A.county_code = C.county_code
    AND A.state_code = C.state_code
GROUP BY S.state_name, C.county_name, A.parameter_name
HAVING AVG(A.aqi) > (
    SELECT AVG(aqi)
    FROM AQI_Record
)
ORDER BY S.state_name, C.county_name;


-- Query 2: Pollutant Associated with the Most Unhealthy Days in Each State
-- Purpose: Identify the pollutant associated with
-- the greatest number of Unhealthy AQI days in each state.
--
-- This helps to identify which pollutant contributed most often
-- to unhealthy air quality days in each state.

SELECT
    S.state_name, 
    A1.parameter_name,
    COUNT(*) AS unhealthy_days
FROM AQI_Record A1
JOIN State S ON S.state_code = A1.state_code
WHERE A1.category = 'Unhealthy'
GROUP BY A1.state_code, A1.parameter_name
HAVING COUNT(*) = (
    SELECT MAX(total_unhealthy_days)
    FROM (
        SELECT COUNT(*) AS total_unhealthy_days
        FROM AQI_Record A2
        WHERE A2.category = 'Unhealthy'
            AND A2.state_code = A1.state_code
        GROUP BY A2.parameter_name
    )
)
ORDER BY unhealthy_days DESC;


-- Query 3: Average AQI Ratio by County
-- Purpose: Calculate the average AQI value for each county
-- and express it as a ratio of the maximum AQI value (500).
--
-- This helps compare overall air quality levels across counties
-- and identifies areas with relatively higher pollution levels.

SELECT
    S.state_name,
    C.county_name,
    AVG(A.aqi) AS avg_aqi,
    (AVG(A.aqi)/500.0) AS avg_aqi_ratio
FROM County C
INNER JOIN State S ON S.state_code = C.state_code
LEFT JOIN AQI_Record A 
    ON A.state_code = C.state_code
    AND A.county_code = C.county_code
GROUP BY S.state_name, C.county_name
ORDER BY avg_aqi_ratio DESC;


-- Query 4: Counties and their Recorded AQI Values
-- Purpose: List all counties and their recorded AQI values,
-- including counties that do not have AQI measurements.
--
-- A LEFT JOIN is used so that counties without AQI data
-- are included in the results.
-- The results are ordered by AQI in descending order.

SELECT 
    S.state_name,
    C.county_name,
    A.aqi
FROM County C
INNER JOIN State S ON S.state_code = C.state_code
LEFT JOIN AQI_Record A
    ON A.state_code = C.state_code
    AND A.county_code = C.county_code
ORDER BY A.aqi DESC;