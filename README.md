# DATA5071-Group-Project

## Authors
- Amanda Boschman
- Hamda Hassan
- Maya Silver
- Travis St Peter

## Schema Description
- State
    - Attributes:
        - state_code: INTEGER
        - state_name: TEXT
    - Primary Key:
        - state_code

- County
    - Attributes:
        - county_code: INTEGER
        - state_code: INTEGER
        - county_name: TEXT
    - Primary Key:
        - county_code
    - Foreign Key:
        - state_code

- Site
    - Atrributes:
        - site_code: INTEGER
        - state_code: INTEGER
        - county_code: INTEGER
    - Primary Key
        - site_code, state_code, county_code
    - Foreign Key
        - state_code
        - county_code

- AQI_record:
    - Attributes:
        - state_code: INTEGER
        - county_code: INTEGER
        - date: TEXT
        - aqi: INTEGER
        - category: TEXT
        - parameter_name: TEXT
        - site_code: INTEGER
    - Primary Key
        - state_code, county_code, date
    - Foreign Key
        - state_code
        - county_code
        - parameter_name
        - site_code
- Pollutant
    - Attributes:
        - parameter_name: TEXT
    - Primary Key
        - parameter_name

## Assumptions
- Each State has exactly one state_code.
- Each State has exactly one state_name.
- Each County is uniquely identified by the combination of state_code and county_code.
- Each County has exactly onen county_name.
- Each State may have zero or many Counties.
- Each Site is uniquely identified by the combination of state_code, county_code, and site_code.
- Each Site belongs to exactly one County.
- Each County may have zero or many Sites.
- Each pollutant may appear in zero or many AQI_records.
- Each AQI_record is a single AQI measurement for one Site, one Pollutant, and one Date.
- Each AQI_record refers to exactly one State, one County, one Site, and one Pollutant.
- A Site may ahve zero or many AQI_records.