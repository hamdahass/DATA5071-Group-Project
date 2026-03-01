-- Creates index JOIN on state_code and county_code
CREATE INDEX IF NOT EXISTS idx_aqi_state ON AQI_Record(state_code);
CREATE INDEX IF NOT EXISTS idx_aqi_county ON AQI_Record(county_code, state_code);

-- GROUP BY on state_name, county_name, parameter_name
-- A composite index on the join + group columns helps avoid sorting:
CREATE INDEX IF NOT EXISTS idx_aqi_composite ON AQI_Record(state_code, county_code, parameter_name, aqi);

-- Creates index on AQI
CREATE INDEX IF NOT EXISTS idx_aqi_aqi ON AQI_Record(aqi);

-- Index to support joins on AQI_Record ↔ Site (state_code, county_code, site_code)
CREATE INDEX IF NOT EXISTS idx_ar_state_county_site
ON AQI_Record(state_code, county_code, site_code);

-- Index to speed WHERE category='Hazardous' + GROUP BY state_code, parameter_name
CREATE INDEX IF NOT EXISTS idx_aqi_category_state_param
ON AQI_Record(category, state_code, parameter_name);

-- Query 1
EXPLAIN QUERY PLAN
SELECT S.state_name, C.county_name, A.parameter_name, AVG(A.aqi) as avg_aqi
FROM AQI_Record A
JOIN State S ON A.state_code = S.state_code
JOIN County C ON A.county_code = C.county_code AND A.state_code = C.state_code
GROUP BY S.state_name, C.county_name, A.parameter_name
HAVING AVG(A.aqi) > (
    SELECT AVG(aqi) FROM AQI_Record
)
ORDER BY S.state_name, C.county_name;

-- EXPLAIN QUERY 1 OUTPUT
-- QUERY PLAN
-- |--SCAN A USING COVERING INDEX idx_aqi_composite
-- |--SEARCH S USING INTEGER PRIMARY KEY (rowid=?)
-- |--SEARCH C USING INDEX sqlite_autoindex_County_1 (county_code=? AND state_code=?)
-- |--USE TEMP B-TREE FOR GROUP BY
-- |--SCALAR SUBQUERY 1
-- |  `--SCAN AQI_Record USING COVERING INDEX idx_aqi_aqi
-- `--USE TEMP B-TREE FOR ORDER BY


-- Query 2
EXPLAIN QUERY PLAN
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

-- EXPLAIN QUERY 2 OUTPUT
-- QUERY PLAN
-- |--SCAN ar USING COVERING INDEX idx_ar_state_county_site
-- |--SEARCH si USING COVERING INDEX sqlite_autoindex_Site_1 (county_code=? AND state_code=? AND site_code=?)
-- |--SEARCH c USING INDEX sqlite_autoindex_County_1 (county_code=? AND state_code=?)
-- |--SEARCH s USING INTEGER PRIMARY KEY (rowid=?)
-- `--USE TEMP B-TREE FOR DISTINCT


-- Query 3
EXPLAIN QUERY PLAN
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

-- EXPLAIN QUERY 3 OUTPUT
-- QUERY PLAN
-- |--SEARCH aqir1 USING COVERING INDEX idx_aqi_category_state_param (category=?)
-- |--SEARCH s USING INTEGER PRIMARY KEY (rowid=?)
-- |--CORRELATED SCALAR SUBQUERY 2
-- |  |--CO-ROUTINE (subquery-1)
-- |  |  `--SEARCH aqir2 USING COVERING INDEX idx_aqi_category_state_param (category=? AND state_code=?)
-- |  `--SEARCH (subquery-1)
-- `--USE TEMP B-TREE FOR ORDER BY
