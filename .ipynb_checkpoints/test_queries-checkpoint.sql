-- Query 1: Select all AQI records
SELECT *
FROM AQI_Record;

-- Query 2: Select AQI records with paramter name PM2.5
SELECT *
FROM AQI_Record
WHERE parameter_name = 'PM2.5';

-- Query 3: Sort all the AQI records in the Good category by site code
SELECT *
FROM AQI_Record
WHERE category = 'Good'
ORDER BY site_code;

-- Query 4: Using DISTINCT to remove duplicates
SELECT DISTINCT parameter_name
FROM AQI_Record;

-- Query 5: Using LIMIT or OFFSET to control the number of results returned
SELECT state_code, county_code, date, aqi
FROM AQI_Record
ORDER BY date DESC
LIMIT 5;