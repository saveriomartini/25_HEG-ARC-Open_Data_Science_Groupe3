# Sample CSV Data Formats

This directory should contain your Synthea-generated CSV files. 

## Required CSV Files

Place the following files in this directory or in the Neo4j import directory:

### 1. patients.csv

Example structure:
```csv
Id,BIRTHDATE,DEATHDATE,SSN,DRIVERS,PASSPORT,PREFIX,FIRST,LAST,SUFFIX,MAIDEN,MARITAL,RACE,ETHNICITY,GENDER,BIRTHPLACE,ADDRESS,CITY,STATE,COUNTY,ZIP,LAT,LON,HEALTHCARE_EXPENSES,HEALTHCARE_COVERAGE
a1b2c3d4-e5f6-7890-abcd-ef1234567890,1990-05-15,,999-99-9999,S99999999,X12345678,Mr.,John,Doe,,,M,white,nonhispanic,M,"Boston, MA",123 Main St,Boston,Massachusetts,Suffolk County,02101,42.3601,-71.0589,12500.50,10000.00
```

### 2. allergies.csv

Example structure:
```csv
START,STOP,PATIENT,ENCOUNTER,CODE,SYSTEM,DESCRIPTION,TYPE,CATEGORY,REACTION1,DESCRIPTION1,SEVERITY1,REACTION2,DESCRIPTION2,SEVERITY2
2010-06-15,,a1b2c3d4-e5f6-7890-abcd-ef1234567890,encounter-123,419199007,SNOMED-CT,Allergy to substance,allergy,environment,39579001,Anaphylaxis,severe,,,
```

### 3. conditions.csv

Example structure:
```csv
START,STOP,PATIENT,ENCOUNTER,CODE,DESCRIPTION
2015-03-20,2015-04-10,a1b2c3d4-e5f6-7890-abcd-ef1234567890,encounter-456,233604007,Pneumonia
```

### 4. devices.csv

Example structure:
```csv
START,STOP,PATIENT,ENCOUNTER,CODE,DESCRIPTION,UDI
2018-07-10,,a1b2c3d4-e5f6-7890-abcd-ef1234567890,encounter-789,468063009,Cardiac pacemaker,00811234567890
```

## Generating Synthea Data

To generate sample data using Synthea:

1. Download Synthea from https://github.com/synthetichealth/synthea
2. Run Synthea to generate synthetic patient data:
   ```bash
   java -jar synthea-with-dependencies.jar -p 100
   ```
3. The CSV files will be generated in the `output/csv` directory
4. Copy the required CSV files to this directory or to your Neo4j import directory

## Notes

- All patient IDs should be consistent across different CSV files
- SNOMED CT codes should be valid SNOMED CT concept IDs
- Dates should be in ISO 8601 format (YYYY-MM-DD)
- Empty values can be represented as empty strings or NULL
