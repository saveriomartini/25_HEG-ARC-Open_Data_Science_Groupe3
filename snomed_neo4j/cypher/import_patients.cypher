// Import Patients from CSV
// This script imports patient data from a Synthea-generated CSV file
//
// Expected CSV columns: Id, BIRTHDATE, DEATHDATE, SSN, DRIVERS, PASSPORT, PREFIX, FIRST, LAST, 
//                       SUFFIX, MAIDEN, MARITAL, RACE, ETHNICITY, GENDER, BIRTHPLACE, ADDRESS, 
//                       CITY, STATE, COUNTY, ZIP, LAT, LON, HEALTHCARE_EXPENSES, HEALTHCARE_COVERAGE
//
// Usage: Place your patients.csv file in the import directory and run this script

// Load patients with batching for large datasets (Neo4j 5.x compatible)
// For Neo4j 4.x, you can use USING PERIODIC COMMIT 500 instead
:auto LOAD CSV WITH HEADERS FROM 'file:///patients.csv' AS row
CALL {
  WITH row
  // Create or merge patient nodes
  MERGE (p:Patient {id: row.Id})
  ON CREATE SET
      p.birthDate = row.BIRTHDATE,
      p.deathDate = row.DEATHDATE,
      p.ssn = row.SSN,
      p.drivers = row.DRIVERS,
      p.passport = row.PASSPORT,
      p.prefix = row.PREFIX,
      p.firstName = row.FIRST,
      p.lastName = row.LAST,
      p.suffix = row.SUFFIX,
      p.maidenName = row.MAIDEN,
      p.marital = row.MARITAL,
      p.race = row.RACE,
      p.ethnicity = row.ETHNICITY,
      p.gender = row.GENDER,
      p.birthplace = row.BIRTHPLACE,
      p.address = row.ADDRESS,
      p.city = row.CITY,
      p.state = row.STATE,
      p.county = row.COUNTY,
      p.zip = row.ZIP,
      p.lat = toFloat(row.LAT),
      p.lon = toFloat(row.LON),
      p.healthcareExpenses = toFloat(row.HEALTHCARE_EXPENSES),
      p.healthcareCoverage = toFloat(row.HEALTHCARE_COVERAGE),
      p.name = row.PREFIX + ' ' + row.FIRST + ' ' + row.LAST
} IN TRANSACTIONS OF 500 ROWS;
