-- Part 1: Schema Implementation

-- Create State table 
CREATE TABLE State (
state_code INTEGER PRIMARY KEY,
state_name TEXT NOT NULL
);

-- Create County table
CREATE TABLE County (
state_code INTEGER NOT NULL,
county_code INTEGER NOT NULL,
county_name TEXT NOT NULL,
PRIMARY KEY (county_code, state_code),
FOREIGN KEY (state_code) REFERENCES State(state_code)
);
	
-- Create Site table
CREATE TABLE Site (
state_code INTEGER NOT NULL,
county_code INTEGER NOT NULL,
site_code INTEGER NOT NULL,
PRIMARY KEY (county_code, state_code, site_code),
FOREIGN KEY (state_code) REFERENCES State(state_code),
FOREIGN KEY (county_code, state_code) REFERENCES County(county_code, state_code)
);

-- Create Pollutant table
CREATE TABLE Pollutant (
  parameter_name TEXT NOT NULL PRIMARY KEY
);

-- Create AQI Record table
CREATE TABLE AQI_Record (
state_code INTEGER NOT NULL,
county_code INTEGER NOT NULL,
date TEXT NOT NULL,
aqi INTEGER NOT NULL,
category TEXT NOT NULL,
parameter_name TEXT NOT NULL,
site_code INTEGER NOT NULL,
PRIMARY KEY (state_code, county_code, date),
FOREIGN KEY (state_code) REFERENCES State(state_code),
FOREIGN KEY (county_code, state_code) REFERENCES County(county_code, state_code),
FOREIGN KEY (parameter_name) REFERENCES Pollutant(parameter_name),
FOREIGN KEY (county_code, state_code, site_code) REFERENCES Site(county_code, state_code, site_code)
);