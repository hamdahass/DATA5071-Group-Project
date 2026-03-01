-- Query 1: Which counties have AQI values higher than the overall average and what is the pollutant type? 
SELECT S.state_name, C.county_name, A.parameter_name, AVG(A.aqi) as avg_aqi
FROM AQI_Record A
JOIN State S ON A.state_code = S.state_code
JOIN County C ON A.county_code = C.county_code AND A.state_code = C.state_code
GROUP BY S.state_name, C.county_name, A.parameter_name
HAVING AVG(A.aqi) > (
    SELECT AVG(aqi)
    FROM AQI_Record
)
ORDER BY S.state_name, C.county_name;


-- Query 2: Which sites have recorded AQI entries, and where are they?
SELECT DISTINCT
  s.state_name,
  c.county_name,
  si.site_code
FROM AQI_Record ar
JOIN Site si
  ON ar.state_code = si.state_code
 AND ar.county_code = si.county_code
 AND ar.site_code = si.site_code
JOIN County c
  ON si.state_code = c.state_code
 AND si.county_code = c.county_code
JOIN State s
  ON si.state_code = s.state_code
ORDER BY s.state_name, c.county_name, si.site_code;

-- Query 3: Pollutant associated with the most 'Hazardous' days in each state
SELECT
    s.state_name, 
    aqir1.parameter_name,
    COUNT(*) AS hazardous_days
FROM AQI_Record aqir1
JOIN State s ON s.state_code = aqir1.state_code
WHERE aqir1.category = 'Hazardous'
GROUP BY aqir1.state_code, aqir1.parameter_name
HAVING COUNT(*) = (
    SELECT MAX(total_hazardous_days)
    FROM (
        SELECT COUNT(*) AS total_hazardous_days
        FROM AQI_Record aqir2
        WHERE aqir2.category = 'Hazardous'
            AND aqir2.state_code = aqir1.state_code
        GROUP BY aqir2.parameter_name
    )
)
ORDER BY hazardous_days DESC;
