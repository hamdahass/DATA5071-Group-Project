{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "92edb2da-1136-4054-b7f6-5ff96365a886",
   "metadata": {},
   "outputs": [],
   "source": [
    "-- Query 1: Which counties have AQI values higher than the overall average and what is the pollutant type? \n",
    "SELECT S.state_name, C.county_name, A.parameter_name, AVG(A.aqi) as avg_aqi\n",
    "FROM AQI_Record A\n",
    "JOIN State S ON A.state_code = S.state_code\n",
    "JOIN County C ON A.county_code = C.county_code AND A.state_code = C.state_code\n",
    "GROUP BY S.state_name, C.county_name, A.parameter_name\n",
    "HAVING AVG(A.aqi) > (\n",
    "    SELECT AVG(aqi)\n",
    "    FROM AQI_Record\n",
    ")\n",
    "ORDER BY S.state_name, C.county_name;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "c8af249e-13b4-44f9-ad7b-40803eda87cf",
   "metadata": {},
   "outputs": [],
   "source": [
    "-- Query 2: Which sites have recorded AQI entries, and where are they?\n",
    "\n",
    "SELECT DISTINCT\n",
    "  s.state_name,\n",
    "  c.county_name,\n",
    "  si.site_code\n",
    "FROM AQI_Record ar\n",
    "JOIN Site si\n",
    "  ON ar.state_code = si.state_code\n",
    " AND ar.county_code = si.county_code\n",
    " AND ar.site_code = si.site_code\n",
    "JOIN County c\n",
    "  ON si.state_code = c.state_code\n",
    " AND si.county_code = c.county_code\n",
    "JOIN State s\n",
    "  ON si.state_code = s.state_code\n",
    "ORDER BY s.state_name, c.county_name, si.site_code;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "1c5352a8-ef96-4619-bbb6-472595a52733",
   "metadata": {},
   "outputs": [],
   "source": [
    "-- Pollutant associated with the most 'Hazardous' days in each state\n",
    "\n",
    "SELECT\n",
    "    s.state_name, \n",
    "    aqir1.parameter_name,\n",
    "    COUNT(*) AS hazardous_days\n",
    "FROM AQI_Record aqir1\n",
    "JOIN State s ON s.state_code = aqir1.state_code\n",
    "WHERE aqir1.category = 'Hazardous'\n",
    "GROUP BY aqir1.state_code, aqir1.parameter_name\n",
    "HAVING COUNT(*) = (\n",
    "    SELECT MAX(total_hazardous_days)\n",
    "    FROM (\n",
    "        SELECT COUNT(*) AS total_hazardous_days\n",
    "        FROM AQI_Record aqir2\n",
    "        WHERE aqir2.category = 'Hazardous'\n",
    "            AND aqir2.state_code = aqir1.state_code\n",
    "        GROUP BY aqir2.parameter_name\n",
    "    )\n",
    ")\n",
    "ORDER BY hazardous_days DESC;"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "id": "4ae83729-91d3-41b0-b44c-1b81b1090586",
   "metadata": {},
   "outputs": [],
   "source": [
    "-- Finds states that have AQI values higher than the average AQI of all records classified as 'Good'\n",
    "\n",
    "SELECT DISTINCT\n",
    "    s.state_name\n",
    "FROM AQI_Record a\n",
    "JOIN State s\n",
    "  ON a.state_code = s.state_code\n",
    "WHERE a.aqi > (\n",
    "    SELECT AVG(aqi)\n",
    "    FROM AQI_Record\n",
    "    WHERE category = 'Good'\n",
    ");"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python [conda env:base] *",
   "language": "python",
   "name": "conda-base-py"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.13.5"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
