-- Part 2: Populate with Sample Data

INSERT OR IGNORE INTO State (state_code, state_name) VALUES
('1', 'Alabama'),
('2', 'Alaska'),
('4', 'Arizona'),
('5', 'Arkansas'),
('6', 'California');

INSERT OR IGNORE INTO County (state_code, county_code, county_name) VALUES
('1', '3', 'Baldwin'),
('2', '20', 'Anchorage'),
('4', '1', 'Apache'),
('5', '19', 'Clark'),
('6', '7', 'Butte'),
('6', '99', 'MissingAQICounty');

INSERT OR IGNORE INTO Site (state_code, county_code, site_code) VALUES
('1', '3', '01-003-0010'),
('2', '20', '02-020-0045'),
('4', '1', '04-001-1003'),
('5', '19', '05-019-9991'),
('6', '7', '06-007-0008'),
('6', '99', '06-099-001');

INSERT OR IGNORE INTO Pollutant (parameter_name) VALUES
('PM2.5'),
('PM10'),
('Ozone');

INSERT OR IGNORE INTO AQI_Record (state_code, county_code, date, aqi, category, parameter_name, site_code) VALUES
('1', '3',  '2025-01-01', 20, 'Good',      'PM2.5', '01-003-0010'),
('2', '20', '2025-01-01', 88, 'Moderate',  'PM2.5', '02-020-0045'),
('4', '1',  '2025-01-01', 22, 'Good',      'PM10',  '04-001-1003'),
('5', '19', '2025-01-01', 26, 'Good',      'Ozone', '05-019-9991'),
('6', '7',  '2025-01-01', 71, 'Moderate',  'PM2.5', '06-007-0008'),
('1', '3', '2025-01-02', 55, 'Moderate', 'Ozone', '01-003-0010'),
('2', '20', '2025-01-02', 120, 'Unhealthy for Sensitive Groups', 'PM2.5', '02-020-0045'),
('6', '7', '2025-01-03', 160, 'Unhealthy', 'PM10', '06-007-0008');

-- Testing
--SELECT * FROM AQI_Record;
--SELECT * FROM State;
--SELECT * FROM County;
--SELECT * FROM Site;
--SELECT * FROM Pollutant