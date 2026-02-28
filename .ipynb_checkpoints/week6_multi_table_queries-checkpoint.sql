-- Query 1: INNER JOIN, WHERE
-- Give dates, AQI, and parameter of instances in category 'Good'
-- Ordered by state, then AQI
SELECT AQI_Record.date, AQI_Record.aqi, AQI_Record.parameter_name, State.state_name
FROM AQI_Record
INNER JOIN State ON State.state_code = AQI_Record.state_code
WHERE AQI_Record.category = 'Good'
ORDER BY State.state_name, AQI_Record.aqi, AQI_Record.date;

-- Query 2: LEFT JOIN, ORDER BY
-- All counties and their aqi values (one row per AQI Record)
-- Includes counties with no AQI data
-- Orderd by aqi values, descending
SELECT State.state_name, County.county_name, AQI_Record.aqi
FROM County
INNER JOIN State ON State.state_code = County.state_code
LEFT JOIN AQI_Record 
	ON AQI_Record.state_code = County.state_code
	AND AQI_Record.county_code = County.county_code
ORDER BY AQI_Record.aqi DESC;


-- Query 3: CALCULATED COLUMN, GROUP BY
-- Average AQI ratio of each county
-- Grouped by state name, county name
-- Ordered by average AQI ratio, descending
SELECT
	State.state_name,
	County.county_name,
	AVG(AQI_Record.aqi) as avg_aqi,
	(AVG(AQI_Record.aqi)/500.0) as avg_aqi_ratio
FROM County
INNER JOIN State ON State.state_code = County.state_code
LEFT JOIN AQI_Record
	ON AQI_Record.state_code = County.state_code
	AND AQI_Record.county_code = County.county_code
GROUP BY State.state_name, County.county_name
ORDER BY avg_aqi_ratio DESC;