-- Creates index JOIN on state_code and county_code
CREATE INDEX idx_aqi_state ON AQI_Record(state_code);
CREATE INDEX idx_aqi_county ON AQI_Record(county_code, state_code);

-- GROUP BY on state_name, county_name, parameter_name-- a composite index on the join + group columns helps avoid sorting:
CREATE INDEX idx_aqi_composite ON AQI_Record(state_code, county_code, parameter_name, aqi);

-- Creates index on AQI
CREATE INDEX idx_aqi_aqi ON AQI_Record(aqi);

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
QUERY PLAN
|--SCAN A USING COVERING INDEX idx_aqi_composite
|--SEARCH S USING INTEGER PRIMARY KEY (rowid=?)
|--SEARCH C USING INDEX sqlite_autoindex_County_1 (county_code=? AND state_code=?)
|--USE TEMP B-TREE FOR GROUP BY
|--SCALAR SUBQUERY 1
|  `--SCAN AQI_Record USING COVERING INDEX idx_aqi_aqi
`--USE TEMP B-TREE FOR ORDER BY